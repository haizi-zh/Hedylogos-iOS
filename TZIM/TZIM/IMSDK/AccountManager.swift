//
//  AccountManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/24/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let accountManager = AccountManager()

class AccountManager: NSObject {
    
    var userId = -1

    class func shareInstance() -> AccountManager {
        return accountManager
    }
    
    override init() {
        super.init()
    }
    
    var userChatImagePath: String {
        get {
            var fileManager = NSFileManager.defaultManager()
            var imagePath = documentPath.stringByAppendingPathComponent("\(userId)/ChatImage/")
            if !fileManager.fileExistsAtPath(imagePath) {
                fileManager.createDirectoryAtPath(imagePath, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return imagePath
        }
    }
    
    var userChatAudioPath: String {
        get {
            var fileManager = NSFileManager.defaultManager()
            var audioPath = documentPath.stringByAppendingPathComponent("\(userId)/ChatAudio/")
            if !fileManager.fileExistsAtPath(audioPath) {
                fileManager.createDirectoryAtPath(audioPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return audioPath
        }
    }
}


