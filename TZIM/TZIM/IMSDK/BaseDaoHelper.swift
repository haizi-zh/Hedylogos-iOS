//
//  BaseDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseDaoHelper: NSObject {
    class func tableIsExit(tableName: String, db:FMDatabase) -> Bool {
        var rs: FMResultSet = db.executeQuery("select count(*) as 'count' from sqlite_master where type ='table' and name = ?", withArgumentsInArray: [tableName])
            while (rs.next())
            {
                var count: Int32 = rs.intForColumn("count")
                if (0 == count) {
                    return false;
                } else {
                    return true;
                }
            }
        return true;
    }
}
