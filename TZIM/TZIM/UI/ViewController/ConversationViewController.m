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
    
    for (int i=0; i<400; i++) {
        FrendModel *frend = [[FrendModel alloc] init];
        frend.userId = i;
        frend.nickName = [NSString stringWithFormat:@"%d号葫芦娃", i];
        frend.avatar = @"http://taozi-uploads.qiniudn.com/avt_1000061423640395342.jpg";
        frend.avatarSmall = @"http://taozi-uploads.qiniudn.com/avt_1000061423640395342.jpg";
        frend.sex = i%2;
        frend.signature = @"我是一只爱旅行的小麻雀";
        frend.memo = @"胖大海";
        frend.type = i%2;
        [imClientManager.frendManager addFrend:frend];
    }
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
    cell.textLabel.text = [NSString stringWithFormat:@"%d", conversation.chatterId];
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
