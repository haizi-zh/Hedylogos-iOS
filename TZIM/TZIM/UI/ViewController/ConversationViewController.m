//
//  ViewController.m
//  TZIM
//
//  Created by liangpengshuai on 4/13/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ConversationViewController.h"
#import "ChatViewController.h"

@interface ConversationViewController () <MessageTransferManagerDelegate, ChatConversationManagerDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    [imClientManager addMessageDelegate:self];
    imClientManager.conversationManager.delegate = self;
    _dataSource = [[imClientManager.conversationManager getConversationList] mutableCopy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

- (void)receiveNewMessage:(BaseMessage * __nonnull)message 
{
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ chatType:%ld", conversation.chatterName, (long)conversation.chatType];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", conversation.lastLocalMessage.message];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatConversation *conversation = [_dataSource objectAtIndex:indexPath.row];
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    [imClientManager.conversationManager removeConversation:conversation.chatterId];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatCtl = [[ChatViewController alloc] init];
    ChatConversation *conversation = [_dataSource objectAtIndex:indexPath.row];
    chatCtl.userID = conversation.chatterId;
    chatCtl.conversation = conversation;
    [self.navigationController pushViewController:chatCtl animated:YES];
}

#pragma mark - ChatConversationManagerDelegate
- (void)conversationsHaveAdded:(NSArray * __nonnull)conversationList
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    NSLog(@"ChatConversationManagerDelegate - conversationListNeedUpdate");
    _dataSource = [imClientManager.conversationManager.getConversationList mutableCopy];
    [self.tableView reloadData];
}

- (void)conversationsHaveRemoved:(NSArray * __nonnull)conversationList
{
    for (ChatConversation *addedConversation in conversationList) {
        for (ChatConversation *conversation in _dataSource) {
            if (addedConversation.chatterId == conversation.chatterId) {
                NSInteger row = [_dataSource indexOfObject:conversation];
                [_dataSource removeObject:conversation];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
}

- (void)conversationStatusHasChanged:(ChatConversation * __nonnull)conversation
{
    for (ChatConversation *oldConversation in _dataSource) {
        if (oldConversation.chatterId == conversation.chatterId) {
            NSInteger index = [_dataSource indexOfObject:oldConversation];
            [_dataSource replaceObjectAtIndex:index withObject:conversation];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
}

@end






