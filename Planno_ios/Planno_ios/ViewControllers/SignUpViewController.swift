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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    let db = Database.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        if checkInputData() {
            if db.addNewUser(email: emailTextField.text!, name : nameTextField.text!, surname: surnameTextField.text!, password: passwordTextField.text!, year: yearTextField.text!) {
                
                
            }
        }
    }
    
    func checkInputData() -> Bool {
        if emailTextField.text!.isEmpty || nameTextField.text!.isEmpty || surnameTextField.text!.isEmpty || dayTextField.text!.isEmpty || monthTextField.text!.isEmpty || yearTextField.text!.isEmpty || passwordTextField.text!.isEmpty || repeatPasswordTextField.text!.isEmpty {
            
            showError(controller: self, message: "Не все данные введены!")
            return false
        }
        
        guard isDateCorrect(day: dayTextField.text!, month : monthTextField.text!, year : yearTextField.text!) else {
            showError(controller: self, message: "Неправильно введена Дата!")
            return false
        }
        
        if passwordTextField.text! != repeatPasswordTextField.text! {
            showError(controller: self, message: "Пароли не совпадают!")
            return false
        }
        return true
    }
    
    func isDateCorrect(day : String, month : String, year : String) -> Bool {
        guard let d = UInt(day), let m = UInt(month), let y = UInt(year), d >= 0, d <= 31, m >= 0, m <= 12, y >= 1900, y <= 2019 else {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpToDesks" {
            if let desksVC = segue.destination as? DesksViewController {
                desksVC.email = emailTextField.text!
            }
        }
    }
}
