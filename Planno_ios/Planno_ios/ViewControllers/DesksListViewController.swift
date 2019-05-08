//
//  DesksListViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 08/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class DesksListViewController : UITabBarController {
    
    var username : String = ""
    let db = Database.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var deskList = db.getDesksList(username : username)
    }
    
}
