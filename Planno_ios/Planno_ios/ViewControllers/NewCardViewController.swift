//
//  NewCardViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 31/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class NewCardViewController: UIViewController {
    
    var db = Database.shared
    var deskID: Int32 = -1
    @IBOutlet weak var nameTextEdit: UITextField!
    @IBOutlet weak var descriptionTextEdit: UITextField!
    @IBOutlet weak var dayTextEdit: UITextField!
    @IBOutlet weak var monthTextEdit: UITextField!
    @IBOutlet weak var yearTextEdit: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewCardToCards" {
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "dd-MM-yyyy"
            let formattedDate = format.string(from: date)
            let card = Card(-1, deskID, nameTextEdit.text!, descriptionTextEdit.text!, formattedDate, dayTextEdit.text! + "-" + monthTextEdit.text! + "-" + yearTextEdit.text!, 0)
            if db.addNewCard(card) {
                if let cardsVC = segue.destination as? CardsViewController{
                    cardsVC.deskID = deskID
                }
            }
            else {
                showError(controller: self, message: "Не удалось добавить карту!")
            }
        }
    }
}
