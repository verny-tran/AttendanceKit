//
//  InstitutionController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 02/01/2024.
//

import UIKit
import AVFoundation
import RealmSwift
import General

class InstitutionController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.stroke(radius: 25.5, size: 1, color: .opaqueSeparator)
        self.stackView.arrangedSubviews.forEach({ $0.corner(radius: 16) })
        self.loadData()
        
        guard !Reachability.isConnectedToInternet else { return }
        self.showDialog(message: "You have not connected to internet. Using local data.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FaceNet.main.clean()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        
        FaceNet.main.load()
    }
    
    @IBAction func buttonReload(_ sender: Any) {
        self.loadData()
        
        guard !Reachability.isConnectedToInternet else { return }
        self.showDialog(message: "You have not connected to internet. Using local data.")

        self.hideLoading()
    }
    
    func loadData() {
        guard Reachability.isConnectedToInternet else { return self.loadLocalData() }
        self.showLoading()
        
        Firebase.manager.loadKMeansVectors { result in
            self.hideLoading()
            
            Vector.kMeanVectors = result
            self.usersLabel.text = "You have \(Vector.kMeanVectors.count / Constant.clusteringNumberOfK) students."
            
            /// Save `local data`
            try? Realm.main.write { Realm.main.deleteAll() }
            for vector in Vector.kMeanVectors { Vector.save(vector) }
        }
    }
    
    private func loadLocalData() {
        Vector.kMeanVectors = []
        
        let result = Realm.main.objects(SavedVector.self)
        
        for vector in result {
            let vector = Vector(name: vector.name, vector: vector.vector.asVector(), distance: vector.distance)
            Vector.kMeanVectors.append(vector)
        }
        
        self.usersLabel.text = "You have \(Vector.kMeanVectors.count / Constant.clusteringNumberOfK) students."
    }
}
