//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol MessageSendManagerDelegate {
    
    /**
    发送新消息
    :param: message
    */
    optional func sendNewMessage(message: BaseMessage)
    
    /**
    发送的消息已经发送成功
    :param: message 发送成功的消息
    */
    optional func messageHasSended(message: BaseMessage)
}


private let messageSendManager = MessageSendManager()

class MessageSendManager: NSObject {
    
    private var sendDelegateList: Array<MessageSendManagerDelegate> = Array()
    
    class func shareInstance() -> MessageSendManager {
        return messageSendManager
    }
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addMessageSendDelegate(listener: MessageSendManagerDelegate) {
        sendDelegateList.append(listener)
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removeMessageSendDelegate(listener: MessageSendManagerDelegate) {
        for (index, value) in enumerate(sendDelegateList) {
            if value === listener {
                sendDelegateList.removeAtIndex(index)
                return
            }
        }
    }

    
//MARK: private methods
    
    private func sendMessage(message: BaseMessage, receiver: Int, chatType:IMChatType, conversationId: String?) {
        var daoHelper = DaoHelper.shareInstance()
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(message)
        }
        var accountManager = IMAccountManager.shareInstance()
        NetworkTransportAPI.asyncSendMessage(MessageManager.prepareMessage2Send(receiverId: receiver, senderId: accountManager.account.userId, conversationId: conversationId, chatType: chatType, message: message), completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
            if isSuccess {
                message.status = IMMessageStatus.IMMessageSuccessful
                if let retMessage = retMessage {
                    if let serverId = retMessage.objectForKey("msgId") as? Int {
                        message.serverId = serverId
                        MessageManager.shareInsatance().updateLastServerMessage(message)
                    }
                }
            } else {
                message.status = IMMessageStatus.IMMessageFailed
            }
            daoHelper.updateMessageInDB("chat_\(receiver)", message: message)
            for messageManagerDelegate in self.sendDelegateList {
                messageManagerDelegate.messageHasSended?(message)
            }
        })
    }
    
//MARK: Internal methods
    
    /**
    发送一条文本消息
    :param: chatterId   接收人 id
    :param: isChatGroup 是否是群组
    :param: message     消息的内容
    :returns: 被发送的 message
    */
    func sendTextMessage(message: String, receiver: Int, chatType:IMChatType, conversationId: String?) -> BaseMessage {
        var textMessage = TextMessage()
        textMessage.createTime = Int(NSDate().timeIntervalSince1970)
        textMessage.status = IMMessageStatus.IMMessageSending
        textMessage.message = message
        textMessage.chatterId = receiver
        textMessage.sendType = IMMessageSendType.MessageSendMine
        textMessage.conversationId = conversationId
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: textMessage)
        
        sendMessage(textMessage, receiver: receiver, chatType: chatType, conversationId: conversationId)
        return textMessage
    }
    
    /**
    发送一条位置信息
    
    :param: location       位置 model，包括 lat，lng，address
    :param: receiver       接收者
    :param: chatType       聊天类型
    :param: conversationId
    
    :returns: 发送前的消息
    */
    func sendLocationMessage(location: LocationModel, receiver: Int, chatType:IMChatType, conversationId: String?) -> BaseMessage {
        var locationMessage = LocationMessage()
        locationMessage.latitude = location.latitude
        locationMessage.longitude = location.longitude
        locationMessage.address = location.address
        locationMessage.chatterId = receiver
        locationMessage.sendType = IMMessageSendType.MessageSendMine
        locationMessage.conversationId = conversationId
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: locationMessage)
        
        sendMessage(locationMessage, receiver: receiver, chatType: chatType, conversationId: conversationId)

        return locationMessage
    }
    
    /**
    发送 poi 信息
    
    :param: poiModel       poimodel
    :param: receiver       接收者
    :param: chatType       聊天类型
    :param: conversationId
    
    :returns:
    */
    func sendPoiMessage(poiModel: IMPoiModel, receiver: Int, chatType: IMChatType, conversationId: String?) -> BaseMessage {
        let message = MessageManager.messageModelWithPoiModel(poiModel)
        message.chatterId = receiver
        message.sendType = IMMessageSendType.MessageSendMine
        message.conversationId = conversationId
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: message)
        sendMessage(message, receiver: receiver, chatType: chatType, conversationId: conversationId)
        
        return message
    }
    
    /**
    发送一条图片消息
    
    :param: chatterId
    :param: isChatGroup
    :param: image   发送的图片，必选
    :returns:
    */
    func sendImageMessage(chatterId: Int, conversationId: String?, image: UIImage, chatType: IMChatType, progress:(progressValue: Float) -> ()) -> BaseMessage {
        var imageMessage = ImageMessage()
        imageMessage.chatterId = chatterId
        imageMessage.sendType = IMMessageSendType.MessageSendMine
        imageMessage.createTime = Int(NSDate().timeIntervalSince1970)
        imageMessage.status = IMMessageStatus.IMMessageSending

        var imageData = UIImageJPEGRepresentation(image, 1)
        
        var metadataId = NSUUID().UUIDString
        var imagePath = IMAccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(metadataId).jpeg")
        MetaDataManager.moveMetadata2Path(imageData, toPath: imagePath)
        
        imageMessage.localPath = imagePath
        
        var imageContentDic = NSMutableDictionary()
        imageContentDic.setObject(metadataId, forKey: "metadataId")
        imageMessage.message = imageMessage.contentsStrWithJsonObjc(imageContentDic) as! String
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(chatterId)", message: imageMessage)
        NSLog("开始上传  图像为\(image)")
        
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(imageMessage)
        }
        
        MetadataUploadManager.asyncRequestUploadToken2SendMessage(QiniuGetTokeAction.uploadChatMetadata, completionBlock: { (isSuccess, key, token) -> () in
            if isSuccess {
                MetadataUploadManager.uploadMetadata2Qiniu(imageMessage, token: token!, key: key!, metadata: imageData, chatType:chatType, conversationId: conversationId, progress: { (progressValue) -> () in
                    println("上传了: \(progressValue)")
                    })
                    { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
                        if isSuccess {
                            imageMessage.status = IMMessageStatus.IMMessageSuccessful
                            if let retMessage = retMessage {
                                if let serverId = retMessage.objectForKey("msgId") as? Int {
                                    imageMessage.serverId = serverId
                                    MessageManager.shareInsatance().updateLastServerMessage(imageMessage)
                                }
                            }
                        } else {
                            imageMessage.status = IMMessageStatus.IMMessageFailed
                        }
                        daoHelper.updateMessageInDB("chat_\(imageMessage.chatterId)", message: imageMessage)
                        for messageManagerDelegate in self.sendDelegateList {
                            messageManagerDelegate.messageHasSended?(imageMessage)
                        }
                        
                        
                }
            }
        })
        
        return imageMessage
    }
    
    /**
    发送 wav 格式的音频
    :param: chatterId
    :param: isChatGroup
    :param: wavAudioPath 音频的本地路径
    :param: progress     发送进度的回调
    :returns:
    */
    func sendAudioMessageWithWavFormat(chatterId: Int, conversationId: String?, wavAudioPath: String, chatType:IMChatType, progress:(progressValue: Float) -> ()) -> BaseMessage {
        var audioMessage = AudioMessage()
        audioMessage.chatterId = chatterId
        audioMessage.sendType = IMMessageSendType.MessageSendMine
        audioMessage.createTime = Int(NSDate().timeIntervalSince1970)
        audioMessage.status = IMMessageStatus.IMMessageSending
        
        var metadataId = NSUUID().UUIDString
        
        var tempAmrPath = IMAccountManager.shareInstance().userTempPath.stringByAppendingPathComponent("\(metadataId).amr")

        var audioWavPath = IMAccountManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("\(metadataId).wav")
        MetaDataManager.moveMetadataFromOnePath2AnotherPath(wavAudioPath, toPath: audioWavPath)
        
        VoiceConverter.wavToAmr(wavAudioPath, amrSavePath: tempAmrPath)
        
        var audioContentDic = NSMutableDictionary()
        audioContentDic.setObject(metadataId, forKey: "metadataId")

        if let url = NSURL(string: tempAmrPath) {
            var play = AVAudioPlayer(contentsOfURL: url, error: nil)
            audioContentDic.setObject(play.duration, forKey: "duration")
            audioMessage.audioLength = Float(play.duration)
        }
        
        audioMessage.localPath = audioWavPath
        audioMessage.message = audioMessage.contentsStrWithJsonObjc(audioContentDic) as! String
        
        println("开始发送语音消息： 消息内容为： \(audioMessage.message)")
        var daoHelper = DaoHelper.shareInstance()

        daoHelper.insertChatMessage("chat_\(chatterId)", message: audioMessage)
        
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(audioMessage)
        }
        
        var audioData = NSData(contentsOfFile: tempAmrPath)
        
        if let audioData = audioData {
        
            MetadataUploadManager.asyncRequestUploadToken2SendMessage(QiniuGetTokeAction.uploadChatMetadata, completionBlock: { (isSuccess, key, token) -> () in
                if isSuccess {
                    MetadataUploadManager.uploadMetadata2Qiniu(audioMessage, token: token!, key: key!, metadata: audioData, chatType:chatType, conversationId:conversationId, progress: { (progressValue) -> () in
                        println("上传了: \(progressValue)")
                        })
                        { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
                            var fileManager =  NSFileManager()
                            var error: NSError?
                            fileManager.removeItemAtPath(tempAmrPath, error: &error)
                            if error != nil {
                                println("移除发送完成后的临时文件出错 error\(error)")
                            }
                            if isSuccess {
                                audioMessage.status = IMMessageStatus.IMMessageSuccessful
                                if let retMessage = retMessage {
                                    if let serverId = retMessage.objectForKey("msgId") as? Int {
                                        audioMessage.serverId = serverId
                                        MessageManager.shareInsatance().updateLastServerMessage(audioMessage)
                                    }
                                }
                                
                            } else {
                                audioMessage.status = IMMessageStatus.IMMessageFailed
                            }
                            daoHelper.updateMessageInDB("chat_\(audioMessage.chatterId)", message: audioMessage)
                            for messageManagerDelegate in self.sendDelegateList {
                                messageManagerDelegate.messageHasSended?(audioMessage)
                            }

                    }
                }
            })
        }
        return audioMessage
    }
}












