//
//  NewDeskViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 25/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class NewDeskViewController : UIViewController {
    
    var db = Database.shared
    var profileID: Int32 = -1
    
    @IBOutlet weak var titleTextEdit: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewDeskToDesks" {
            if titleTextEdit.text!.isEmpty {
                showError(controller: self, message: "Введите заголовок доски!")
                return
            }
            if db.addNewDesk(Desk(-1, titleTextEdit.text!, descriptionTextView.text!, profileID)) {
                _ = navigationController?.popViewController(animated: true)
            }
            else {
                showError(controller: self, message: "Что-то пошло не так!")
            }
        }
    }
}
