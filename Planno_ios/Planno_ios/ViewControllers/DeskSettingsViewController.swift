//
//  DeskSettignsViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 31/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class DeskSettingsViewController: UIViewController {
    
    var deskID: Int32 = -1
    var db = Database.shared
    
    @IBOutlet weak var nameTextEdit: UITextField!
    @IBOutlet weak var descriptionTextEdit: UITextField!
    @IBOutlet weak var guestEmailTextEdit: UITextField!
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        if db.updateDesk(deskID: deskID, name: nameTextEdit.text, description: descriptionTextEdit.text, guestEmail: guestEmailTextEdit.text) {
                showMessage(controller: self, message: "Доска обновлена!")
        }
        else {
            showError(controller: self, message: "Доска не обновлена!")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
