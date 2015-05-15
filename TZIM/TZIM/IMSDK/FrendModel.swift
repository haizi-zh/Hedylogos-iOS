//
//  FrendModel.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

/**
好友类型
*/
@objc enum IMFrendType: Int {
    case Default = 0
    case Frend = 1
    case Expert = 2
    case Group = 8
    case DiscussionGroup = 256
    case Business = 16
    case GroupMember = 4
    case Frend_Expert = 3
    case Frend_GroupMember = 5
    case Frend_Business = 17
    case Expert_GroupMember = 6
    case Business_GroupMember = 20
    case ChatTop_Frend = 65
    case ChatTop_Group = 72
    case ChatTop_DiscussionGroup = 320
    case Black_Frend = 129
    case Black_Business = 144
    case Black_Expert = 130
}

//类型的权重值
@objc enum IMFrendWeightType: Int {
    case Frend = 1
    case Expert = 2
    case Group = 8
    case Business = 16
    case Favorite = 32
    case ConversationTop = 64
    case BlackList = 128
    case DiscussionGroup = 256
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
