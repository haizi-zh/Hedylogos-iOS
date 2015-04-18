//
//  ChatViewController.m
//  FireFighting
//
//  Created by liang pengshuai on 14-3-17.
//  Copyright (c) 2014年 liang pengshuai. All rights reserved.
//

#import "ChatViewController.h"
#import "TZIM-swift.h"

@interface ChatViewController () <MessageManagerDelegate>
{
    float currentKeyboardHeigh;
    BOOL keyboardIsShow;
    float bubbleViewFrame;
}
@property (strong, nonatomic) NSMutableArray *chatDataSource;

@property (nonatomic) CGSize keyboardSize;


@end

@implementation ChatViewController

static NSString *messageCellIdentifier = @"messageCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    [imClientManager.messageManager addMessageDelegate:self];
    
     keyboardIsShow = NO;
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    _bubbleTable.bubbleDataSource = self;
    _bubbleTable.showAvatars = YES;
  //  _bubbleTable.snapInterval = 120;

    if (!_chatDataSource) {
        _chatDataSource = [[NSMutableArray alloc]init];
    }
    _messageToSend.layer.cornerRadius = 3.0f;
    _messageToSend.delegate = self;
    NSMutableArray *chatlogArray;
    for (NSDictionary *dic in chatlogArray) {
        NSBubbleData *chatData;
        if ([[dic objectForKey:@"chatType"] isEqualToString:@"receiver"]) {
            NSDate *chatdate = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"chatDate"] doubleValue]-8*3600];

            chatData = [[NSBubbleData alloc] initWithText:[dic objectForKey:@"detail"] date:chatdate type:BubbleTypeSomeoneElse];
            chatData.avatar = _otherImage;

        } else {
            NSDate *chatdate = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"chatDate"] doubleValue]-8*3600];
            
            chatData = [[NSBubbleData alloc] initWithText:[dic objectForKey:@"detail"] date:chatdate type:BubbleTypeMine];
            chatData.avatar = _myImage;
        }
        
        [_chatDataSource addObject:chatData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = _chatWith;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide :) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow :) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatView:) name:@"updateChatView" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateChatView" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_chatDataSource.count>0) {
        if ((int)[_chatDataSource objectAtIndex:(_chatDataSource.count-1)] > 380) {
            [self.bubbleTable scrollBubbleViewToBottomAnimated:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateChatView:(NSNotification *)noti
{
    if ([[noti.object objectForKey:@"fromid"] isEqualToString:_otherUserID]) {
        NSBubbleData *bubbleData = [NSBubbleData dataWithText:[noti.object objectForKey:@"msgdetail"] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        bubbleData.avatar = _otherImage;
        [_chatDataSource addObject:bubbleData];
        [_bubbleTable reloadData];
        if ((int)bubbleData > 380) {
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        }
    }
}

- (void)TouchDownViewToHideKeyboard
{
    [_messageToSend resignFirstResponder];
}

#pragma mark - MessageManagerDelegate

- (void)receiveNewMessage:(BaseMessage *)message fromUser:(NSString *)fromUser
{
    NSMutableDictionary *insertToDBdic = [[NSMutableDictionary alloc] init];
    [insertToDBdic setObject:@"我收到一条新消息" forKey:@"msgdetail"];
    [insertToDBdic setObject:[NSNumber numberWithInt:1] forKey:@"msgstatus"];
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSInteger intervalfrom1970 = [localeDate timeIntervalSince1970];
    [insertToDBdic setObject:[NSNumber numberWithDouble:intervalfrom1970] forKey:@"msgdate"];
    
    NSBubbleData *bubbleData = [NSBubbleData dataWithText:@"我收到一条新消息" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    bubbleData.avatar = _myImage;
    [_chatDataSource addObject:bubbleData];
    [_bubbleTable reloadData];
    if (_bubbleTable.contentSize.height > self.view.bounds.size.height) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }

    
}

#pragma -UIBubbleTableViewDataSource

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [_chatDataSource count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [_chatDataSource objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)KeyboardWillShow :(NSNotification*)aNotification
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TouchDownViewToHideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.bubbleTable addGestureRecognizer:tap];
    
    CGRect windowSize = [[UIScreen mainScreen] bounds];
    float kbEndHeigh = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    float kbBeginHeigh = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size.height;
    float kbBeginY = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].origin.y;
    
    if (kbBeginY == windowSize.size.height) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = _textView.frame;
            frame.origin.y -= kbEndHeigh;
            _textView.frame = frame;
        }];
    } else if(kbBeginHeigh < kbEndHeigh) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = _textView.frame;
            frame.origin.y -= (kbEndHeigh - kbBeginHeigh);
            _textView.frame = frame;
        }];
    } else if(kbBeginHeigh > kbEndHeigh) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = _textView.frame;
            frame.origin.y += (kbBeginHeigh - kbEndHeigh);
            _textView.frame = frame;
        }];
    }

}

- (void)KeyboardWillHide:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //通过传递通知类型，得到键盘的大小。
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = _textView.frame;
            frame.origin.y += kbSize.height;
            _textView.frame = frame;
        }];
}

- (void)sendMessage
{
    NSMutableDictionary *insertToDBdic = [[NSMutableDictionary alloc] init];
    [insertToDBdic setObject:_messageToSend.text forKey:@"msgdetail"];
    [insertToDBdic setObject:[NSNumber numberWithInt:1] forKey:@"msgstatus"];
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSInteger intervalfrom1970 = [localeDate timeIntervalSince1970];
    [insertToDBdic setObject:[NSNumber numberWithDouble:intervalfrom1970] forKey:@"msgdate"];

    NSBubbleData *bubbleData = [NSBubbleData dataWithText:_messageToSend.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    bubbleData.avatar = _myImage;
    [_chatDataSource addObject:bubbleData];
    [_bubbleTable reloadData];
    if (_bubbleTable.contentSize.height > self.view.bounds.size.height) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
    
    ChatManager *chatManager = [[ChatManager alloc] init];
    NSLog(@"%lf", [[NSDate date] timeIntervalSince1970]);
    BaseMessage *chatMsg = [[BaseMessage alloc] initWithTLocalId:1000 tServerId:10001 tStatus:1 tCreateTime:[[NSDate date] timeIntervalSince1970] tSendType:1];
    chatMsg.messageContent = _messageToSend.text;
    
    [chatManager asyncSendMessage:chatMsg receiver:@"liang" isChatGroup:NO completionBlock:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            NSLog(@"hello world");
        }
    }];
    [_messageToSend setText:@""];
}

- (IBAction)audioRecord:(id)sender {
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    return YES;
}

@end










