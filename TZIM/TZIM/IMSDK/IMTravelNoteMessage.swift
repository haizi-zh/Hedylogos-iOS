//
//  IMTravelNoteMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMTravelNoteMessage: BaseMessage {
    
    var travelNoteId: String!
    var name: String?
    var image: String?
    var desc: String?
    var detailUrl: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.TravelNoteMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let id = contentsDic.objectForKey("id") as? String {
            travelNoteId = id
        }
        if let name = contentsDic.objectForKey("name") as? String {
            self.name = name
        }
        if let image = contentsDic.objectForKey("image") as? String {
            self.image = image
        }
        if let desc = contentsDic.objectForKey("desc") as? String {
            self.desc = desc
        }
        if let url = contentsDic.objectForKey("detailUrl") as? String {
            self.detailUrl = url
        }
    }

   
}
