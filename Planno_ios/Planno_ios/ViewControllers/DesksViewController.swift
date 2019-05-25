//
//  DesksViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 23/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit


class DesksViewController : UIViewController {
    
    var profileID : Int32 = -1
    var db = Database.shared
    var desksList : [Desk]?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desksList = db.getDesksList(profileID: profileID)
        
    }
}
