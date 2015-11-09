//
//  ViewController.swift
//  数据库测试
//
//  Created by 章芝源 on 15/11/8.
//  Copyright © 2015年 ZZY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        demoInsertPerson()
        //更新
//        demoUpdatePerson()
        //删除
//        demoDeleteData()
        
        //查询
        print(Person.persons())
       
    
    }
    
    
    ///删除
    func demoDeleteData() {
        let dict = ["id":1]
        
        let p = Person(dict: dict)
        if p.deletePerson(){
            print("删除成功")
        }else{
            print("删除失败")
        }

    }
    
    
    
    ///更新
    func demoUpdatePerson() {
        let dict = ["id":1, "name": "zhangdadan", "age": 28, "height": 1.8, "title": "boss"]
        
        let p = Person(dict: dict)
        if p.updatePerson(){
            print("更新成功")
        }else{
            print("更新失败")
        }
    }
    
    
    ///插入
    func demoInsertPerson() {
        let dict = ["name": "lisi", "age": 28, "height": 1.8, "title": "boss"]
        
        let p = Person(dict: dict)
        if p.insertPerson() {
            print("插入成功 \(p.id)")
        } else {
            print("插入失败")
        }
    }
  
    

}

