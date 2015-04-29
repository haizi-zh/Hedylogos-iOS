//
//  MetadataManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let QiniuToken = "pUj-ZwQ5-s6m8aZ8RbFwnFNxUQccPHjwJP_SR1LX:NkFPbzZR8MOUtXG0DoPFUSLe3cA=:eyJzY29wZSI6ImhlaGVjZW8iLCJkZWFkbGluZSI6MTQzMDIxMDc4OH0="

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
    上传二进制文件到七牛服务器
    
    :param: metadataMessage 二进制消息
    :param: metadata        二进制文件实体
    :param: progress        上传进度回调
    :param: completion      完成回调
    */
    class func uploadMetadata2Qiniu(metadataMessage: BaseMessage, metadata: NSData, progress: (progressValue: Float) -> (), completion:(isSuccess:Bool) -> ()) {
        var uploadManager = QNUploadManager()
        
        var opt = QNUploadOption(mime: "text/plain", progressHandler: { (key: String!, progressValue: Float) -> Void in
            progress(progressValue: progressValue)
            }, params: ["st" : "st"], checkCrc: true, cancellationSignal: nil)
        
        var token: String?
        
        uploadManager.putData(metadata, key: metadataMessage.metaDataId, token: QiniuToken, complete: { (info: QNResponseInfo!, key: String!, resp:Dictionary!) -> Void in
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
































