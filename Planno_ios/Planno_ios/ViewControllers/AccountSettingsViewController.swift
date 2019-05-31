//
//  AccountSettingsViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 31/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class AccountSettingsViewController: UIViewController {
    
    var profileID: Int32 = -1
    var db = Database.shared
    @IBOutlet weak var emailTextEdit: UITextField!
    @IBOutlet weak var nameTextEdit: UITextField!
    @IBOutlet weak var surnameTextEdit: UITextField!
    @IBOutlet weak var newPasswordTextEdit: UITextField!
    @IBOutlet weak var repeatNewPasswordTextEdit: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        if newPasswordTextEdit.text! != repeatNewPasswordTextEdit.text! {
            showError(controller: self, message: "Пароли не совпадают!")
            return
        }
        let email = emailTextEdit.text!
        let name = nameTextEdit.text!
        let surname = surnameTextEdit.text!
        let password = newPasswordTextEdit.text!
        if db.updateUser(email: email, name: name, surname: surname, password: password) {
            
            showMessage(controller: self, message: "Данные аккаунта изменены!")
        }
        else {
            showError(controller: self, message: "Данные некорректны!")
        }
    }
    
}
