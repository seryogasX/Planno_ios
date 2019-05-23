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
    var statement : OpaquePointer?
    
    
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
    
    public func findUser(_ email : String, _ password : String?) -> Bool {
        var findUserQuery = "SELECT * from Users where username=\(email)"
        if let pass = password {
            findUserQuery += "and password=\(pass)"
        }
        return true
    }
    
    public func addNewUser(email : String, name : String, surname: String,  password : String, year : String) -> Bool {
        var addNewUserQuery = "INSERT INTO ProfileInformation(ProfileName, ProfileSecondName, ProfileYear) VALUES (\(name), \(surname), \(year))"
        if sqlite3_exec(db, addNewUserQuery, nil, nil, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно добавить нового пользователя!")
            return false
        }
        
        let newProfileIDQuery = "SELECT MAX(ProfileID) FROM ProfileInformation"
        if sqlite3_prepare_v2(db, newProfileIDQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно получить максимальный ID!")
            return false
        }
        let id = sqlite3_column_int(statement, 0)
        
        addNewUserQuery = "INSERT INTO ProfileAuthor(ProfileEmail, ProfilePassword, ProfileID) VALUES(\(email), \(password), \(id))"
        if sqlite3_exec(db, addNewUserQuery, nil, nil, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно добавить нового пользователя в таблицу аутентификации!")
            return false
        }
        return true
    }
    
    public func getDesksList(username : String) -> [Desk] {
        var list : [Desk] = []
        let getDesksQuery = "SELECT * FROM Desks where owner=\(username)"
        
        return list
    }
}
