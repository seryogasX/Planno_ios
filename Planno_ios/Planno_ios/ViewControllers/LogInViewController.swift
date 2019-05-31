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
    var password : String = ""
    var profileID: Int32 = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogInToDesks" && checkInputData() {
            //password = "\(SHA3.shared.getHash(passwordTextField.text!))"
            password = passwordTextField.text!
            profileID = db.findUser(email: emailTextField.text!, password: password)
            guard profileID > -1 else {
                showError(controller : self, message: "Неправильный логин или пароль!");
                return
            }
            if let navVC = segue.destination as? UINavigationController {
                let desksVC = navVC.topViewController as! DesksViewController
                desksVC.profileID = profileID
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
