//
//  MetadataManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MetaDataManager: NSObject {
    
    /**
    将二进制文件移动到某个路径下
    
    :param: fileData 需要移动的数据
    :param: toPath   将要移动到的路径
    */
    class func moveMetadata2Path(metadata: NSData, toPath: String) {
        var fileManager = NSFileManager.defaultManager()
        fileManager.createFileAtPath(toPath, contents: metadata, attributes: nil)
    }
    
    /**
    将某个路径下的二进制文件移动到某个路径下
    
    :param: fileData 需要移动的数据
    :param: toPath   将要移动到的路径
    */

    class func moveMetadataFromOnePath2AnotherPath(fromPath: String, toPath: String) {
        if let metadata = NSData(contentsOfFile: fromPath) {
            MetaDataManager.moveMetadata2Path(metadata, toPath: toPath)
        }
    }
}

class MetadataUploadManager: NSObject {
    
    /**
    异步获取上传的 token 和 key
    
    :param: completionBlock 获取完后的回调
    */
    class func asyncRequestUploadToken2SendMessage(actionCode: Int, completionBlock: (isSuccess: Bool, key: String?, token: String?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        manager.POST(requestQiniuTokenToUploadMetadata, parameters: ["action": actionCode], success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let reslutDic = responseObject.objectForKey("result") as? NSDictionary {
                    var key: String? = (reslutDic.objectForKey("key") as! String)
                    var token: String? = (reslutDic.objectForKey("token") as! String)
                    completionBlock(isSuccess: true, key: key, token: token)
                    
                } else {
                    completionBlock(isSuccess: false, key: nil, token: nil)
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                completionBlock(isSuccess: false, key: nil, token: nil)
                print(error)
        }
    
    }
   
    /**
    上传二进制文件到七牛服务器
    
    :param: metadataMessage 二进制消息
    :param: metadata        二进制文件实体
    :param: progress        上传进度回调
    :param: completion      完成回调
    */
    class func uploadMetadata2Qiniu(metadataMessage: BaseMessage, token: String, key: String, metadata: NSData, progress: (progressValue: Float) -> (), completion:(isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        var uploadManager = QNUploadManager()
        
        var params = NSMutableDictionary()
        params.setObject("\(metadataMessage.chatterId)", forKey: "x:receiver")
        params.setObject("\(AccountManager.shareInstance().userId)", forKey: "x:sender")
        params.setObject("\(metadataMessage.messageType.rawValue)", forKey: "x:msgType")
        
        var opt = QNUploadOption(mime: "text/plain", progressHandler: { (key: String!, progressValue: Float) -> Void in
            progress(progressValue: progressValue)
            }, params: params as [NSObject : AnyObject], checkCrc: true, cancellationSignal: nil)
    
        uploadManager.putData(metadata, key: key, token: token, complete: { (info: QNResponseInfo!, key: String!, resp:Dictionary!) -> Void in
            println("resp: \(resp)")
            if let error = info.error {
                println("上传二进制文件出错： \(error)")
                completion(isSuccess: false, errorCode:0, retMessage: nil)
            } else {
                completion(isSuccess: true, errorCode:0, retMessage: resp["result"] as? NSDictionary)
            }
            }, option: opt)
    }
}

class MetadataDownloadManager:NSObject{
    
    /**
    异步下载图片的预览图片信息
    :param: url        图片的 url
    :param: completion 下载的回掉
    */
    class func asyncDownloadThumbImage(imageMessage: ImageMessage, completion:(isSuccess:Bool, retMessage:ImageMessage) -> ()) {
        var currentSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        if let url = NSURL(string: imageMessage.thumbUrl!) {
            var request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10)
            
            var downloadTask = currentSession.downloadTaskWithRequest(request, completionHandler: { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                if error != nil {
                    NSLog("下载图片预览图失败 失败原因是: \(error)")
                    completion(isSuccess: false, retMessage: imageMessage)
                } else {
                    var imagePath = AccountManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(imageMessage.metadataId!).jpeg")
                    
                    if let imageData = NSData(contentsOfURL: url) {
                        var fileManager = NSFileManager.defaultManager()
                        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
                        NSLog("下载图片预览图成功 保存后的地址为: \(imagePath)")
                        imageMessage.localPath = imagePath
                        imageMessage.updateMessageContent()
                        var daoHelper = DaoHelper()
                        daoHelper.openDB()
                        daoHelper.updateMessageContents("chat_\(imageMessage.chatterId)", message: imageMessage)
                        daoHelper.closeDB()
                    }
                    completion(isSuccess: true, retMessage: imageMessage)
                }
            })
            
            downloadTask.resume()
            
        } else {
            completion(isSuccess: false, retMessage: imageMessage)
        }
    }
    
    /**
    异步下载语音消息信息
    :param: url        图片的 url
    :param: completion 下载的回掉
    */
    class func asyncDownloadAudioData(audioMessage: AudioMessage, completion:(isSuccess:Bool, retMessage:AudioMessage) -> ()) {
        var currentSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        if let url = NSURL(string: audioMessage.remoteUrl!) {
            var request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10)
            
            var downloadTask = currentSession.downloadTaskWithRequest(request, completionHandler: { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                if error != nil {
                    NSLog("下载语音失败 失败原因是: \(error)")
                    completion(isSuccess: false, retMessage: audioMessage)
                } else {
                    var audioWavPath = AccountManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("\(audioMessage.metadataId!).wav")
                    
                    var tempAmrPath = AccountManager.shareInstance().userTempPath.stringByAppendingPathComponent("\(audioMessage.metadataId!).amr")
                    
                    if let imageData = NSData(contentsOfURL: url) {
                        var fileManager = NSFileManager.defaultManager()
                        fileManager.createFileAtPath(tempAmrPath, contents: imageData, attributes: nil)

                        VoiceConverter.amrToWav(tempAmrPath, wavSavePath: audioWavPath)
                        NSLog("下载语音成功 保存后的地址为: \(audioWavPath)")
                        fileManager.removeItemAtPath(tempAmrPath, error: nil)

                        audioMessage.localPath = audioWavPath
                        audioMessage.updateMessageContent()
                        var daoHelper = DaoHelper()
                        daoHelper.openDB()
                        daoHelper.updateMessageContents("chat_\(audioMessage.chatterId)", message: audioMessage)
                        daoHelper.closeDB()
                    }
                    completion(isSuccess: true, retMessage: audioMessage)
                }
            })
            
            downloadTask.resume()
            
        } else {
            completion(isSuccess: false, retMessage: audioMessage)
        }
    }

    
    
}
































