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
    @IBOutlet weak var usernameTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    var username : String = ""
    var password : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        if usernameTextField.text!.isEmpty {
            showError(controller: self, message: "Введите имя пользователя!")
            return
        }
        if passwordTextField.text!.isEmpty {
            showError(controller: self, message: "Введите пароль!")
            return
        }
        username = usernameTextField.text!
        password = passwordTextField.text!
        if db.findUser(username, password) {
            self.performSegue(withIdentifier: "MainVCtoMenuVC", sender: self)
        }
        else {
            showError(controller : self, message: "Неправильный логин или пароль!");
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainVCtoMenuVC" {
            let tabVCs = segue.destination as! UITabBarController
            let nav = tabVCs.viewControllers![0] as! UINavigationController
            let desksVC = nav.topViewController as! DesksViewController
            desksVC.username = username
        }
    }
}
