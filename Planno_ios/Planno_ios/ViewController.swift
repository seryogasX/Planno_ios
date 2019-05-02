//
//  ViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 01/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import UIKit
//import SQLite3

class ViewController: UIViewController {

    let db = Database.shared
    @IBOutlet weak var usernameTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if db.findUser(username, password) {
            print("OK")
        }
        else {
            showError(controller : self, message: "Неправильный логин или пароль");
        }
    }
    
}

func showError(controller : UIViewController, message : String) {
    let alertController = UIAlertController(
        title: "Ошибка",
        message: message,
        preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction (
        title: "OK",
        style: UIAlertAction.Style.default,
        handler: nil))
    controller.present(alertController, animated: true, completion: nil)
}


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
        
        if !db.findUser(username, password)
    }
    
}

