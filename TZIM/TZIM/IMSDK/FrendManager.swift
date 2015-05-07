//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let frendManger = FrendManager()

class FrendManager: NSObject {
    
    let frendList: NSMutableArray!
    
    class func shareInstance() -> FrendManager {
        return frendManger
    }
    
    override init() {
        frendList = FrendManager.getAllMyContacts().mutableCopy() as! NSMutableArray
    }
    
    /**
    添加一个好友
    :param: frend
    */
    func addFrend(frend: FrendModel) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.addFrend2DB(frend)
        frendList.addObject(frend)
    }
    
    /**
    获取所有的好友列表
    :returns:
    */
    private class func getAllMyContacts() -> NSArray {
        var retArray = NSArray()
        var daoHelper = DaoHelper.shareInstance()
        retArray = daoHelper.selectAllContacts()
        return retArray
    }
    
    /**
    用户是否在本地数据里存在
    :param: userId 查询的用户 id
    :returns:
    */
    func frendIsExit(userId: Int) -> Bool {
        for model in frendList {
            if (model as! FrendModel).userId == userId {
                return true
            }
        }
        return false
    }
}






