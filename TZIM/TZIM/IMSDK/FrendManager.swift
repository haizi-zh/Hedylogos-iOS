//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class FrendManager: NSObject {
    
    /**
    添加一个好友到数据库里
    :param: frend
    */
    func addFrend2DB(frend: FrendModel) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.addFrend2DB(frend)
    }
    
    /**
    获取所有的好友列表
    :returns:
    */
    func getAllMyContacts() -> NSArray {
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
        var daoHelper = DaoHelper.shareInstance()
        return daoHelper.frendIsExitInDB(userId)
    }
    
    /**
    异步通过 userid 获取用户信息
    
    :param: userId
    */
    func asyncGetFrendInfo(userId: Int, completion: (isSuccess: Bool, errorCode: Int, frendInfo: FrendModel) -> ()) {
        
    }
    
    /**
    从数据库里通过 userid 获取用户信息
    
    :param: userId
    
    :returns:
    */
    func getFrendInfoFromDB(#userId: Int) -> FrendModel? {
        var daoHelper = DaoHelper.shareInstance()

        return daoHelper.selectFrend(userId: userId)
    }
    
    /**
    从数据库里通过 conversationId 获取用户信息
    
    :param: conversationId
    
    :returns:
    */
    func getFrendInfoFromDB(#conversationId: String) -> FrendModel? {
        var daoHelper = DaoHelper.shareInstance()
        return daoHelper.selectFrend(conversationId: conversationId)
    }
}


















