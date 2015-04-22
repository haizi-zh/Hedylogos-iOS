//
//  ChatConversation.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ChatConversation: NSObject {
    var chatterId: Int = -1
    var chattterName: String?
    var lastUpdateTime: Int?
    var lastMessage: BaseMessage?
    var chatType: Int?
}
