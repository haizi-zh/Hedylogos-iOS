//
//  IMShoppingMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMShoppingMessage: BaseMessage {
    
    var shoppingId: String!
    var poiName: String?
    var image: String?
    var rating: String?
    var address: String?
    var price: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.ShoppingMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let id = contentsDic.objectForKey("id") as? String {
            shoppingId = id
        }
        if let name = contentsDic.objectForKey("name") as? String {
            poiName = name
        }
        if let image = contentsDic.objectForKey("image") as? String {
            self.image = image
        }
        if let price = contentsDic.objectForKey("price") as? String {
            self.price = price
        }
        if let rating = contentsDic.objectForKey("rating") as? String {
            self.rating = rating
        }
        if let address = contentsDic.objectForKey("address") as? String {
            self.address = address
        }
    }

   
}
