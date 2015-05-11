//
//  FrendTableViewController.swift
//  TZIM
//
//  Created by liangpengshuai on 5/8/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class FrendTableViewController: UITableViewController {

    var dataSource: Array<FrendModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frendManager = FrendManager()
        dataSource = frendManager.getAllMyContacts() as! Array<FrendModel>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dataSource.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("frendCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = "\(dataSource[indexPath.row].userId)   \(dataSource[indexPath.row].nickName)"

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var manager = IMClientManager.shareInstance()
        var conversation = manager.conversationManager.getConversationWithChatterId(dataSource[indexPath.row].userId)
        manager.conversationManager.addConversation(conversation)
        var viewController = ChatViewController()
        viewController.conversation = conversation
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}






