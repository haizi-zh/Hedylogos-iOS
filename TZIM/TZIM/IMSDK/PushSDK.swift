//
//  PushSDK.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol PushMessageDelegate {
    func receivePushMessage(messageStr: NSDictionary)
}

@objc protocol PushConnectionDelegate {
    func getuiDidConnection(clientId: String)
}


private let pushSDKManager = PushSDKManager()

class PushSDKManager: NSObject, GexinSdkDelegate {
    private var gexinSdk: GexinSdk?
    private var listenerQueue: NSMutableArray = NSMutableArray()
    
    weak var pushConnectionDelegate: PushConnectionDelegate?
    
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
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addPushMessageListener(listener: PushMessageDelegate, withRoutingKey routingKey: String) {
        listenerQueue.addObject([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removePushMessageListener(listener: PushMessageDelegate, withRoutingKey routingKey: String) {
        for value in listenerQueue {
            var listenerDic = value as! Dictionary<String, PushMessageDelegate>
            if let oldListener = listenerDic[routingKey] {
                if oldListener === listener {
                    listenerQueue.removeObject(value)
                    return
                }
            }
        }
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
        
        println("*****  GexinSdkDidOccurError  ******")

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
            dispatchPushMessage(message)
        }
    }
    
    /**
    分发给不同监听者不同的消息
    
    :param: message 需要分发的消息
    */
    func dispatchPushMessage(message: NSString) {
        let dispatchMessageDic: NSDictionary
        var mseesageData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            dispatchMessageDic = messageJson?.objectForKey("message") as! NSDictionary
        } else {
            dispatchMessageDic = NSDictionary()
        }

        var routingKey = "IM"
        
        for value in listenerQueue {
            var listenerDic = value as! Dictionary<String, PushMessageDelegate>
            if let pushMessageDelegate = listenerDic[routingKey] {
                pushMessageDelegate.receivePushMessage(dispatchMessageDic)
            }
        }
    }
    
    /**
    个推注册成功,相当于 client 登录成功
    :param: clientId 注册成功后的 id
    */
    func GexinSdkDidRegisterClient(clientId: String!) {
        pushConnectionDelegate?.getuiDidConnection(clientId)
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








