//
//  MessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/23/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

/// ACKArray 当超过多少是进行 ack
let MaxACKCount = 20
let ACKTime = 120.0


private let messageManger = MessageManager()

@objc protocol MessageManagerDelegate {
    func shouldACK(messageList: Array<String>)
    
}

class MessageManager: NSObject {
    
    let allLastMessageList: NSMutableDictionary
    weak var delegate: MessageManagerDelegate?
    
    private var timer: NSTimer!
    
    /// 储存将要 ACK 的消息
    var messagesShouldACK: Array<String> = Array()
    
    class func shareInsatance() -> MessageManager {
        return messageManger
    }
    
    override init() {
        var daoHelper = DaoHelper.shareInstance()
        allLastMessageList = daoHelper.selectAllLastServerChatMessageInDB().mutableCopy() as! NSMutableDictionary
        super.init()
        self.startTimer()
    }
    
    func updateLastServerMessage(message: BaseMessage) {
        if let lastMessage: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
            if (lastMessage as! Int) < message.serverId {
                allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
            }
        } else {
            allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
        }
    }
    
    func addChatMessage2ACK(message: BaseMessage) {
        messagesShouldACK.append(message.messageId)
        println("ACK消息队列里一共有\(messagesShouldACK.count)条数据")
        if messagesShouldACK.count > MaxACKCount {
            self.shouldACK()
        }
    }
    
    func ackMessageWhenTimeout() {
        self.shouldACK()
    }

    /**
    当 ack 成功后只清除ack 成功的数据
    
    :param: messageList 成功 ack 的消息
    */
    func clearMessageWhenACKSuccess(messageList: Array<BaseMessage>) {

    }
    
    /**
    当 ack 成功后清除说有的 ack 数据
    */
    func clearAllMessageWhenACKSuccess() {
        messagesShouldACK.removeAll(keepCapacity: false)
    }
    
    func shouldACK() {
        self.delegate?.shouldACK(messagesShouldACK)
    }
   
    /**
    将 MessageModel转化成发送的消息格式
    :param: receiverId
    :param: senderId
    :param: message
    :returns:
    */
    class func prepareMessage2Send(#receiverId: Int, senderId: Int, conversationId: String?, chatType: IMChatType, message:BaseMessage) ->  NSDictionary {
        var retDic = NSMutableDictionary()
        retDic.setValue(message.messageType.rawValue, forKey: "msgType")
        retDic.setValue(senderId, forKey: "sender")
        retDic.setValue(message.message, forKey: "contents")
        if let conversationId = conversationId {
            retDic.setValue(conversationId, forKey: "conversation")
        }
        retDic.setValue(receiverId, forKey: "receiver")
        
        if chatType == IMChatType.IMChatSingleType {
            retDic.setValue("single", forKey: "chatType")
            
            } else {
            retDic.setValue("group", forKey: "chatType")
        }
    
        switch message.messageType {
        case .LocationMessageType :
            var location = ["name": (message as! LocationMessage).address, "lng": (message as! LocationMessage).longitude, "lat": (message as! LocationMessage).latitude]
            var contentStr = message.contentsStrWithJsonObjc(location)
            retDic.setValue(contentStr, forKey: "contents")
            
        case .TextMessageType :
            retDic.setValue(message.message, forKey: "contents")
            
        case .ImageMessageType :
            retDic.setValue("image: \(message.localId)", forKey: "contents")
            
        default:
            break
        }
        return retDic
    }
    
    /**
    将 其他类型的 message 转为 MessageModel 类型
    :param: messageObjc
    :returns:
    */
    class func messageModelWithMessage(messageObjc: AnyObject) -> BaseMessage? {
        if let messageDic = messageObjc as? NSDictionary {
            return MessageManager.messageModelWithMessageDic(messageDic)
        } else if let messageStr = messageObjc as? String {
            return MessageManager.messageModelWithMessageDic(MessageManager.jsonObjcWithString(messageStr))
        }
        return nil
    }
    
    class func messageModelWithPoiModel(poiModel: IMPoiModel) -> BaseMessage {
        var message: BaseMessage
        switch poiModel.poiType {
        case IMPoiType.City:
            var cityMsg = IMCityMessage()
            cityMsg.poiId = poiModel.poiId
            cityMsg.poiName = poiModel.poiName
            cityMsg.image = poiModel.image
            cityMsg.desc = poiModel.desc
            message = cityMsg

        case IMPoiType.Spot:
            var spotMsg = IMSpotMessage()
            spotMsg.spotId = poiModel.poiId
            spotMsg.spotName = poiModel.poiName
            spotMsg.image = poiModel.image
            spotMsg.desc = poiModel.desc
            message = spotMsg

        case IMPoiType.Guide:
            var guideMsg = IMGuideMessage()
            guideMsg.guideId = poiModel.poiId
            guideMsg.guideName = poiModel.poiName
            guideMsg.image = poiModel.image
            guideMsg.desc = poiModel.desc
            guideMsg.timeCost = poiModel.timeCost
            message = guideMsg

        case IMPoiType.TravelNote:
            var travelNoteMsg = IMTravelNoteMessage()
            travelNoteMsg.travelNoteId = poiModel.poiId
            travelNoteMsg.name = poiModel.poiName
            travelNoteMsg.image = poiModel.image
            travelNoteMsg.desc = poiModel.desc
            travelNoteMsg.detailUrl = poiModel.detailUrl
            message = travelNoteMsg

        case IMPoiType.Restaurant:
            var restaurantMsg = IMRestaurantMessage()
            restaurantMsg.restaurantId = poiModel.poiId
            restaurantMsg.poiName = poiModel.poiName
            restaurantMsg.image = poiModel.image
            restaurantMsg.rating = poiModel.rating
            restaurantMsg.address = poiModel.address
            restaurantMsg.price = poiModel.price
            message = restaurantMsg

        case IMPoiType.Shopping:
            var shoppingMsg = IMShoppingMessage()
            shoppingMsg.shoppingId = poiModel.poiId
            shoppingMsg.poiName = poiModel.poiName
            shoppingMsg.image = poiModel.image
            shoppingMsg.rating = poiModel.rating
            shoppingMsg.address = poiModel.address
            shoppingMsg.price = poiModel.price
            message = shoppingMsg

        case IMPoiType.Hotel:
            var hotelMsg = IMHotelMessage()
            hotelMsg.hotelId = poiModel.poiId
            hotelMsg.poiName = poiModel.poiName
            hotelMsg.image = poiModel.image
            hotelMsg.rating = poiModel.rating
            hotelMsg.address = poiModel.address
            hotelMsg.price = poiModel.price
            message = hotelMsg

        default:
            message = BaseMessage()

        }
        
        if let content = poiModel.getContentStr() {
            message.message = content as String
        }
        return message
    }
       
//MARK: private methods
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(ACKTime, target: self, selector: Selector("ackMessageWhenTimeout"), userInfo: nil, repeats: true)
        println("********ACK 的定时器开始启动了*******")
    }
    
    private class func messageModelWithMessageDic(messageDic: NSDictionary) -> BaseMessage? {
        var messageModel: BaseMessage?
        if let messageTypeInteger = messageDic.objectForKey("msgType")?.integerValue {
        
            if let messageType = IMMessageType(rawValue: messageTypeInteger) {
                switch messageType {
                    
                case .TextMessageType :
                    messageModel = TextMessage()
                    
                case .ImageMessageType :
                    messageModel = ImageMessage()
                    messageModel?.metadataId = NSUUID().UUIDString
                    
                case .AudioMessageType:
                    messageModel = AudioMessage()
                    messageModel?.metadataId = NSUUID().UUIDString

                case .LocationMessageType:
                    messageModel = LocationMessage()
                    
                case .CityPoiMessageType:
                    messageModel = IMCityMessage()
                    
                case .SpotMessageType:
                    messageModel = IMSpotMessage()
                    
                case .GuideMessageType:
                    messageModel = IMGuideMessage()
                    
                case .TravelNoteMessageType:
                    messageModel = IMTravelNoteMessage()
                    
                case .RestaurantMessageType:
                    messageModel = IMRestaurantMessage()
                    
                case .ShoppingMessageType:
                    messageModel = IMShoppingMessage()
                    
                case .HotelMessageType:
                    messageModel = IMHotelMessage()
                    
                case .CMDMessageType:
                    messageModel = IMCMDMessage()
                    
                default :
                    return nil
                }
                
                if let contents = messageDic.objectForKey("contents") as? String {
                    messageModel!.message = contents
                    messageModel?.fillContentWithContent(contents)
                }
                messageModel!.conversationId = messageDic.objectForKey("conversation") as? String
                messageModel!.createTime = messageDic.objectForKey("timestamp") as! Int
                
                if let chatType = messageDic.objectForKey("chatType") as? String {
                    if chatType == "single" {
                        messageModel!.chatterId = messageDic.objectForKey("senderId") as! Int
                        
                    } else {
                        messageModel!.chatterId = messageDic.objectForKey("groupId") as! Int
                    }
                    
                } else {
                    messageModel!.chatterId = messageDic.objectForKey("senderId") as! Int

                }
                
                messageModel!.senderId = messageDic.objectForKey("senderId") as! Int
                
                if let senderId = messageDic.objectForKey("msgId") as? Int {
                    messageModel!.serverId = senderId
                }
                
                if let messageId = messageDic.objectForKey("id") as? String {
                    messageModel?.messageId = messageId
                }
                
            }
        } else {
            println(" ****解析消息出错******")
        }
        return messageModel
    }
    
    private class func jsonObjcWithString(messageStr: String) -> NSDictionary {
        var mseesageData = messageStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            return messageJson as! NSDictionary
        } else {
            return NSDictionary()
        }
    }
    
}
