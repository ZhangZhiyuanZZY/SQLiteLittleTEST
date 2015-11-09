//
//  SQLiteManager.swift
//  数据库测试
//
//  Created by 章芝源 on 15/11/8.
//  Copyright © 2015年 ZZY. All rights reserved.
//

import Foundation
///打开数据库的方法
///是c语言的框架, 函数都是以 sqlite3_开始的
///SQLite管理器
class SQLiteManager {
    //swift中的单例
    static let shareManager = SQLiteManager();
    //生成句柄
    /// 全局的数据库`句柄` handler，通常就是一个指向结构体的指针
    /// 后续的数据库操作，全部依赖此句柄
    private var db: COpaquePointer = COpaquePointer();
    
    ///打开数据库
    func openDB(dbName: String) {
        
        //生成数据库中完整的路径
        let path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString).stringByAppendingPathComponent(dbName);
        
//        print(path);
        /**
        参数
        1. 数据库的完整路径，beta 5可以直接使用
        2. 数据库`句柄`
        
        如果数据库存在，就会直接打开
        如果数据库不存在，会新建数据库，再打开
        */
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("打开数据库失败")
            return;
        }
        
        if createTable() {
            print("打开数据库成功")
        }else{
            print("打开数据库失败")
        }
           }
    
    
    ///执行插入语句
    func execInsert(sql: String) -> Int {
        // 1. 执行sql
        if sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK {
            // 2. 返回id > 0
            // sqlite3_last_insert_rowid 返回自动增长键值的 id
            return Int(sqlite3_last_insert_rowid(db))
        }
        // 2. 插入失败，返回-1
        return -1

    }
    
    ///执行SQL
    func execSQL(sql: String) -> Bool {
        /**
        参数
        1. db 全局句柄
        2. 要执行的 sql
        3. callback 执行sql完毕回调的函数，通常是nil
        4. 第三个参数回调函数的第一个参数的地址，通常是 nil
        5. 错误信息字符串的地址，通常不需要
        */
        return (sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK)
    }
    
    
    
    //双引号在swift中涉及到一个转义的问题
    ///创建数据列表
    private func createTable() -> Bool {
        // 提示：拼接 sql 的末尾，添加 \n 可以避免字符串连接错误，方便阅读，便于维护
        // 如果 sql 执行错误，可以 print 输出，在 navicat 中调试修改！
        let sql = "CREATE TABLE \n" +
            "IF NOT EXISTS 'T_Person' ( \n" +
            "'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "'name' TEXT, \n" +
            "'age' INTEGER, \n" +
            "'height' REAL, \n" +
            "'title' TEXT \n" +
        ");"
        
        print(sql)
        
        return execSQL(sql)
    }
    
    //MARK: -查询
    //查询成功后返回一个字典数组
    func execRecordSet(sql: String) -> [[String: AnyObject]]? {
        
        //1. 预先编译sql语句
        //能让运行变快
        /**
        参数
        1. db 数据库句柄
        2. sql 执行的 sql
        3. sql 语句字节的长度，但是 -1 能够自动计算
        4. stmt 语句的指针，后续的查询操作，全部依赖这个指针
        相当于编译好的 sql
        需要`释放`
        5. 尾部参数，通常设置为 nil
        */
        var stmt: COpaquePointer = nil
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("SQL 语句错误！")
            return nil
        }
        print("正确")
        
        // ---定义一个字典数组 , 返回整个查询结果集合
        var recordSet = [[String: AnyObject]]()

        // sqlite3_step `单步`执行sql 每调用一次，就获得一个结果
        // SQLITE_ROW 表示获得一条记录
        while sqlite3_step(stmt) == SQLITE_ROW {
            // 添加到数组
            recordSet.append(recordDict(stmt))
        }
        
        // 释放语句
        sqlite3_finalize(stmt)
        
        return recordSet
    }
    
    /// 从 stmt 语句中提取单条记录的字典
    private func recordDict(stmt: COpaquePointer) -> [String: AnyObject] {
        // 再继续操作就是针对`行` 一条记录，每条记录应该有多个字段
        // 1. 每一行有多少个`字段` - 列
        let colCount = sqlite3_column_count(stmt)
        
        // --- 设定一个字典 -- 记录单条记录的完整内容
        var dict = [String: AnyObject]()
        
        for col in 0..<colCount {
            // 字段名
            // uint_8 Int8 CChar Byte
            let cName = sqlite3_column_name(stmt, col)  //貌似不进行编码输出的话, 得到都是二进制的数
            let name = String(CString: cName, encoding: NSUTF8StringEncoding)
            
            // 每一列的数据类型
            let type = sqlite3_column_type(stmt, col)
            
            // 根据类型获取数值
            var value: AnyObject?
            switch type {
            case SQLITE_INTEGER:
                value = Int(sqlite3_column_int64(stmt, col))
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt, col)
            case SQLITE3_TEXT:
                // 将 UInt8 -> Int8
                let cValue = UnsafePointer<Int8>(sqlite3_column_text(stmt, col))
                value = String(CString: cValue, encoding: NSUTF8StringEncoding)
            case SQLITE_NULL:
                // OC 中不允许向数组或者字典添加 nil，添加空值可以使用 NSNull()
                value = NSNull()
            default:
                print("不支持的数据类型")
            }
            // 给字典赋值
            dict[name!] = value ?? NSNull()
    }
        return dict
    }
    
}