//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

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
        
        var imageData = UIImageJPEGRepresentation(image, 1)
        
        var imagePath = AccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("test.jpg")
        MetadataUploadManager.moveMetadata2Path(imageData, toPath: imagePath)
        
        var imageContentDic = ["localPath": imagePath]
        imageMessage.message = "\(imageContentDic)"
        
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(chatterId)", message: imageMessage)
            daoHelper.closeDB()
        }
        
        NSLog("开始上传  图像为\(image)")
        MetadataUploadManager.uploadMetadata2Qiniu(imageMessage, metadata: imageData, progress: { (progressValue) -> () in
            println("上传了: \(progressValue)")
        }) { (isSuccess) -> () in
            NSLog("上传成功")
            var contentDic = ["url":"http://7xistf.com1.z0.glb.clouddn.com/test.jpg", "h":image.size.height, "w":image.size.width]
            var contentStr = "\(contentDic)"
            imageMessage.message = contentStr
            
            self.sendMessage(imageMessage, receiver: chatterId, isChatGroup: isChatGroup)
        }
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
        
        var audioPath = AccountManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("test.wav")

        VoiceConverter.wavToAmr(wavAudioPath, amrSavePath: audioPath)
        
        var audioContentDic = ["localPath": audioPath]
        audioMessage.message = "\(audioContentDic)"
        
        println("开始发送语音消息： 消息内容为： \(audioMessage.message)")
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.insertChatMessage("chat_\(chatterId)", message: audioMessage)
            daoHelper.closeDB()
        }
        
        var audioData = NSData(contentsOfFile: audioPath)
        
        if let audioData = audioData {
            MetadataUploadManager.moveMetadata2Path(audioData, toPath: audioPath)
            MetadataUploadManager.uploadMetadata2Qiniu(audioMessage, metadata: audioData, progress: { (progressValue) -> () in
                
                }) { (isSuccess) -> () in
                    if isSuccess {
                        println("上传成功")
                    }
                    self.sendMessage(audioMessage, receiver: chatterId, isChatGroup: isChatGroup)
            }
        }
        return audioMessage
    }
}












