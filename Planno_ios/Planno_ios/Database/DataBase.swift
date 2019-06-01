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
            CREATE TABLE IF NOT EXISTS ProfileInformation (ProfileID integer primary key, ProfileName varchar(50), ProfileSecondName varchar(50), ProfileYear varchar(10));
            CREATE TABLE IF NOT EXISTS ProfileAuthor (ProfileEmail varchar(50), ProfilePassword varchar(256), ProfileID integer, foreign key (ProfileID) references ProfileInformation(ProfileID));
            CREATE TABLE IF NOT EXISTS Desks (DeskID integer primary key, DeskName varchar(50), DeskText varchar(255), ProfileID integer, foreign key(ProfileID) references ProfileInformation(ProfileID));
            CREATE TABLE IF NOT EXISTS AccessTable (ProfileID integer, DeskID integer, IsOwner integer, foreign key (ProfileID) references ProfileInformation(ProfileID), foreign key(DeskID) references Desks(DeskID));
            CREATE TABLE IF NOT EXISTS MarkList (MarkID integer primary key, MarkDescription varchar(255));
            CREATE TABLE IF NOT EXISTS Cards (CardID integer primary key, DeskID integer, CardName varchar(50), CardDescription varchar(255), CardCreationDate varchar(10), CardDeadLineDate varchar(10), CardStatus integer, foreign key(DeskID) references Desks(DeskID));
            CREATE TABLE IF NOT EXISTS Marks (CardID integer, MarkID integer, foreign key(CardID) references Cards(CardID), foreign key(MarkID) references MarkList(MarkID));
            """
//        let createQuery = """
//            DROP TABLE IF EXISTS Marks;
//            DROP TABLE IF EXISTS Cards;
//            DROP TABLE IF EXISTS MarkList;
//            DROP TABLE IF EXISTS AccessTable;
//            DROP TABLE IF EXISTS Desks;
//            DROP TABLE IF EXISTS ProfileAuthor;
//            DROP TABLE IF EXISTS ProfileInformation;
//            """

        if sqlite3_exec(db, createQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating Tables!")
            return false
        }
        sqlite3_finalize(statement)
        print("OK!!!")
        return true
    }
    
    public func findUser(email : String, password: String?) -> Int32 {
        var findUserQuery = "SELECT * from ProfileAuthor where ProfileEmail=?"
        if let _ = password {
            findUserQuery += " and ProfilePassword=?"
        }
        var profileID: Int32 = -1
        if sqlite3_prepare_v2(db, findUserQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, email, -1, nil)
            if let _ = password {
                sqlite3_bind_text(statement, 2, password, -1, nil)
            }
            if sqlite3_step(statement) == SQLITE_ROW {
                profileID = sqlite3_column_int(statement, 2)
                print("Нашли пользователя! ID=\(profileID)")
            }
            else {
                print("Пользователь не найден!")
            }
        }
        else {
            print("Ошибка базы данных!")
        }
        
        sqlite3_finalize(statement)
        return profileID
    }
    
    public func addNewUser(_ user: User) -> Bool {
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK {
            let newProfileIDQuery = "SELECT MAX(ProfileID) FROM ProfileInformation"
            if sqlite3_prepare_v2(db, newProfileIDQuery, -1, &statement, nil) != SQLITE_OK {
                print("Ошибка базы данных! Невозможно получить максимальный ID!")
                completeTransaction = false
                
            }
            if sqlite3_step(statement) == SQLITE_ROW {
                user.id = sqlite3_column_int(statement, 0) + 1
            }
            else {
                user.id = 1
            }
            var addNewUserQuery = "INSERT INTO ProfileInformation(ProfileID, ProfileName, ProfileSecondName, ProfileYear) VALUES (?, ?, ?, ?);"
            if sqlite3_prepare_v2(db, addNewUserQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, user.id)
                sqlite3_bind_text(statement, 2, user.name, -1, nil)
                sqlite3_bind_text(statement, 3, user.surname, -1, nil)
                sqlite3_bind_text(statement, 4, user.birthDate, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Добавили нового пользователя в ProfileInformation!")
                } else {
                    print("Не удалось добавить нового пользователя в ProfileInformation!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Невозможно добавить нового пользователя в ProfileInformation!")
                completeTransaction = false
            }
            
            addNewUserQuery = "INSERT INTO ProfileAuthor(ProfileEmail, ProfilePassword, ProfileID) VALUES(?, ?, ?)"
            if sqlite3_prepare_v2(db, addNewUserQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, user.email, -1, nil)
                sqlite3_bind_text(statement, 2, user.password, -1, nil)
                sqlite3_bind_int(statement, 3, user.id)
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Добавили нового пользователя в ProfileAuthor!")
                } else {
                    print("Не удалось добавить нового пользователя в ProfileAuthor!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Невозможно добавить нового пользователя в ProfileAuthor!")
                completeTransaction = false
            }
            
            if completeTransaction {
                if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                    print("Транзация завершилась успешно! Пользователь добавлен!")
                }
                else {
                    print("Транзация не завершилась успешно! Пользователь не добавлен!")
                    completeTransaction = false
                }
            }
            else if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Откат транзации завершен!")
            }
            else {
                print("Ошибка отката транзации!")
            }
            sqlite3_finalize(statement)
            return completeTransaction
        }
        else {
            print("Что-то пошло не так!")
            return false
        }
    }
    
    public func addNewDesk(_ desk: Desk) -> Bool {
        let newDeskIDQuery = "SELECT MAX(DeskID) FROM Desks"
        if sqlite3_prepare_v2(db, newDeskIDQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Невозможно получить максимальный ID!")
            return false
        }
        if sqlite3_step(statement) == SQLITE_ROW {
            desk.id = sqlite3_column_int(statement, 0) + 1
        }
        else {
            desk.id = 1
        }
        
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK {
            var addNewDeskQuery = "INSERT INTO Desks(DeskID, DeskName, DeskText, ProfileID) VALUES(?, ?, ?, ?)"
            if sqlite3_prepare_v2(db, addNewDeskQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, desk.id)
                sqlite3_bind_text(statement, 2, desk.name, -1, nil)
                sqlite3_bind_text(statement, 3, desk.text, -1, nil)
                sqlite3_bind_int(statement, 4, desk.profileID)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска добавлена! ID=\(desk.id)")
                }
                else {
                    print("Ошибка при добавлении доски!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка при добавлении доски!")
                completeTransaction = false
            }
            
            addNewDeskQuery = "INSERT INTO AccessTable(ProfileID, DeskID, IsOwner) VALUES(?, ?, ?)"
            if sqlite3_prepare_v2(db, addNewDeskQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, desk.profileID)
                sqlite3_bind_int(statement, 2, desk.id)
                sqlite3_bind_int(statement, 3, 1)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска добавлена! ID=\(desk.id)")
                }
                else {
                    print("Ошибка при добавлении доски!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка при добавлении доски!")
                completeTransaction = false
            }
        }
        else {
            print("Не удалось добавить доску!")
            completeTransaction = false
        }
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Изменения внесены!")
            }
            else{
                print("Изменения не внесены!")
                completeTransaction = false
            }
        }
        else{
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Откат транзакции!")
            }
            else {
                print("Ошибка при откате транзакции!")
                completeTransaction = false
            }
        }
        sqlite3_finalize(statement)
        return completeTransaction
    }
    
    public func getDesksList(profileID : Int32) -> [Desk] {
        var list : [Desk] = []
        var deskIDList : [Int32] = []
        guard profileID > 0 else {
            return list
        }
        var getDesksQuery = "SELECT * FROM AccessTable WHERE ProfileID=?"
        if sqlite3_prepare_v2(db, getDesksQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, profileID)
        }
        else {
            print("Ошибка базы данных! Не удалось загрузить список доступа к доскам!")
            return list
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 1)
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
    
    public func getCardsList(deskID: Int32) -> [Card] {
        var list: [Card] = []
        guard deskID > 0 else {
            return list
        }
        let getDesksQuery = "SELECT * FROM Cards WHERE DeskID=\(deskID)"
        if sqlite3_prepare_v2(db, getDesksQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка базы данных! Не удалось загрузить список досок!")
            return list
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let deskID = sqlite3_column_int(statement, 1)
            let name = String(cString: sqlite3_column_text(statement, 2)!)
            let description = String(cString: sqlite3_column_text(statement, 3)!)
            let creationDate = String(cString: sqlite3_column_text(statement, 4)!)
            let deadlineDate = String(cString: sqlite3_column_text(statement, 5)!)
            let cardStatus = sqlite3_column_int(statement, 6)
            list.append(Card(id, deskID, name, description, creationDate, deadlineDate, cardStatus))
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
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK {
            var deleteDeskQuery = "DELETE FROM Desks WHERE DeskID=\(deskID)"
            if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска удалена из Desks!")
                }
                else {
                    print("Ошибка при удалении доски из Desks!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Не удалось удалить доску из Desks!")
                completeTransaction = false
            }
            
            deleteDeskQuery = "DELETE FROM Cards WHERE DeskID=\(deskID)"
            if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска удалена из Cards!")
                }
                else {
                    print("Ошибка при удалении доски из Cards!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Не удалось удалить доску из Cards!")
                completeTransaction = false
            }
            
            deleteDeskQuery = "DELETE FROM AccessTable WHERE DeskID=\(deskID)"
            if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска удалена из AccessTable!")
                }
                else {
                    print("Ошибка при удалении доски из AccessTable!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Не удалось удалить доску из AccessTable!")
                completeTransaction = false
            }
            
            if completeTransaction {
                if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                    print("Доска удалена!")
                }
                else {
                    print("Доска не удалена! Ошибка в COMMIT!")
                    completeTransaction = false
                }
            }
            else {
                if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                    print("Доска не удалена! Откат транзакции!")
                }
                else {
                    print("Доска не удалена! Ошибка в ROLLBACK!")
                    completeTransaction = false
                }
            }
        }
        else {
            print("Ошибка базы данных! Не удалось начать транзакцию")
            completeTransaction = false
        }
        
        return completeTransaction
    }
    
    public func deleteCard(_ cardID: Int32) -> Bool {
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK {
            var deleteDeskQuery = "DELETE FROM Cards WHERE CardID=\(cardID)"
            if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Карта удалена из Cards!")
                }
                else {
                    print("Ошибка при удалении карты из Cards!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Не удалось удалить карту!")
                completeTransaction = false
            }
            
            deleteDeskQuery = "DELETE FROM Marks WHERE CardID=\(cardID)"
            if sqlite3_prepare_v2(db, deleteDeskQuery, -1, &statement, nil) != SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Карта удалена из Marks!")
                }
                else {
                    print("Ошибка при удалении карты из Marks!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка базы данных! Не удалось удалить карту!")
                completeTransaction = false
            }
        }
        else {
            print("Ошибка базы данных! Не удалось начать транзакцию!")
            completeTransaction = false
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Карта удалена!")
            }
            else {
                print("Карта не удалена! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Карта не удалена! Откат транзакции!")
            }
            else {
                print("Карта не удалена! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
    
    public func updateDesk(deskID: Int32, name: String?, description: String?, guestEmail: String?) -> Bool {
        
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) == SQLITE_OK {
            var updateDeskQuery = "UPDATE Desks SET"
            if let _ = name, let _ = description{
                updateDeskQuery += " DeskName=?, DeskText=? "
            }
            else if let _ = name {
                updateDeskQuery += " DeskName=? "
            }
            else if let _ = description {
                updateDeskQuery += " DeskText=? "
            }
            else {
                return false
            }
            updateDeskQuery += "WHERE DeskID=?"
        
            if sqlite3_prepare_v2(db, updateDeskQuery, -1, &statement, nil) == SQLITE_OK {
                if let _ = name, let _ = description{
                    sqlite3_bind_text(statement, 1, name, -1, nil)
                    sqlite3_bind_text(statement, 2, description, -1, nil)
                    sqlite3_bind_int(statement, 3, deskID)
                }
                else if let _ = name {
                    sqlite3_bind_text(statement, 1, name, -1, nil)
                    sqlite3_bind_int(statement, 2, deskID)
                }
                else if let _ = description {
                    sqlite3_bind_text(statement, 1, description, -1, nil)
                    sqlite3_bind_int(statement, 2, deskID)
                }
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Доска обновлена!")
                }
                else {
                    print("Ошибка обновления доски!")
                    completeTransaction = false
                }
            }
            else {
                print("Ошибка обновления доски!")
                completeTransaction = false
            }
            
            if let _ = guestEmail {
                var guestID: Int32 = -1
                let getGuestIDQuery = "SELECT ProfileID FROM ProfileAuthor WHERE ProfileEmail=?"
                if sqlite3_prepare_v2(db, getGuestIDQuery, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(db, 1, guestEmail, -1, nil)
                    
                    if sqlite3_step(statement) == SQLITE_ROW {
                        guestID = sqlite3_column_int(statement, 0)
                    }
                }
                
                if guestID == -1 {
                    print("Нет такого пользователя!")
                    completeTransaction = false
                }
                else {
                    if !addNewUserToDesk(deskID, guestID, 0) {
                        print("Пользователь не добавлен!")
                        completeTransaction = false
                    }
                    else {
                        print("Пользователь добавлен!")
                    }
                }
            }
        }
        else {
            completeTransaction = false
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Доска обновлена!")
            }
            else {
                print("Доска не обновлена! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Доска не обновлена! Откат транзакции!")
            }
            else {
                print("Доска не обновлена! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
    
    
    public func updateCard(cardID: Int32, name: String?, description: String?, deadLineDate: String?, cardStatus: Int32?) -> Bool {
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN", nil, nil, nil) == SQLITE_OK {
            
            if let _ = name {
                if sqlite3_prepare_v2(db, "UPDATE Cards SET CardName=? WHERE CardID=?", -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, name!, -1, nil)
                    sqlite3_bind_int(statement, 2, cardID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
            if let _ = description {
                if sqlite3_prepare_v2(db, "UPDATE Cards SET CardDescription=? WHERE CardID=?", -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, description!, -1, nil)
                    sqlite3_bind_int(statement, 2, cardID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
            if let _ = deadLineDate {
                if sqlite3_prepare_v2(db, "UPDATE Cards SET CardDeadlineDate=? WHERE CardID=?", -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, deadLineDate!, -1, nil)
                    sqlite3_bind_int(statement, 2, cardID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
            if let _ = cardStatus {
                if sqlite3_prepare_v2(db, "UPDATE Cards SET CardStatus=? WHERE CardID=?", -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_int(statement, 1, cardStatus!)
                    sqlite3_bind_int(statement, 2, cardID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
        }
        else {
            completeTransaction = false
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Карта обновлена!")
            }
            else {
                print("Карта не обновлена! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Карта не обновлена! Откат транзакции!")
            }
            else {
                print("Карта не обновлена! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
    
    public func addNewUserToDesk(_ deskID: Int32, _ newUserID: Int32, _ isOwner: Int32) -> Bool {
        let addNewUserToDeskQuery = "INSERT INTO AccessTable(ProfileID, DeskID, IsOwner) VALUES (?, ?, ?)"
        if sqlite3_prepare_v2(db, addNewUserToDeskQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, newUserID)
            sqlite3_bind_int(statement, 2, deskID)
            sqlite3_bind_int(statement, 3, isOwner)
            if sqlite3_step(statement) != SQLITE_OK {
                print("Ошибка базы данных! Невозможно добавить нового пользователя к доске!")
                return false
            }
        }
        return true
    }
    
    public func updateUser(profileID: Int32, email: String?, name: String?, surname: String?, password: String?) -> Bool {
        var completeTransaction = true
        
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK{
            if let _ = email {
                if findUser(email: email!, password: nil) == -1{
                    completeTransaction = false
                }
                else {
                    let query = "UPDATE ProfileAuthor SET ProfileEmail=? WHERE ProfileID=?"
                    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                        sqlite3_bind_text(statement, 1, email, -1, nil)
                        sqlite3_bind_int(statement, 2, profileID)
                        if sqlite3_step(statement) != SQLITE_DONE {
                            completeTransaction = false
                        }
                    }
                    else {
                        completeTransaction = false
                    }
                }
            }
            
            if let _ = password {
                let query = "UPDATE ProfileAuthor SET ProfilePassword=? WHERE ProfileID=?"
                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                    sqlite3_bind_text(statement, 1, password, -1, nil)
                    sqlite3_bind_int(statement, 2, profileID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
            if let _ = name {
                let query = "UPDATE ProfileInformation SET ProfileName=? WHERE ProfileID=?"
                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                    sqlite3_bind_text(statement, 1, name, -1, nil)
                    sqlite3_bind_int(statement, 2, profileID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
            
            if let _ = surname {
                let query = "UPDATE ProfileInformation SET ProfileSecondName=? WHERE ProfileID=?"
                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                    sqlite3_bind_text(statement, 1, surname, -1, nil)
                    sqlite3_bind_int(statement, 2, profileID)
                    if sqlite3_step(statement) != SQLITE_DONE {
                        completeTransaction = false
                    }
                }
                else {
                    completeTransaction = false
                }
            }
        }
        else {
            completeTransaction = false
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Пользователь не обновлен!")
            }
            else {
                print("Пользователь не обновлен! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Пользователь не обновлен! Откат транзакции!")
            }
            else {
                print("Пользователь не обновлен! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
    
    public func deleteUser(ID: Int32) -> Bool {
        let deskList = getDesksList(profileID: ID)
        var cardList: [Card] = []
        for i in deskList {
            let cardListByDeskID = getCardsList(deskID: i.id)
            for j in cardListByDeskID {
                cardList.append(j)
            }
        }
        
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) != SQLITE_OK {
            for i in cardList{
                if !deleteCard(i.id) {
                    completeTransaction = false
                    break
                }
            }
            
            for i in deskList {
                if !deleteDesk(i.id) {
                    completeTransaction = false
                    break
                }
            }
            
            if sqlite3_prepare_v2(db, "DELETE from ProfileAuthor WHERE ProfileID=?", -1, &statement, nil) != SQLITE_OK {
                sqlite3_bind_int(statement, 1, ID)
                if sqlite3_step(statement) != SQLITE_DONE {
                    completeTransaction = false
                }
            }
            
            if sqlite3_prepare_v2(db, "DELETE from ProfileInformation WHERE ProfileID=?", -1, &statement, nil) != SQLITE_OK {
                sqlite3_bind_int(statement, 1, ID)
                if sqlite3_step(statement) != SQLITE_DONE {
                    completeTransaction = false
                }
            }
        }
        else {
            completeTransaction = true
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Пользователь удален!")
            }
            else {
                print("Пользователь не удален! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Пользователь не удален! Откат транзакции!")
            }
            else {
                print("Пользователь не удален! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
    
    public func addNewCard(_ card: Card) -> Bool {
        var completeTransaction = true
        if sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil) == SQLITE_OK {
            let newCardIDQuery = "SELECT MAX(CardID) FROM Cards"
            if sqlite3_prepare_v2(db, newCardIDQuery, -1, &statement, nil) != SQLITE_OK {
                print("Ошибка базы данных! Невозможно получить максимальный ID!")
                completeTransaction = false
            }
            if sqlite3_step(statement) == SQLITE_ROW {
                card.id = sqlite3_column_int(statement, 0) + 1
            }
            else {
                card.id = 1
            }
            
            let newCardQuery = "INSERT INTO Cards (CardID, DeskID, CardName, CardDescription, CardCreationDate, CardDeadLineDate, CardStatus) VALUES(?, ?, ?, ?, ?, ?, ?)"
            if sqlite3_prepare_v2(db, newCardQuery, -1, &statement, nil) == SQLITE_OK {
                let id = card.id
                let deskID = card.deskID
                let name = card.name
                let desc = card.description
                let crDate = card.creationDate
                let dDate = card.deadLineDate
                let status = card.cardStatus
                sqlite3_bind_int(statement, 1, id)
                sqlite3_bind_int(statement, 2, deskID)
                sqlite3_bind_text(statement, 3, name, -1, nil)
                sqlite3_bind_text(statement, 4, desc, -1, nil)
                sqlite3_bind_text(statement, 5, crDate, -1, nil)
                sqlite3_bind_text(statement, 6, dDate!, -1, nil)
                sqlite3_bind_int(statement, 7, status)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    completeTransaction = false
                }
            }
            else {
                completeTransaction = false
            }
        }
        
        if completeTransaction {
            if sqlite3_exec(db, "COMMIT;", nil, nil, nil) == SQLITE_OK {
                print("Карта добавлена!")
            }
            else {
                print("Карта не добавлена! Ошибка в COMMIT!")
                completeTransaction = false
            }
        }
        else {
            if sqlite3_exec(db, "ROLLBACK;", nil, nil, nil) == SQLITE_OK {
                print("Карта не добавлена! Откат транзакции!")
            }
            else {
                print("Карта не добавлена! Ошибка в ROLLBACK!")
                completeTransaction = false
            }
        }
        return completeTransaction
    }
}
