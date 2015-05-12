//
//  AccountModel.swift
//  TZIM
//
//  Created by liangpengshuai on 5/11/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class AccountModel: NSObject {
    
    var userId: Int = -1
    var nickName: String = ""
    var avatar: String = ""
    var avatarSmall: String = ""
    var shortPY: String = ""
    var fullPY: String = ""
    var signature: String = ""
    var memo: String = ""
    var sex: Int = 0
    
    var contactList: Array<FrendModel> = Array()
    var groupList: Array<IMGroupModel> = Array()
   
}
