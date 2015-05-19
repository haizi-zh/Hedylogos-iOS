//
//  IMConstants.swift
//  TZIM
//
//  Created by liangpengshuai on 4/24/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

/**
消息类型
*/
@objc enum IMMessageType: Int {
    case TextMessageType = 0
    case AudioMessageType = 1
    case ImageMessageType = 2
    case LocationMessageType = 3
    case GuideMessageType = 10
    case CityPoiMessageType = 11
    case TravelNoteMessageType = 12
    case SpotMessageType = 13
    case RestaurantMessageType = 14
    case ShoppingMessageType = 15
    case HotelMessageType = 16
    case CMDMessageType = 100
}

/**
消息的状态
- IMMessageReaded: 已读和发送成功
- IMMessageSending: 发送中
- IMMessageFailed: 发送失败
- IMMessageUnRead: 消息未读
*/
@objc enum IMMessageStatus: Int {
    case IMMessageSuccessful = 0
    case IMMessageSending = 1
    case IMMessageFailed = 2
}

/**
消息发送类型
- MessageMine:        我发送的消息
- MessageSomeoneElse: 别人发送的消息
*/
@objc enum IMMessageSendType: Int {
    case MessageSendMine = 0
    case MessageSendSomeoneElse = 1
}

/**
*  聊天类型
*/
@objc enum IMChatType: Int {
    case IMChatSingleType = 0               //单聊
    case IMChatGroupType = 1                //群聊
    case IMChatDiscussionGroupType = 2      //讨论组
}




