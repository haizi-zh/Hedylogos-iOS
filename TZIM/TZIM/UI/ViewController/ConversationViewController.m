//
//  ViewController.m
//  TZIM
//
//  Created by liangpengshuai on 4/13/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ConversationViewController.h"
#import "ChatViewController.h"

@interface ConversationViewController () <UITableViewDataSource, UITableViewDelegate, MessageManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    IMClientManager *imClientManager = [IMClientManager shareInstance];
    [imClientManager addMessageDelegate:self];
    [imClientManager.conversationManager updateConversationList];
    _dataSource = imClientManager.conversationManager.conversationList;
    [_tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

- (void)receiveNewMessage:(BaseMessage * __nonnull)message fromUser:(NSString * __nonnull)fromUser
{
    NSLog(@"收到一条消息");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"conversationCell"];
    }
    ChatConversation *conversation = [_dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ chatType:%d", conversation.chatterName, conversation.chatType];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", conversation.lastMessage.message];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatCtl = [[ChatViewController alloc] init];
    ChatConversation *conversation = [_dataSource objectAtIndex:indexPath.row];
    chatCtl.userID = conversation.chatterId;
    [self.navigationController pushViewController:chatCtl animated:YES];
}

@end
