//
//  CardSettingsViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 31/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class CardSettingsViewController: UIViewController {
    
    var cardID: Int32 = -1
    var db = Database.shared
    @IBOutlet weak var nameTextEdit: UITextField!
    @IBOutlet weak var descriptionTextEdit: UITextField!
    @IBOutlet weak var dayTextEdit: UITextField!
    @IBOutlet weak var monthTextEdit: UITextField!
    @IBOutlet weak var yearTextEdit: UITextField!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func confirmButtonClicked(_ sender: Any) {
        if db.updateCard(cardID: cardID, name: nameTextEdit.text!.isEmpty ? nil : nameTextEdit.text!, description: descriptionTextEdit.text!.isEmpty ? nil : descriptionTextEdit.text!, deadLineDate: dayTextEdit.text! + "-" + monthTextEdit.text! + "-" + yearTextEdit.text!, cardStatus: statusSwitch!.isOn ? 1 : 0) {
            
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            showError(controller: self, message: "Что-то пошло не так!")
        }
    }
    
    @IBAction func DeleteCardButtonClicked(_ sender: Any) {
        if db.deleteCard(cardID) {
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            showError(controller: self, message: "Что-то пошло не так!")
        }
    }
}
