//
//  LocationMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class LocationMessage: BaseMessage {
    var longitude: Float = 0
    var latitude: Float = 0
    var address: String = ""
    
    override init() {
        super.init()
        messageType = .LocationMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let lng = contentsDic.objectForKey("lng") as? Float {
            longitude = lng
        }
        if let lat = contentsDic.objectForKey("lat") as? Float {
            latitude = lat
        }
        if let name = contentsDic.objectForKey("name") as? String {
            address = name
        }
    }
}

