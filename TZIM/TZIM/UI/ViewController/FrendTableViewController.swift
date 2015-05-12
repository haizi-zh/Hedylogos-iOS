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
           }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let frendManager = FrendManager()
        dataSource = frendManager.getAllMyContacts() as! Array<FrendModel>
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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



