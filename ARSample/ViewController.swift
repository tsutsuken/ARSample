//
//  ViewController.swift
//  ARSample
//
//  Created by Ken Tsutsumi on 2022/10/12.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet var arView: ARView!
    @IBOutlet weak var saveWorldButton: UIButton!
    @IBOutlet weak var restoreWorldButton: UIButton!
    
    let keyWorldMap = "keyWorldMap"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンを生成
        saveWorldButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapSaveWorldButton)))
        restoreWorldButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapRestoreWorldButton(_:))))
        
        // boxAnchorをARViewにセット
        let boxAnchor = try! Experience.loadBox()
        arView.scene.anchors.append(boxAnchor)
    }
    
    @objc func didTapSaveWorldButton(_ sender: UITapGestureRecognizer) {
        saveCurrentWorldMap()
    }
    
    @objc func didTapRestoreWorldButton(_ sender: UITapGestureRecognizer) {
        restoreSavedWorldMap()
    }
}

// MARK: - WorldMap
extension ViewController {
    func saveCurrentWorldMap() {
        print("saveCurrentWorldMap")
        arView.session.getCurrentWorldMap { [weak self] worldMap, error in
            guard let self = self else { return }
            guard let worldMap = worldMap else {
                print("getCurrentWorldMap error: \(String(describing: error))")
                return
            }

            // ARWorldMapをUserDefaultsに保存
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                UserDefaults.standard.set(data, forKey: self.keyWorldMap)
                print("saveCurrentWorldMap success data: \(data)")
            } catch let error {
                print("saveCurrentWorldMap error: \(error)")
            }
        }
    }
    
    func restoreSavedWorldMap() {
        print("restoreSavedWorldMap")
        
        // ワールドのDataを復元
        let mapData = UserDefaults.standard.data(forKey: keyWorldMap)
        guard let mapData = mapData else {
            print("restoreSavedWorldMap error: mapData is nil")
            return
        }
        
        // DataをARWorldMapに変換
        var worldMap: ARWorldMap?
        do {
            worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData)
            print("restoreSavedWorldMap success worldMap: \(String(describing: worldMap))")
        } catch let error {
            print("restoreSavedWorldMap error: \(error)")
            return
        }
        
        // ARWorldMapをARViewにセット
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
