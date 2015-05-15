//
//  IMPoiModel.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum IMPoiType: Int {
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
    var poiType: IMPoiType!
    var poiName: String?
    var desc: String?
    var image: String?
    var address: String?
    var rating: String?
    var url: String?
    var price: String?
    var timeCost: String?
   
}
