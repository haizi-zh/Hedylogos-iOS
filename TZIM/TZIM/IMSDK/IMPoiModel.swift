//
//  IMPoiModel.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc enum IMPoiType: Int {
    case City = 0
    case Guide = 1
    case Spot = 2
    case TravelNote = 3
    case Restaurant = 4
    case Shopping = 5
    case Hotel = 6
}

class IMPoiModel: NSObject {
    var poiId: String!
    var poiType: IMPoiType = .City  //默认是城市
    var poiName: String?
    var desc: String?
    var image: String?
    var address: String?
    var rating: String?
    var detailUrl: String?
    var price: String?
    var timeCost: String?
    
    func getContentStr() -> NSString? {
        var contentDic = NSMutableDictionary()
        contentDic.setObject(poiId, forKey: "id")
        if let poiName = poiName {
            contentDic.setObject(poiId, forKey: "id")

        }
        if let poiName = poiName {
            contentDic.setObject(poiName, forKey: "name")

        }
        if let desc = desc {
            contentDic.setObject(desc, forKey: "desc")

        }
        if let image = image {
            contentDic.setObject(image, forKey: "image")

        }
        if let address = address {
            contentDic.setObject(address, forKey: "address")

        }
        if let rating = rating {
            contentDic.setObject(rating, forKey: "rating")

        }
        if let url = detailUrl {
            contentDic.setObject(url, forKey: "detailUrl")

        }
        if let price = price {
            contentDic.setObject(price, forKey: "price")

        }
        if let timeCost = timeCost {
            contentDic.setObject(timeCost, forKey: "timeCost")

        }
        var jsonData = NSJSONSerialization.dataWithJSONObject(contentDic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var retStr = NSString(data:jsonData!, encoding: NSUTF8StringEncoding)
        return retStr
    }
}
