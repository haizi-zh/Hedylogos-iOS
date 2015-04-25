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
}
