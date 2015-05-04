//
//  MetadataManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class MetadataUploadManager: NSObject {
    
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
    class func uploadMetadata2Qiniu(metadataMessage: BaseMessage, token: String, key: String, metadata: NSData, progress: (progressValue: Float) -> (), completion:(isSuccess:Bool) -> ()) {
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
                completion(isSuccess: false)
            } else {
                completion(isSuccess: true)
            }
            }, option: opt)
    }
    
    
}


class MetadataDownloadManager:NSObject{

    class func asyncDownloadMetadataFrom(fromUrl url: NSURL, completion:(isSuccess:Bool, filePath:NSURL?) -> ()) {
        var currentSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10)
        
        currentSession.downloadTaskWithRequest(request, completionHandler: { (url: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if error == nil {
                completion(isSuccess: false, filePath: nil)
            } else {
                completion(isSuccess: true, filePath: response.URL)

            }
        })
        
    }
}
































