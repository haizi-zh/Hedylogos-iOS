//
//  BaseDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseDaoHelper: NSObject {
    
    let dataBase: FMDatabase
    
    init(db: FMDatabase) {
        dataBase = db
        super.init()
    }
    
    init(db: FMDatabase, queue:FMDatabaseQueue) {
        dataBase = db
        super.init()
    }

    func tableIsExit(tableName: String) -> Bool {
        var sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [tableName])
        if (rs != nil) {
            while (rs.next())
            {
                var count: Int32 = rs.intForColumn("count")
                if (0 == count) {
                    return false;
                } else {
                    return true;
                }
            }
        }
        return false;
    }
    
    func selectAllTableName(#keyWord: String) -> NSArray {
        var retArray = NSMutableArray()
        
        var sql = "select * from sqlite_master where type ='table' and name like '\(keyWord)%'"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
        if (rs != nil) {
            while (rs.next())
            {
                if let tableName = rs.stringForColumn("name") {
                    retArray.addObject(tableName)
                }

            }
        }
        return retArray
    }
}
