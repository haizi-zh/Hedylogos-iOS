//
//  PushSDK.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol PushMessageDelegate {
    func receivePushMessage(messageStr: NSString)
}

protocol PushConnectionDelegate {
    func getuiDidConnection(clientId: String)
}


private let pushSDKManager = PushSDKManager()

class PushSDKManager: NSObject, GexinSdkDelegate {
    private var gexinSdk: GexinSdk?
    
    var pushMessageDelegate: PushMessageDelegate?
    var pushConnectionDelegate: PushConnectionDelegate?
    
    var timer: NSTimer?
    var anotherTimer: NSTimer?

    
    var allMessage = NSMutableArray()

    
    
    class func shareInstance() -> PushSDKManager {
        return pushSDKManager
    }
    
    deinit {
        println("PushSDKManager deinit")
    }
    
    func registerDeviceToken(token: String) {
        gexinSdk?.registerDeviceToken(token)
    }
    
    /**
    登录
    :param: userId   用户名
    :param: password 密码
    */
    func login(userId:Int, password:String) {
        gexinSdk = GetuiPush.login()
    }
    
    //MARK: 个推 delegate
    /**
    个推sdk 出现问题
    :param: error
    */
    func GexinSdkDidOccurError(error: NSError!) {

    }
    
    /**
    收到透传消息
    :param: payloadId 透传消息内容
    :param: appId     来自的 id
    */
    func GexinSdkDidReceivePayload(payloadId: String!, fromApplication appId: String!) {
        var payload = gexinSdk?.retrivePayloadById(payloadId)
        var length = payload?.length
        var bytes = payload?.bytes
        var payloadMsg = NSString(bytes:bytes! , length: length!, encoding: NSUTF8StringEncoding)
        
        if let message = payloadMsg {
//            pushMessageDelegate?.receivePushMessage(message)
        }
        
        testMessageReorder()

    }
    
    /**
    个推注册成功,相当于 client 登录成功
    :param: clientId 注册成功后的 id
    */
    func GexinSdkDidRegisterClient(clientId: String!) {
        pushConnectionDelegate?.getuiDidConnection(clientId)
    }
    
//MARK : TEST
    func testMessageReorder() {
        println("新一轮 testMessageReorder")

        for i in 0...0 {
            var serverId = 21+i
            var message = "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(473),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(9),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}"
            allMessage.addObject(message)
        }
        
//        for i in 0...10 {
//            var serverId = i
//            var message = "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(serverId),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello world\",\"senderId\":\(10),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}"
//            allMessage.addObject(message)
//        }
//        
//        for i in 0...10 {
//            var serverId = i
//            var message = "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(serverId),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(11),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}"
//            allMessage.addObject(message)
//        }
        
//        for i in 1...10 {
//            var serverId = 100%i
//            var message = "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(serverId),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello world\",\"senderId\":\(11),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}"
//            allMessage.addObject(message)
//        }

        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("receiveMessages"), userInfo: nil, repeats: true)
        
//        anotherTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("anotherReceiveMessages"), userInfo: nil, repeats: true)

    }
    
    func anotherReceiveMessages() {
        anotherTimer?.invalidate()
        anotherTimer = nil
        var messageStr = "{\"id\":\"55404aaef4428a00c43b4158\",\"msgId\":\(22),\"msgType\":0,\"conversation\":\"553a06e86773af0001fa51f9\",\"contents\":\"hello\(NSDate())\",\"senderId\":\(9),\"senderAvatar\":\"\",\"senderName\":\"测试用户\",\"timestamp\":\(1430276782540)}"
        pushMessageDelegate?.receivePushMessage(messageStr)
        allMessage.removeObject(messageStr)
    }

    
    func receiveMessages() {
        if allMessage.count == 0 {
            timer?.invalidate()
            timer = nil
            return
        }
        var messageStr = allMessage.firstObject as! String
        pushMessageDelegate?.receivePushMessage(messageStr)
        allMessage.removeObject(messageStr)
    }
}


class GetuiPush: GexinSdk {
    
    class func login() -> GexinSdk {
        let kAppKey = "2FaPekdgKz9QULo2X4iEq5"
        let kAppId = "PSrYJWRPN765o211bIkFM3"
        let kAppSecret = "Zvl1NOaajv5KkByR8iolgA"
        
        var pushSDKManager = PushSDKManager.shareInstance()
        var err: NSErrorPointer = NSErrorPointer()
        return GexinSdk.createSdkWithAppId(kAppId, appKey: kAppKey, appSecret: kAppSecret, appVersion: "1.0.0", delegate:pushSDKManager, error: err)
    }
    
    deinit {
        println("GetuiPush deinit")
    }
}
