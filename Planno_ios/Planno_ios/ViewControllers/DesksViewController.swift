//
//  DesksViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 23/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit


class DesksViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var profileID : Int32 = -1
    var db = Database.shared
    var desksList : [Desk] = []
    var selectedIndex = -1
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desksList = db.getDesksList(profileID: profileID)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return desksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardIdentifier", for: indexPath)
        cell.textLabel?.text = desksList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndex = -1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DesksToAccountSettings" {
            if let accountSettingsVC = segue.destination as? AccountSettingsViewController {
                accountSettingsVC.profileID = profileID
            }
        }
        else if segue.identifier == "DesksToNewDesk" {
            if let newDeskVC = segue.destination as? NewDeskViewController {
                newDeskVC.profileID = profileID
            }
        }
        else if segue.identifier == "DesksToCards" {
            if let cardsVC = segue.destination as? CardsViewController{
                cardsVC.deskID = desksList[selectedIndex].id
            }
        }
    }
}
