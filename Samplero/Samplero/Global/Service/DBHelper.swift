//
//  DBHelper.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/11.
//

import Foundation
import SQLite3

final class DBHelper {
    
    // MARK: - Properties
    
    static let shared = DBHelper()
    
    var db: OpaquePointer?
    let databaseName = "SampleroDB.sqlite"
    
    // MARK: - Init
    
    init() {
        self.db = createDB()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - DDL Func (CREATE, ALTER, DROP, etc)
    
    private func createDB() -> OpaquePointer? {
        var db: OpaquePointer?
        
        do {
            let dbPath: String = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
                .appendingPathComponent(databaseName).path
            
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("SQLite:", "Successfully created DB. Path: \(dbPath)")
                return db
            }
        } catch {
            print("SQLite:", "Error while creating Database -\(error.localizedDescription)")
        }
        
        return nil
    }
    
    func createTables() {
        createEstimateHistoryTable()
    }
    
    private func createEstimateHistoryTable() {
        var statement: OpaquePointer?
        let query = """
               CREATE TABLE IF NOT EXISTS ESTIMATE_HISTORY(
               IMAGE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
               WIDTH REAL,
               HEIGHT REAL,
               SELECTED_SAMPLE_ID INTEGER
               );
               """
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("SQLite:", "Creating table has been succesfully done. db: \(String(describing: self.db))")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("SQLite:", "sqlte3_step failure while creating table: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db))
            print("SQLite:", "sqlite3_prepare failure while creating table: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - DML Func (INSERT, UPDATE, DELETE, SELECT, etc)
    
    func insertEstimateHistory(history: EstimateHistory) {
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO ESTIMATE_HISTORY (IMAGE_ID, WIDTH, HEIGHT, SELECTED_SAMPLE_ID) VALUES (?, ?, ?, ?);"
        
        if sqlite3_prepare_v2(self.db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 2, history.width ?? 0.0)
            sqlite3_bind_double(statement, 3, history.height ?? 0.0)
            sqlite3_bind_int(statement, 4, Int32(history.selectedSampleId ?? 1))
        } else {
            print("SQLite:", "sqlite binding failure")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("SQLite:", "sqlite insertion success")
        } else {
            print("SQLite:", "sqlite step failure")
        }
    }
    
    func getEstimateHistories() -> [EstimateHistory] {
        var statement: OpaquePointer?
        var estimateHistories: [EstimateHistory] = []
        let query: String = "SELECT * FROM ESTIMATE_HISTORY;"
        
        if sqlite3_prepare(self.db, query, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("SQLite:", "error while prepare: \(errorMessage)")
            return estimateHistories
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let imageId: Int = Int(sqlite3_column_int(statement, 0))
            let width: Double = sqlite3_column_double(statement, 1)
            let height: Double = sqlite3_column_double(statement, 2)
            let selectedSampleId: Int = Int(sqlite3_column_int(statement, 3))
            
            estimateHistories.append(EstimateHistory(imageId: imageId, width: width, height: height, selectedSampleId: selectedSampleId))
        }
        
        sqlite3_finalize(statement)
        
        return estimateHistories
    }
    
    func updateEstimateHistory(imageId id: Int, history: EstimateHistory) {
        var statement: OpaquePointer?
        let query = "UPDATE ESTIMATE_HISTORY SET IMAGE_ID = '\(history.imageId)', WIDTH = '\(history.width ?? 0.0)', HEIGHT = '\(history.height ?? 0.0)', SELECTED_SAMPLE_ID = '\(history.selectedSampleId ?? 1) WHERE IMAGE_ID == \(id)"
        
        if sqlite3_prepare(db, query, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("SQLite:", "Error preparing update: \(errorMessage)")
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("SQLite:", "Error preparing update: \(errorMessage)")
            return
        }
        
        print("SQLite:", "Update has been successfully done")
    }
    
    func deleteEstimateHistory(imageId id: Int) {
        var statement: OpaquePointer?
        let queryString = "DELETE FROM ESTIMATE_HISTORY WHERE IMAGE_ID == \(id)"
        
        if sqlite3_prepare(db, queryString, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("SQLite:", "Error preparing update: \(errorMessage)")
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("SQLite:", "Error preparing update: \(errorMessage)")
            return
        }
        
        print("SQLite:", "delete has been successfully done")
    }
    
    // MARK: - DCL Func (COMMIT, ROLLBACK, GRANT, REVOKE, etc)
    
    
}

