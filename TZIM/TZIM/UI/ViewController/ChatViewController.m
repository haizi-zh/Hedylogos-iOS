//
//  ChatViewController.m
//  FireFighting
//
//  Created by liang pengshuai on 14-3-17.
//  Copyright (c) 2014年 liang pengshuai. All rights reserved.
//

#import "ChatViewController.h"
#import "TZIM-swift.h"

@interface ChatViewController () <ChatConversationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    _conversation.delegate = self;
     keyboardIsShow = NO;
    _bubbleTable.bubbleDataSource = self;
    _bubbleTable.showAvatars = YES;
    
    if (!_chatDataSource) {
        _chatDataSource = [[NSMutableArray alloc] init];
    }
    
    NSLog(@"开始加载聊天数据");
    NSArray *chatlogArray = _conversation.chatMessageList;
    NSLog(@"结束加载聊天数据");

    _messageToSend.layer.cornerRadius = 3.0f;
    _messageToSend.delegate = self;
    

    for (BaseMessage *message in chatlogArray) {
        NSBubbleData *bubbleData;
        NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, message.localId, message.serverId];

        if (message.sendType == 1) {
            bubbleData = [[NSBubbleData alloc] initWithText:content date:[NSDate dateWithTimeIntervalSince1970:1429684002] type:BubbleTypeSomeoneElse];
        } else {
            bubbleData = [[NSBubbleData alloc] initWithText:content date:[NSDate dateWithTimeIntervalSince1970:1429684002] type:BubbleTypeMine];
        }
        bubbleData.avatar = _otherImage;
        [_chatDataSource addObject:bubbleData];
    }
    [_bubbleTable reloadData];
    [_bubbleTable scrollBubbleViewToBottomAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.title = _chatWith;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide :) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow :) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatView:) name:@"updateChatView" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateChatView" object:nil];
    
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

- (void)addMessageToDataSource:(BaseMessage *)message
{
    NSBubbleData *bubbleData;
    
    NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, message.localId, message.serverId];
    
    if (message.sendType == IMMessageSendTypeMessageSendMine) {
        
        bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    } else {
        bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    }
    bubbleData.avatar = _myImage;
    [_chatDataSource addObject:bubbleData];
    [_bubbleTable reloadData];
    if (_bubbleTable.contentSize.height > self.view.bounds.size.height) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }

}

#pragma mark - MessageManagerDelegate
- (void)receiverMessage:(BaseMessage* __nonnull)message
{
    [self addMessageToDataSource:message];
}

- (void)didSendMessage:(BaseMessage * __nonnull)message
{
    if (message.status == IMMessageStatusIMMessageFailed) {
        NSLog(@"didSendMessage: 发送失败");
    } else {
        NSLog(@"didSendMessage: 发送成功"); 
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
    [_messageToSend.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (_messageToSend.text.length == 0) {
        return;
    }
    
    NSLog(@"%lf", [[NSDate date] timeIntervalSince1970]);
       
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    BaseMessage *message = [imClientManager.messageSendManager sendTextMessage:_conversation.chatterId isChatGroup:NO message:_messageToSend.text];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}

- (IBAction)startRecrodAudio:(UIButton *)sender {
    [_conversation.chatManager beginRecordAudio];
}

- (IBAction)stopRecrodAudio:(UIButton *)sender {
    [_conversation.chatManager stopRecordAudio];
    
    
}

- (IBAction)selectImage:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *headerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    ImageMessage *image = [imClientManager.messageSendManager sendImageMessage:_conversation.chatterId isChatGroup:NO image:headerImage progress:^(float progressValue) {
        
    }];
    
    NSLog(@"info: %@", info);
    [self addMessageToDataSource:image];
}

@end










