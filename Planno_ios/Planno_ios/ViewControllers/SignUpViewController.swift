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
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let db = Database.shared
    var status = "CREATE"
    var profileID: Int32 = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if status == "CREATE" {
            actionButton.setTitle("Sign up", for: .normal)
            cancelButton.isHidden = true
        }
        else {
            actionButton.setTitle("Confirm settings", for: .normal)
            actionButton.setTitleColor(UIColor.red, for: .normal)
            cancelButton.isHidden = false
            cancelButton.setTitle("Delete account", for: .normal)
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
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        if checkInputData() {
            let userID = db.findUser(email: emailTextField.text!, password: passwordTextField.text!)
            if userID != -1 {
                showError(controller: self, message: "Пользователь с такой почтой уже есть!")
                return
            }
            if status == "CREATE" {
                var user = User(userID, nameTextField.text!, surnameTextField.text!, emailTextField.text!, passwordTextField.text!, dayTextField.text! + "." + monthTextField.text! + "." + yearTextField.text!)
                if db.addNewUser(user) {
                    self.performSegue(withIdentifier: "SignUpToDesks", sender: self)
                }
                else {
                    print("Что-то пошло не так! Не удалось добавить пользователя!")
                    return
                }
            }
            else {
                var user = User(profileID, nameTextField.text!, surnameTextField.text!, emailTextField.text!, passwordTextField.text!, dayTextField.text! + "." + monthTextField.text! + "." + yearTextField.text!)
                if db.updateUser(user) {
                    self.performSegue(withIdentifier: "SignUpToDesks", sender: self)
                }
                else {
                    print("Что-то пошло не так! Не удалось изменить пользователя!")
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpToDesks" {
            if let desksVC = segue.destination as? DesksViewController {
                desksVC.profileID = profileID
            }
        }
        else if segue.identifier == "SignUpToLaunch" {
            if let _ = segue.destination as? LaunchViewController {
                
            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        if status == "CREATE" {
            self.performSegue(withIdentifier: "SignUpToDesks", sender: self)
        } else {
            if db.deleteUser(ID: profileID) {
                self.performSegue(withIdentifier: "SignUpToLaunch", sender: self)
            }
            else {
                showError(controller: self, message: "Что-то пошло не так! Не удалось удалить пользователя!")
            }
        }
    }
}
