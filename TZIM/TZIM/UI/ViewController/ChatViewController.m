//
//  ChatViewController.m
//  FireFighting
//
//  Created by liang pengshuai on 14-3-17.
//  Copyright (c) 2014年 liang pengshuai. All rights reserved.
//

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TZIM-swift.h"
@interface ChatViewController () <ChatConversationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatManagerAudioDelegate, AVAudioPlayerDelegate>
{
    float currentKeyboardHeigh;
    BOOL keyboardIsShow;
    float bubbleViewFrame;
}
@property (strong, nonatomic) NSMutableArray *chatDataSource;

@property (nonatomic) CGSize keyboardSize;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


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
    _conversation.isCurrentConversation = YES;
    _conversation.delegate = self;
    [_conversation resetConvsersationUnreadMessageCount];
    [_conversation getDefaultChatMessageInConversation:20];
    
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

        if (message.sendType == IMMessageSendTypeMessageSendMine) {
            if (message.messageType == IMMessageTypeImageMessageType) {
                NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld, localPath:%@", message.message, (long)message.localId, (long)message.serverId, ((ImageMessage*)message).localPath];
                
                UIImage *image = [UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath];

                bubbleData = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
                
            } else if (message.messageType == IMMessageTypeTextMessageType) {
                NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];

                bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            } else if (message.messageType == IMMessageTypeAudioMessageType) {
                NSString *content = [NSString stringWithFormat:@"声音文件： %@ 时长: %f, localId:%ld,  serverId:%ld", message.message, ((AudioMessage *)message).audioLength, (long)message.localId, (long)message.serverId];
                
                UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
                playBtn.backgroundColor = [UIColor blueColor];
                [playBtn setTitle:[NSString stringWithFormat:@"时长：%f", ((AudioMessage *)message).audioLength] forState:UIControlStateNormal];
                [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeMine insets:UIEdgeInsetsZero];
                playBtn.tag = _chatDataSource.count;
                [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            }
            
        } else {
            if (message.messageType == IMMessageTypeImageMessageType) {
                NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld, localPath:%@", message.message, (long)message.localId, (long)message.serverId, ((ImageMessage*)message).localPath];

                bubbleData = [NSBubbleData dataWithImage:[UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
                
            } else if (message.messageType == IMMessageTypeTextMessageType) {
                NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];

                bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
                
            } else if (message.messageType == IMMessageTypeAudioMessageType) {
                NSString *content = [NSString stringWithFormat:@"声音文件： %@ 时长: %f, localId:%ld,  serverId:%ld", message.message, ((AudioMessage *)message).audioLength, (long)message.localId, (long)message.serverId];
                
                UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
                playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];

                playBtn.backgroundColor = [UIColor blueColor];
                [playBtn setTitle:[NSString stringWithFormat:@"时长：%f", ((AudioMessage *)message).audioLength] forState:UIControlStateNormal];
                [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeSomeoneElse insets:UIEdgeInsetsZero];
                playBtn.tag = _chatDataSource.count;
                [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            }
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

- (void)dealloc {
    _conversation.isCurrentConversation = NO;
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

    if (message.sendType == IMMessageSendTypeMessageSendMine) {
        if (message.messageType == IMMessageTypeImageMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld, localPath:%@", message.message, (long)message.localId, (long)message.serverId, ((ImageMessage*)message).localPath];
            
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            
        } else if (message.messageType == IMMessageTypeTextMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            
        } else if (message.messageType == IMMessageTypeAudioMessageType) {
            NSString *content = [NSString stringWithFormat:@"声音文件： %@ 时长: %f, localId:%ld,  serverId:%ld", message.message, ((AudioMessage *)message).audioLength, (long)message.localId, (long)message.serverId];
            
            UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
            playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];

            playBtn.backgroundColor = [UIColor blueColor];
            [playBtn setTitle:[NSString stringWithFormat:@"时长：%f", ((AudioMessage *)message).audioLength] forState:UIControlStateNormal];
            [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeMine insets:UIEdgeInsetsZero];
            
            playBtn.tag = _chatDataSource.count;
            [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    } else {
        if (message.messageType == IMMessageTypeImageMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld, localPath:%@", message.message, (long)message.localId, (long)message.serverId, ((ImageMessage*)message).localPath];
            
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
            
        } else if (message.messageType == IMMessageTypeTextMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
            
        } else if (message.messageType == IMMessageTypeAudioMessageType) {
            NSString *content = [NSString stringWithFormat:@"声音文件： %@ 时长: %f, localId:%ld,  serverId:%ld", message.message, ((AudioMessage *)message).audioLength, (long)message.localId, (long)message.serverId];
            
            UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
            playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];

            playBtn.backgroundColor = [UIColor blueColor];
            [playBtn setTitle:[NSString stringWithFormat:@"时长：%f", ((AudioMessage *)message).audioLength] forState:UIControlStateNormal];
            [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeSomeoneElse insets:UIEdgeInsetsZero];
            playBtn.tag = _chatDataSource.count;
            [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    bubbleData.avatar = _myImage;
    [_chatDataSource addObject:bubbleData];
    [_bubbleTable reloadData];
    if (_bubbleTable.contentSize.height > self.view.bounds.size.height) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
}

- (IBAction)playAudio:(UIButton *)sender {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
        
    } else {
        AudioMessage *message = [_conversation.chatMessageList objectAtIndex:sender.tag];

        NSError *error;

        NSData *audioData = [NSData dataWithContentsOfFile:message.localPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
        _audioPlayer.volume = 0.8;
        _audioPlayer.currentTime = 0;
        [_audioPlayer prepareToPlay];

        if (error) {
            NSLog(@"%@", error);
            return;
        }
        _audioPlayer.delegate = self;
        [_audioPlayer play];
        NSLog(@"开始播放语音");
        if (message.audioStatus == IMAudioStatusUnRead) {
            message.audioStatus = IMAudioStatusReaded;
        }
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
    BaseMessage *message = [imClientManager.messageSendManager sendTextMessage:_messageToSend.text receiver:_conversation.chatterId conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}

- (IBAction)startRecrodAudio:(UIButton *)sender {
    _conversation.chatManager.chatManagerAudio.delegate = self;
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

- (void)audioRecordEnd:(NSString * __nonnull)audioPath
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    AudioMessage *audioMessage = [imClientManager.messageSendManager sendAudioMessageWithWavFormat:_conversation.chatterId conversationId:_conversation.conversationId wavAudioPath:audioPath progress:^(float progress) {
        
    }];
    
    [self addMessageToDataSource:audioMessage];
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
    
    ImageMessage *image = [imClientManager.messageSendManager sendImageMessage:_conversation.chatterId conversationId:_conversation.conversationId image:headerImage progress:^(float progressValue) {
        
    }];
    
    NSLog(@"info: %@", info);
    [self addMessageToDataSource:image];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完毕");
    _audioPlayer = nil;
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"播放被打断,error: %@", error);
}

@end










