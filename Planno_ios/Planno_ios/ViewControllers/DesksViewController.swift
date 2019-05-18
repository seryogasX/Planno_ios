//
//  DesksViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 08/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class DesksViewController : UIViewController {
    
    @IBOutlet weak var elemStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var username : String = ""
    let db = Database.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var deskList = db.getDesksList(username : username)
        print(username)
    }
}