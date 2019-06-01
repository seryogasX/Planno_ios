//
//  CardsViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 24/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class CardsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db = Database.shared
    var deskID : Int32 = -1
    var cardList: [Card] = []
//    var selectedIndex = -1
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardList = db.getCardsList(deskID: deskID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cardList = db.getCardsList(deskID: deskID)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("BLET!!!")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardIdentifier", for: indexPath)
        cell.textLabel?.text = cardList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //selectedIndex = -1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CardsToDeskSettings" {
            if let deskSettingsVC = segue.destination as? DeskSettingsViewController {
                deskSettingsVC.deskID = deskID
            }
        }
        else if segue.identifier == "CardsToNewCard" {
            if let newCardVC = segue.destination as? NewCardViewController {
                newCardVC.deskID = deskID
            }
        }
        else if segue.identifier == "CardsToCardSettings" {
            if let cardSettingsVC = segue.destination as? CardSettingsViewController {
                let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
                cardSettingsVC.cardID = cardList[selectedIndex!].id
            }
        }
    }
}
