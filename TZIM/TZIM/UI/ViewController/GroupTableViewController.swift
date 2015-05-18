//
//  GroupTableViewController.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    
    var dataSource :Array<IMDiscussionGroup> = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var groupManager = IMDiscussionGroupManager.shareInstance()
        groupManager.asyncLoadAllMyDiscussionGroupsFromServer({ (isSuccess, errorCode, groupList) -> () in
            self.dataSource = groupList
            self.tableView.reloadData()
        })
    }

    @IBAction func addGroup(sender: AnyObject) {
        var imClient = IMClientManager.shareInstance()
        SVProgressHUD.show()
        var groupManager = IMDiscussionGroupManager.shareInstance()
       groupManager.asyncCreateDiscussionGroup([100001,100002,100003,100004,100014, 100015], completionBlock: { (isSuccess, errorCode, discussionGroup) -> () in
        if isSuccess {
            SVProgressHUD.showSuccessWithStatus("新建成功")
            self.dataSource.append(discussionGroup!)
            self.tableView.reloadData()
        } else {
            SVProgressHUD.showErrorWithStatus("新建失败")
        }
        
       })
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

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var manager = IMClientManager.shareInstance()
        var conversation = manager.conversationManager.getConversationWithChatterId(dataSource[indexPath.row].groupId)
        manager.conversationManager.addConversation(conversation)
        conversation.chatterId = dataSource[indexPath.row].groupId
        conversation.chatType = IMChatType.IMChatDiscussionGroupType
        var viewController = ChatViewController()
        viewController.conversation = conversation
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}





