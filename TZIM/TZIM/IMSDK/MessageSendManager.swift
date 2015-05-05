//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
import AVFoundation

private let messageSendManager = MessageSendManager()

class MessageSendManager: MessageTransferManager {
    var messageManagerDelegate: MessageTransferManagerDelegate?
    
    class func shareInstance() -> MessageSendManager {
        return messageSendManager
    }
    
//MARK: private methods
    
    private func sendMessage(message: BaseMessage, receiver: Int, isChatGroup: Bool) {
        var daoHelper = DaoHelper()
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).sendNewMessage?(message)
        }
        var accountManager = AccountManager.shareInstance()
        NetworkTransportAPI.asyncSendMessage(MessageManager.prepareMessage2Send(receiverId: receiver, senderId: accountManager.userId, message: message), completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
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
            if daoHelper.openDB() {
                daoHelper.updateMessageInDB("chat_\(receiver)", message: message)
                daoHelper.closeDB()
            }
            for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                (messageManagerDelegate as! MessageTransferManagerDelegate).messageHasSended?(message)
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
    func sendTextMessage(chatterId: Int, isChatGroup: Bool, message: String) -> TextMessage {
        var textMessage = TextMessage()
        textMessage.createTime = Int(NSDate().timeIntervalSince1970)
        textMessage.status = IMMessageStatus.IMMessageSending
        textMessage.message = message
        textMessage.chatterId = chatterId
        textMessage.sendType = IMMessageSendType.MessageSendMine
        
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(chatterId)", message: textMessage)
            daoHelper.closeDB()
        }
        
        sendMessage(textMessage, receiver: chatterId, isChatGroup: isChatGroup)
        return textMessage
    }
    
    /**
    发送一条图片消息
    
    :param: chatterId
    :param: isChatGroup
    :param: image   发送的图片，必选
    :returns:
    */
    func sendImageMessage(chatterId: Int, isChatGroup: Bool, image: UIImage, progress:(progressValue: Float) -> ()) -> ImageMessage {
        var imageMessage = ImageMessage()
        imageMessage.chatterId = chatterId
        imageMessage.sendType = IMMessageSendType.MessageSendMine
        imageMessage.createTime = Int(NSDate().timeIntervalSince1970)
        imageMessage.status = IMMessageStatus.IMMessageSending

        var imageData = UIImageJPEGRepresentation(image, 1)
        
        var metadataId = NSUUID().UUIDString
        var imagePath = AccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(metadataId).jpeg")
        MetadataUploadManager.moveMetadata2Path(imageData, toPath: imagePath)
        
        imageMessage.localPath = imagePath
        
        var imageContentDic = NSMutableDictionary()
        imageContentDic.setObject(metadataId, forKey: "metadataId")
        imageMessage.message = imageMessage.contentsStrWithJsonObjc(imageContentDic) as! String
        
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(chatterId)", message: imageMessage)
            daoHelper.closeDB()
        }
        NSLog("开始上传  图像为\(image)")
        
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).sendNewMessage?(imageMessage)
        }
        
        MetadataUploadManager.asyncRequestUploadToken2SendMessage(1, completionBlock: { (isSuccess, key, token) -> () in
            if isSuccess {
                MetadataUploadManager.uploadMetadata2Qiniu(imageMessage, token: token!, key: key!, metadata: imageData, progress: { (progressValue) -> () in
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
                        if daoHelper.openDB() {
                            daoHelper.updateMessageInDB("chat_\(imageMessage.chatterId)", message: imageMessage)
                            daoHelper.closeDB()
                        }
                        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                            (messageManagerDelegate as! MessageTransferManagerDelegate).messageHasSended?(imageMessage)
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
    func sendAudioMessageWithWavFormat(chatterId: Int, isChatGroup: Bool, wavAudioPath: String, progress:(progressValue: Float) -> ()) -> AudioMessage {
        var audioMessage = AudioMessage()
        audioMessage.chatterId = chatterId
        audioMessage.sendType = IMMessageSendType.MessageSendMine
        audioMessage.createTime = Int(NSDate().timeIntervalSince1970)
        audioMessage.status = IMMessageStatus.IMMessageSending
        
        var metadataId = NSUUID().UUIDString

        var audioPath = AccountManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("\(metadataId).amr")
        
        VoiceConverter.wavToAmr(wavAudioPath, amrSavePath: audioPath)
        
        var audioContentDic = NSMutableDictionary()
        audioContentDic.setObject(metadataId, forKey: "metadataId")

        if let url = NSURL(string: audioPath) {
            var play = AVAudioPlayer(contentsOfURL: url, error: nil)
            audioContentDic.setObject(play.duration, forKey: "length")
        }
        
        audioMessage.localPath = AccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(metadataId).amr")

        audioMessage.message = audioMessage.contentsStrWithJsonObjc(audioContentDic) as! String
        
        println("开始发送语音消息： 消息内容为： \(audioMessage.message)")
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(chatterId)", message: audioMessage)
            daoHelper.closeDB()
        }
        
        for messageManagerDelegate in super.messageTransferManagerDelegateArray {
            (messageManagerDelegate as! MessageTransferManagerDelegate).sendNewMessage?(audioMessage)
        }
        
        var audioData = NSData(contentsOfFile: audioPath)
        
        if let audioData = audioData {
        
            MetadataUploadManager.asyncRequestUploadToken2SendMessage(1, completionBlock: { (isSuccess, key, token) -> () in
                if isSuccess {
                    MetadataUploadManager.uploadMetadata2Qiniu(audioMessage, token: token!, key: key!, metadata: audioData, progress: { (progressValue) -> () in
                        println("上传了: \(progressValue)")
                        })
                        { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
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
                            if daoHelper.openDB() {
                                daoHelper.updateMessageInDB("chat_\(audioMessage.chatterId)", message: audioMessage)
                                daoHelper.closeDB()
                            }
                            for messageManagerDelegate in super.messageTransferManagerDelegateArray {
                                (messageManagerDelegate as! MessageTransferManagerDelegate).messageHasSended?(audioMessage)
                            }
                    }
                }
            })
        }
        return audioMessage
    }
}












