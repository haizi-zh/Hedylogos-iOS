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
    let databaseQueue: FMDatabaseQueue
    
    init(db: FMDatabase, dbQueue: FMDatabaseQueue) {
        dataBase = db
        databaseQueue = dbQueue
        super.init()
    }

    func tableIsExit(tableName: String) -> Bool {
        
        var retResult = false
        
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [tableName])
            if (rs != nil) {
                while (rs.next())
                {
                    var count: Int32 = rs.intForColumn("count")
                    if (0 == count) {
                        retResult =  false;
                    } else {
                        retResult =  true;
                    }
                }
            }
        }
        return retResult;
    }
    
    func selectAllTableName(#keyWord: String) -> NSArray {
        var retArray = NSMutableArray()
        
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
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
        }
        return retArray
    }
}
