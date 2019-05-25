//
//  Users.swift
//  Planno_ios
//
//  Created by Сергей Петров on 08/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation

struct User {
    let id : Int32
    let username : String
    let password : String
    let email : String
}

struct Desk {
    let id : Int32
    let name : String
    let text : String?
    let profileID : Int32
    
    init (_ newID_: Int32, _ newName_ : String, _ newText_ : String?, _ profileID_: Int32) {
        id = newID_
        name = newName_
        text = newText_
        profileID = profileID_
    }
}

struct Mark {
    let id : Int32
    let description: String
    
    init(_ id_: Int32, _ description_: String) {
        id = id_
        description = description_
    }
}

struct Card {
    let id : Int32
    let name : String
    let description : String
    let creationDate : String
    let deadLineDate : String?
    let cardStatus : Bool
    var marksList: [Mark]
    
    init (_ id_: Int32, _ name_: String, _ description_: String, _ creationDate_: String, _ deadlineDate_: String?, _ cardStatus_: Bool) {
        id = id_
        name = name_
        description = description_
        creationDate = creationDate_
        deadLineDate = deadlineDate_
        cardStatus = cardStatus_
        marksList = []
    }
}
