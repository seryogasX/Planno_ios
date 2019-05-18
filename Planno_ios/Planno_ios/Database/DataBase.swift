//
//  DataBase.swift
//  Planno_ios
//
//  Created by Сергей Петров on 02/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import SQLite3

class Database {
    
    let dbUrl : URL
    var db : OpaquePointer?
    
    
    static let shared = Database()
    
    private init() {
        dbUrl = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false).appendingPathComponent("Database.sqlite")

        if sqlite3_open(dbUrl.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
        if initTables() {
            print("OK!")
        }
    }
    
    private func initTables() -> Bool {
        let createTableQuery = "CREATE TABLE IF NOT EXISTS USERS (ID, NAME, ))"
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return false
        }
        return true
    }
    
    public func findUser(_ username : String, _ password : String?) -> Bool {
        var findUserQuery = "SELECT * from Users where username=\(username)"
        if let pass = password {
            findUserQuery += "and password=\(pass)"
        }
        return true
    }
    
    public func addNewUser(_ username : String, _ name : String, _ password : String, _ email : String) -> Bool {
        
        return true
    }
    
    public func getDesksList(username : String) -> [Desk] {
        var list : [Desk] = []
        let getDesksQuery = "SELECT * FROM Desks where owner=\(username)"
        
        return list
    }
}
