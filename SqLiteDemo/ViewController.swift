//
//  ViewController.swift
//  SqLiteDemo
//
//  Created by Quan Li on 2019/10/18.
//  Copyright © 2019 Quan Li. All rights reserved.
//

import UIKit
import SQLite

class UserTable{
    var sql:SqLiteManger
    let id = Expression<Int64>.init("uId")
    let name = Expression<String>.init("userName")
    let isMan = Expression<Bool>.init("isMan")
    
    var table:Table?
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        print(path)
        sql = SqLiteManger.init(sqlPath: path + "/demo.sqlite")
        
        table = sql.createTable(tableName: "User") { (bulider) in
            bulider.column(id,primaryKey: .autoincrement)
            bulider.column(name)
            bulider.column(isMan)
        }
    }
    
    
    func add(userName:String,isMain:Bool){
//        增
//        if sql.insert(table: table, setters: [name <- "小红",isMan <- true]){
//            print("成功")
//        }
//        删
//        if sql.delete(table: table, filter: name == "小红") {
//            print("成功")
//        }
//        改
//        if sql.update(table: table, setters: [name <- "小红"], filter: name == "小明") {
//            print("成功")
//        }
//        查
        let rows = sql.select(table: table,select: [id,name],filter: id >= 0)
        for item in rows ?? [] {
            print(item[id],item[name])
        }
    }
    
    
}



class ViewController: UIViewController {
    
    var table = UserTable.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func clickAdd(_ sender: Any) {
        table.add(userName: "小明", isMain: true)
    }
    
    @IBAction func clickDelete(_ sender: Any) {
        
    }
    
    @IBAction func clickUpdate(_ sender: Any) {
        
    }
    @IBAction func clickSelect(_ sender: Any) {
        
    }
    
}

