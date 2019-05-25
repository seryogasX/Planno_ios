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
        let createQuery = """
            CREATE TABLE IF NOT EXISTS ProfileAuthor (ProfileEmail varchar(50) primary key, ProfilePassword varchar(32), ProfileID integer);
            CREATE TABLE IF NOT EXISTS ProfileInformation (ProfileID integer primary key, ProfileName varchar(50), ProfileSecondName varchar(50), ProfileYear varchar(10));
            CREATE TABLE IF NOT EXISTS Desks (DeskID integer primary key, DeskName varchar(50), DeskText varchar(255), ProfileID integer);
            CREATE TABLE IF NOT EXISTS Cards (CardID integer primary key, DeskID integer, CardName varchar(50), CardDescription varchar(255), CardCreationDate varchar(10), CardDeadlineDate varchar(10), CardStatus integer);
            CREATE TABLE IF NOT EXISTS AccessTable (ProfileID integer, DeskID integer, IsOwner integer);
            CREATE TABLE IF NOT EXISTS Marks (CardID integer, MarkID integer);
            CREATE TABLE IF NOT EXISTS MarkList (MarkID integer primary key, MarkDescription varchar(255));
            """
        if sqlite3_exec(db, createQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating Tables!")
            return false
        }
        sqlite3_finalize(statement)
        return true
    }
    
    public func findUser(_ email : String, _ password : String?) -> Bool {
        var findUserQuery = "SELECT * from ProfileAuthor where ProfileEmail=?"
        if let pass = password {
            findUserQuery += " and ProfilePassword=?"
        }
        if sqlite3_prepare_v2(db, findUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, email, -1, nil)
            sqlite3_bind_text(statement, 2, password, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully find user.")
            } else {
                print("Could not find user.")
            }
        }
        else {
            print("Ошибка базы данных! Не удалось найти пользователя с таким логином и паролем!")
            return false
        }
        sqlite3_finalize(statement)
        return true
    }
    
    public func addNewUser(_ user: User) -> Bool {
        let newProfileIDQuery = "SELECT MAX(ProfileID) FROM ProfileInformation"
        if sqlite3_prepare_v2(db, newProfileIDQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно получить максимальный ID!")
            return false
        }
        user.id = sqlite3_column_int(statement, 0) + 1
        var addNewUserQuery = "INSERT INTO ProfileInformation(ProfileID, ProfileName, ProfileSecondName, ProfileYear) VALUES (?, ?, ?, ?);"
        if sqlite3_prepare_v2(db, addNewUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, user.id)
            sqlite3_bind_text(statement, 2, user.name, -1, nil)
            sqlite3_bind_text(statement, 3, user.surname, -1, nil)
            sqlite3_bind_text(statement, 4, user.birthDate, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        }
        else {
            print("Ошибка базы данных! Невозможно добавить нового пользователя!")
            return false
        }
        
        addNewUserQuery = "INSERT INTO ProfileAuthor(ProfileEmail, ProfilePassword, ProfileID) VALUES(\(user.email), \(user.password), \(user.id))"
        if sqlite3_exec(db, addNewUserQuery, nil, nil, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно добавить нового пользователя в таблицу аутентификации!")
            return false
        }
        sqlite3_finalize(statement)
        return true
    }
    
    public func addNewDesk(_ desk: Desk) -> Bool {
        let addNewDeskQuery = "INSERT INTO Desks(DeskID, DeskName, DeskText, ProfileID) VALUES(\(desk.id), \(desk.name), \(desk.text ?? ""), \(desk.profileID))"
        if sqlite3_exec(db, addNewDeskQuery, nil, nil, nil) != SQLITE_OK {
            print("Ошибка при добавлении доски!")
            return false
        }
        sqlite3_finalize(statement)
        return true
    }
    
    public func getDesksList(profileID : Int32) -> [Desk] {
        
        var list : [Desk] = []
        var deskIDList : [Int32] = []
        guard profileID > 0 else {
            return list
        }
        var getDesksQuery = "SELECT DeskID FROM AccessTable WHERE ProfileID=\(profileID)"
        if sqlite3_prepare_v2(db, getDesksQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Не удалось загрузить список доступа к досокам!")
            return list
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            deskIDList.append(id)
        }
        
        for deskID in deskIDList {
            getDesksQuery = "SELECT * FROM Desks WHERE DeskID=\(deskID)"
            if sqlite3_prepare_v2(db, getDesksQuery, -1, &statement, nil) != SQLITE_OK {
                print("Ошибка базы данных! Не удалось загрузить список досок!")
                return list
            }
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let name = sqlite3_column_text(statement, 1)
                let text = sqlite3_column_text(statement, 2)
                list.append(Desk(id, String(cString: name!), String(cString: text!), profileID))
            }
        }
        sqlite3_finalize(statement)
        return list
    }
    
    public func getUserID(email: String, password: String) -> Int32 {
        let getUserIDQuery = "SELECT * FROM ProfileAuthor WHERE ProfileEmail=\(email) AND ProfilePassword=\(password)"
        if sqlite3_prepare_v2(db, getUserIDQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Ошибка при получении ID пользователя!")
            return -1
        }
        let id = sqlite3_column_int(statement, 0)
        if id != 0 {
            sqlite3_finalize(statement)
            return id
        }
        else {
            return -1
        }
    }
    
    public func getCardsList(deskid: Int) -> [Card] {
        var list: [Card] = []
        guard deskid > 0 else {
            return list
        }
        let getDesksQuery = "SELECT * FROM Cards WHERE DeskID=\(deskid)"
        if sqlite3_prepare_v2(db, getDesksQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Не удалось загрузить список досок!")
            return list
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let name = sqlite3_column_text(statement, 1)
            let description = sqlite3_column_text(statement, 2)
            let creationDate = sqlite3_column_text(statement, 3)
            let deadlineDate = sqlite3_column_text(statement, 4)
            let cardStatus = sqlite3_column_int(statement, 5)
            list.append(Card(id, String(cString: name!), String(cString: description!),
                             String(cString: creationDate!), String(cString: deadlineDate!),
                             cardStatus == 1 ? true : false))
        }
        sqlite3_finalize(statement)
        return list
    }
    
    public func getCardMarks(_ cardID: Int32) -> [Mark] {
        var list : [Mark] = []
        let getCardMarksList = "SELECT Marks.MarkID, MarkList.MarkDescription FROM Marks JOIN MarkList ON Marks.MarkID=MarkList.MarkID WHERE CardID=\(cardID)"
        if sqlite3_prepare_v2(db, getCardMarksList, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Не удалось получить список меток для доски!")
            return []
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            list.append(Mark(sqlite3_column_int(statement, 0), String(cString: sqlite3_column_text(statement, 1))))
        }
        sqlite3_finalize(statement)
        return list
    }
    
    public func getAllMarksList() -> [Mark] {
        var list : [Mark] = []
        if sqlite3_prepare_v2(db, "SELECT * FROM MarkList", -1, &statement, nil) != SQLITE_OK {
            
            print("Ошибка базы данных! Не удалось получить список всех меток!")
            return []
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            list.append(Mark(sqlite3_column_int(statement, 0), String(cString: sqlite3_column_text(statement, 1))))
        }
        sqlite3_finalize(statement)
        return list
    }
    
    public func deleteDesk(_ deskID: Int32) -> Bool {
        var deleteDeskQuery = "DELETE FROM Desks WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successful delete!")
            }
            else {
                print("Ошибка при удалении доски!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось удалить доску!")
            return false
        }
        
        deleteDeskQuery = "DELETE FROM Cards WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successful delete!")
            }
            else {
                print("Ошибка при удалении доски!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось удалить доску!")
            return false
        }
        
        deleteDeskQuery = "DELETE FROM AccessTable WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successful delete!")
            }
            else {
                print("Ошибка при удалении доски!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось удалить доску!")
            return false
        }
        return true
    }
    
    public func deleteCard(_ cardID: Int32) -> Bool {
        var deleteDeskQuery = "DELETE FROM Cards WHERE CardID=\(cardID)"
        if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successful delete!")
            }
            else {
                print("Ошибка при удалении карты!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось удалить карту!")
            return false
        }
        
        deleteDeskQuery = "DELETE FROM Marks WHERE CardID=\(cardID)"
        if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successful delete!")
            }
            else {
                print("Ошибка при удалении карты!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось удалить карту!")
            return false
        }
        return true
    }
    
    public func updateDeskName(_ deskID: Int32, _ newName: String) -> Bool {
        let updatDeskNameQuery = "UPDATE Desks SET DeskName=\(newName) WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, updatDeskNameQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Succesful update!")
            }
            else {
                print("Ошибка при обновлении имени доски!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось обновить имя доски!")
            return false
        }
        return true
    }
    
    public func updateCardName(_ cardID: Int32, _ newName: String) -> Bool {
        let updatDeskNameQuery = "UPDATE Cards SET CardName=\(newName) WHERE CardID=\(cardID)"
        if sqlite3_prepare_v2(db, updatDeskNameQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Succesful update!")
            }
            else {
                print("Ошибка при обновлении имени карты!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось обновить имя карты!")
            return false
        }
        return true
    }
    
    public func updateDeskDescription(_ deskID: Int32, _ newDesc: String) -> Bool {
        let updatDeskDescQuery = "UPDATE Desks SET DeskText=\(newDesc) WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, updatDeskDescQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Succesful update!")
            }
            else {
                print("Ошибка при обновлении описания доски!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось обновить описание доски!")
            return false
        }
        return true
    }
    
    public func updateCardDescription(_ cardID: Int32, _ newDesc: String) -> Bool {
        let updatCardDescQuery = "UPDATE Cards SET CardDescription=\(newDesc) WHERE CardID=\(cardID)"
        if sqlite3_prepare_v2(db, updatCardDescQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Succesful update!")
            }
            else {
                print("Ошибка при обновлении описания карты!")
                return false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось обновить описание карты!")
            return false
        }
        return true
    }
    
    public func addNewUserToDesk(_ deskID: Int32, _ newUserID: Int32, _ isOwner: Bool) -> Bool {
        let addNewUserToDesk = "INSERT INTO AccessTable(ProfileID, DeskID, isOwner) VALUES(\(newUserID), \(deskID), \(isOwner))"
        if sqlite3_exec(db, addNewUserToDesk, nil, nil, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно добавить нового пользователя к доске!")
            return false
        }
        return true
    }
}
