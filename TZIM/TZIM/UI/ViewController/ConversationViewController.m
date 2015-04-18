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

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    [imClientManager.messageManager addMessageDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatCtl = [[ChatViewController alloc] init];
    [self.navigationController pushViewController:chatCtl animated:YES];
}

@end
