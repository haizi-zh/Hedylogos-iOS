//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol FrendManagerProtocol {
    func addFrend(frend: FrendModel)
}

class FrendManager: NSObject, FrendManagerProtocol {
    func addFrend(frend: FrendModel) {
        var daoHelper = DaoHelper()
        if daoHelper.openDB() {
            daoHelper.addFrend2DB(frend)
            daoHelper.closeDB()
        }
    }
}
