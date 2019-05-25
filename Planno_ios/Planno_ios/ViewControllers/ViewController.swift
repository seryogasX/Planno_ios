//
//  ViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 01/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let db = Database.shared
    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        if checkInputData() {
            if db.findUser(emailTextField.text!, passwordTextField.text!) {
                self.performSegue(withIdentifier: "LogInToDesks", sender: self)
            }
            else {
                showError(controller : self, message: "Неправильный логин или пароль!");
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogInToDesks" {
            if let desksVC = segue.destination as? DesksViewController {
                let profileID = db.getUserID(email: emailTextField.text!, password: passwordTextField.text!)
                if profileID != -1 {
                    desksVC.profileID = profileID
                }
            }
        }
    }
    
    func checkInputData() -> Bool {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showError(controller: self, message: "Введите имя пользователя!")
            return false
        }
        return true
    }
}
