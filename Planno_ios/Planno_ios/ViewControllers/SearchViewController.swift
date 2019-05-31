//
//  SearchViewController.swift
//  Planno_ios
//
//  Created by Сергей Петров on 24/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db = Database.shared
    var profileID: Int32 = -1
    var resultCount: Int = 0
    var cardList: [Card] = []
    @IBOutlet weak var CardWordTextEdit: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCardIdentifier", for: indexPath)
        return cell
    }
    
    @IBAction func findButtonClicked(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToDesks" {
            if let desksVC = segue.destination as? DesksViewController {
                desksVC.profileID = profileID
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultCount = 0
    }
}
