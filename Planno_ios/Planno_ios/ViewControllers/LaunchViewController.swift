//
//  LaunchViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 23/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func SignInButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "LaunchToLogin", sender: self)
    }
    
}
