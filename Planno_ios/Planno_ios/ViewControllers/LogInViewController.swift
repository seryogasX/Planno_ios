//
//  ViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 01/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

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
        if segue.identifier == "LogInToDesks" && checkInputData() {
            if db.findUser(emailTextField.text!, passwordTextField.text!) {
                if let desksVC = segue.destination as? DesksViewController {
                    let profileID = db.getUserID(email: emailTextField.text!, password: passwordTextField.text!)
                    if profileID != -1 {
                        desksVC.profileID = profileID
                    }
                }
            }
            else {
                showError(controller : self, message: "Неправильный логин или пароль!");
            }
            
        }
    }
    
    func checkInputData() -> Bool {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showError(controller: self, message: "Введите имя пользователя и пароль!")
            return false
        }
        return true
    }
}
