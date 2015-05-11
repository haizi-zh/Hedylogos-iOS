//
//  FrendModel.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit


/*
好友	1
达人	2
商家	16
群组	8
群成员	4
好友&达人	3
好友&群成员	5
好友&商家	17
达人&群成员	6
商家&群成员	20
置顶&好友	65
置顶&群组	72
黑名单&好友	129
黑名单&商家	144
黑名单&达人	130
*/

/**
好友类型
*/
@objc enum IMFrendType: Int {
    case Default = 0
    case Frend = 1
    case Expert = 2
    case Group = 8
    case Business = 16
    case GroupMember = 4
    case Frend_Expert = 3
    case Frend_GroupMember = 5
    case Frend_Business = 17
    case Expert_GroupMember = 6
    case Business_GroupMember = 20
    case ChatTop_Frend = 65
    case ChatTop_Group = 72
    case Black_Frend = 129
    case Black_Business = 144
    case Black_Expert = 130
}

class FrendModel: NSObject {
    var userId: Int = -1
    var nickName: String = ""
    var type: IMFrendType = .Default
    var avatar: String = ""
    var avatarSmall: String = ""
    var shortPY: String = ""
    var fullPY: String = ""
    var signature: String = ""
    var memo: String = ""
    var sex: Int = 0
}
