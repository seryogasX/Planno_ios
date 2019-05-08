//
//  SignUpViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 08/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController : UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let db = Database.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        if usernameTextField.text?.isEmpty ?? true {
            showError(controller: self, message: "Введите имя")
            return
        }
        if passwordTextField.text?.isEmpty ?? true {
            showError(controller: self, message: "Введите пароль!")
            return
        }
        if emailTextField.text?.isEmpty ?? true {
            showError(controller: self, message: "Введите email!")
            return
        }
        
        let username = usernameTextField.text!
        let name = nameTextField.text!
        let surname = surnameTextField.text!
        let password = passwordTextField.text!
        let repeat_password = repeatPasswordTextField.text!
        let email = emailTextField.text!
        
        if password != repeat_password {
            showError(controller: self, message: "Пароли не совпадают!")
            return
        }
        
        if db.findUser(username, password) {
            print("OK!")
        }
        else {
            print("NE OK!")
        }
    }
}
