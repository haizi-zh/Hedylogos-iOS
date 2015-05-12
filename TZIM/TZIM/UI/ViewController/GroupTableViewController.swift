//
//  GroupTableViewController.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    
    var dataSource :Array<IMGroupModel> = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var imClient = IMClientManager.shareInstance()
        imClient.groupManager.asyncLoadAllMyGroupsFromServer({ (isSuccess, errorCode, groupList) -> () in
            self.dataSource = groupList
            self.tableView.reloadData()
        })
    }

    @IBAction func addGroup(sender: AnyObject) {
        var imClient = IMClientManager.shareInstance()
        SVProgressHUD.show()
        imClient.groupManager.asyncCreateGroup(subject: "第一个群组", description: "大家好", isPublic: true, invitees: [100001, 100002], welcomeMessage: "大家好") { (isSuccess, errorCode, retMessage) -> () in
            SVProgressHUD.dismiss()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var group = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "\(group.groupId)"
        cell.detailTextLabel?.text = "\(group.subject)  \(group.conversationId)"

        return cell
    }
}





