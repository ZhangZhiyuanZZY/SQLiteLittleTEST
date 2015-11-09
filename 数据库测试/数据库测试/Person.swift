//
//  Person.swift
//  数据库测试
//
//  Created by 章芝源 on 15/11/8.
//  Copyright © 2015年 ZZY. All rights reserved.
//

import UIKit

class Person: NSObject {
    var id: Int = 0;
    var name: String?
    var age: Int = 0;
    var height: Double = 0;
    var title: String?
    
    
    ///字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    ///设置本类输出格式
    override var description: String {
        return "\(id) \(name) \(age) \(height) \(title)"
    }
    
    ///MARK: -查询
    class  func persons() ->[Person] {
        
        //设置sql数组
        let sql =  "SELECT id, name, age, height, title FROM T_Person LIMIT 20;"
        
        //执行sql
       guard let array = SQLiteManager.shareManager
    }
    
    //MARK: -将当前对象插入数据
    func insertPerson() -> Bool {
        //断言名字不能为空
        assert(name != nil, "名字不能为空")
        let t = title ?? ""
        let sql = "INSERT INTO T_Person (name, age, height, title) \n" +
        "VALUES ('\(name!)', \(age), \(height), '\(t)');"
         // 执行完成之后，需要知道 自动增长的 id，否则无法更新模型数据
        id = SQLiteManager.shareManager.execInsert(sql)
        
        return id > 0
    }
    
    
    //MARK: -更新id对应的数据
    func updatePerson() -> Bool {
        //0. 断言
        assert(name != nil, "名字不能为空")
        assert(id > 0, "无效主键")
        let t = title ?? ""
        
        //1. 设置sql语句
        let sql = "UPDATE T_Person SET name = '\(name!)', \n" +
            "age = \(age), height = \(height), title = '\(t)' \n" +
        "WHERE id = \(id);"
        
        //2. 执行sql
        return SQLiteManager.shareManager.execSQL(sql)
    }
    
    //MARK: -删除
    func deletePerson() -> Bool {
        //0. 断言
        assert(id > 0, "无效主键")
        
        //1. 设置sql语句 
        let sql = "DELETE FROM T_Person WHERE id = \(id);"
        
        //2.执行
        return SQLiteManager.shareManager.execSQL(sql)
    }
    
    
}
