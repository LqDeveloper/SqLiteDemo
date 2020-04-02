//
//  SqLiteManger.swift
//
//
//  Created by Quan Li on 2019/10/18.
//  Copyright © 2019 Quan Li. All rights reserved.
//

import Foundation
import SQLite
class SqLiteManger{
    private var db:Connection?
    init(sqlPath:String) {
        db = try? Connection.init(sqlPath)
        db?.busyTimeout = 5.0
    }
}

struct TableColumn {
    var cid:Int64?
    var name:String?
    var type:String?
    var notnul:Int64?
    var defaultValue:Any?
    var primaryKey:Int64?
}

extension SqLiteManger{
    func createTable(tableName:String, block: (TableBuilder) -> Void) -> Table? {
        do{
            let table = Table.init(tableName)
            try db?.run(table.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (builder) in
                block(builder)
            }))
            return table
        }catch(let error){
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult func deleteTable(tableName:String) -> Bool {
        let exeStr = "drop table if exists \(tableName) "
        do {
            try db?.execute(exeStr)
            return true
        }catch(let error){
            debugPrint(error.localizedDescription)
            return  false
        }
    }
    
    @discardableResult func updateTable(oldName:String,newName:String) -> Bool {
        let exeStr = "alter table \(oldName) rename to \(newName) "
        do {
            try db?.execute(exeStr)
            return true
        }catch(let error){
            debugPrint(error.localizedDescription)
            return  false
        }
    }
}

extension SqLiteManger{
    @discardableResult func addColumn(tableName:String,columnName:String,columnType:String) -> Bool {
        let exeStr = "alter table \(tableName) add \(columnName) \(columnType) "
        do {
            try db?.execute(exeStr)
            return true
        }catch(let error){
            debugPrint(error.localizedDescription)
            return  false
        }
    }
    
    func checkColumnExist(tableName:String,columnName:String) -> Bool {
        return  allColumns(tableName: tableName).filter { (model) -> Bool in
            return model.name == columnName
        }.count != 0
    }
    
    func allColumns(tableName:String) -> [TableColumn] {
        let exeStr = "PRAGMA table_info([\(tableName)]) "
        do {
            let stmt = try db?.prepare(exeStr)
            guard let result = stmt else {
                return []
            }
            var columns:[TableColumn] = []
            for case let row in result {
                guard row.count == 6 else {
                    continue
                }
                let column = TableColumn.init(cid: row[0] as? Int64, name: row[1] as? String, type: row[2] as? String, notnul: row[3] as? Int64 ??  0, defaultValue: row[4], primaryKey: row[5]  as? Int64 ??  0)
                columns.append(column)
                print(row)
            }
            return  columns
        }catch(let error){
            debugPrint(error.localizedDescription)
            return  []
        }
    }
}


extension SqLiteManger{
    @discardableResult func insert (table:Table?,setters:[Setter]) -> Bool{
        guard let tab = table else {
            return false
        }
        do {
            try db?.run(tab.insert(setters))
            return true
        } catch let error {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    @discardableResult func delete(table:Table?,filter: Expression<Bool>? = nil) -> Bool{
        guard var filterTable = table else {
            return false
        }
        do {
            if let filterTemp = filter  {
                filterTable = filterTable.filter(filterTemp)
            }
            try db?.run(filterTable.delete())
            return true
        } catch let error {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    @discardableResult func update(table:Table?,setters:[Setter],filter: Expression<Bool>? = nil) -> Bool {
        guard var filterTable = table else {
            return false
        }
        do {
            if let filterTemp = filter  {
                filterTable = filterTable.filter(filterTemp)
            }
            try db?.run(filterTable.update(setters))
            return true
        } catch let error {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    func select(table:Table?,select: [Expressible] = [],filter: Expression<Bool>? = nil, order: [Expressible] = [], limit: Int? = nil, offset: Int? = nil) -> [Row]? {
        guard var queryTable = table else {
            return nil
        }
        do {
            if select.count != 0{
                queryTable = queryTable.select(select).order(order)
            }else{
                queryTable = queryTable.order(order)
            }
            
            if let filterTemp = filter {
                queryTable = queryTable.filter(filterTemp)
            }
            if let lim = limit{
                if let off = offset {
                    queryTable = queryTable.limit(lim, offset: off)
                }else{
                    queryTable = queryTable.limit(lim)
                }
            }
            guard let result = try db?.prepare(queryTable) else { return nil }
            return Array.init(result)
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
}
