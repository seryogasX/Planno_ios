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
    }
    
    func createTableQuery() -> Bool {
        let createTableQuery = "CREATE TABLE IF NOT EXISTS"
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return false
        }
        return true
    }
    
    func findUser(_ username : String, _ password : String?) -> Bool {
        var finduserQuery = "SELECT * from Users where username=\(username)"
        if (password! as String?) != nil {
            finduserQuery += " and password=\(password)"
        }
        
        
        return true
    }
}
