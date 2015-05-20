//
//  IMAccountManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/24/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let userUrl = "http://hedy.zephyre.me/users"


private let accountManager = IMAccountManager()

class IMAccountManager: NSObject {
    
    var account: AccountModel!

    class func shareInstance() -> IMAccountManager {
        return accountManager
    }
    
    override init() {
        var accountDaoHelper = AccountDaoHelper()
        account = accountDaoHelper.loadAccountFromDB()
        super.init()
    }
    
    /**
    用户登录成功
    
    :param: account
    */
    func userDidLogin(accountInfo: NSDictionary) {
        self.account = AccountModel()
        self.account.userId = accountInfo.objectForKey("userId") as! Int
        var accountDaoHelper = AccountDaoHelper()
        accountDaoHelper.insertAccountInfo2DB(account)  
    }
    
    var userChatImagePath: String {
        get {
            var fileManager = NSFileManager()
            var imagePath = documentPath.stringByAppendingPathComponent("\(account.userId)/ChatImage/")
            if !fileManager.fileExistsAtPath(imagePath) {
                fileManager.createDirectoryAtPath(imagePath, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return imagePath
        }
    }
    
    var userChatAudioPath: String {
        get {
            var fileManager =  NSFileManager()
            var audioPath = documentPath.stringByAppendingPathComponent("\(account.userId)/ChatAudio/")
            if !fileManager.fileExistsAtPath(audioPath) {
                fileManager.createDirectoryAtPath(audioPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return audioPath
        }
    }
    
    //文件的临时目录
    var userTempPath: String {
        get {
            var fileManager =  NSFileManager()
            var tempPath = tempDirectory.stringByAppendingPathComponent("\(account.userId)/tempFile/")
            if !fileManager.fileExistsAtPath(tempPath) {
                fileManager.createDirectoryAtPath(tempPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return tempPath
        }
    }

}


