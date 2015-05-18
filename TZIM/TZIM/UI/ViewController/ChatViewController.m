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
        bubbleData = [self getBubbleDataWith:message];

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
    NSBubbleData *bubbleData = [self getBubbleDataWith:message];
    bubbleData.avatar = _myImage;
    [_chatDataSource addObject:bubbleData];
    [_bubbleTable reloadData];
    if (_bubbleTable.contentSize.height > self.view.bounds.size.height) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
}

- (NSBubbleData *)getBubbleDataWith:(BaseMessage *) message
{
    
    NSBubbleData *bubbleData;
    
    if (message.sendType == IMMessageSendTypeMessageSendMine) {
        if (message.messageType == IMMessageTypeImageMessageType) {
            
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            
        } else if (message.messageType == IMMessageTypeTextMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
            
        } else if (message.messageType == IMMessageTypeAudioMessageType) {
            
            UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
            playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            
            playBtn.backgroundColor = [UIColor blueColor];
            [playBtn setTitle:[NSString stringWithFormat:@"时长：%f 是否已听 %ld", ((AudioMessage *)message).audioLength, (long)((AudioMessage *)message).audioStatus] forState:UIControlStateNormal];
            [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeMine insets:UIEdgeInsetsZero];
            
            playBtn.tag = _chatDataSource.count;
            [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (message.messageType == IMMessageTypeLocationMessageType) {
                UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
                locationBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
                
                locationBtn.backgroundColor = [UIColor greenColor];
                [locationBtn setTitle:[NSString stringWithFormat:@"addr: %@  lat：%f lng: %f",((LocationMessage *)message).address, ((LocationMessage *)message).latitude, ((LocationMessage *)message).longitude] forState:UIControlStateNormal];
                [locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                bubbleData  = [NSBubbleData dataWithView:locationBtn date:[NSDate date] type:BubbleTypeMine insets:UIEdgeInsetsZero];
                locationBtn.tag = _chatDataSource.count;
        } else if (message.messageType == IMMessageTypeCityPoiMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld cityId：%@", (long)message.localId, (long)message.serverId, ((IMCityMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeSpotMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld spotId：%@", (long)message.localId, (long)message.serverId, ((IMSpotMessage *)message).spotName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeGuideMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld guide：%@", (long)message.localId, (long)message.serverId, ((IMGuideMessage *)message).guideName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeTravelNoteMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld Note：%@", (long)message.localId, (long)message.serverId, ((IMTravelNoteMessage *)message).name];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeRestaurantMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld RestaurantId：%@", (long)message.localId, (long)message.serverId, ((IMRestaurantMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeShoppingMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld ShoppintId：%@", (long)message.localId, (long)message.serverId, ((IMShoppingMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        } else if (message.messageType == IMMessageTypeHotelMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld HotelId：%@", (long)message.localId, (long)message.serverId, ((IMRestaurantMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
        }

        
    } else {
        if (message.messageType == IMMessageTypeImageMessageType) {
            
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
            
        } else if (message.messageType == IMMessageTypeTextMessageType) {
            NSString *content = [NSString stringWithFormat:@"%@, localId:%ld,  serverId:%ld", message.message, (long)message.localId, (long)message.serverId];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
            
        } else if (message.messageType == IMMessageTypeAudioMessageType) {
            
            UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
            playBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            
            playBtn.backgroundColor = [UIColor blueColor];
            [playBtn setTitle:[NSString stringWithFormat:@"时长：%f 是否已听 %ld", ((AudioMessage *)message).audioLength, (long)((AudioMessage *)message).audioStatus] forState:UIControlStateNormal];
            [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bubbleData  = [NSBubbleData dataWithView:playBtn date:[NSDate date] type:BubbleTypeSomeoneElse insets:UIEdgeInsetsZero];
            playBtn.tag = _chatDataSource.count;
            [playBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (message.messageType == IMMessageTypeLocationMessageType) {
            UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
            locationBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            
            locationBtn.backgroundColor = [UIColor greenColor];
            [locationBtn setTitle:[NSString stringWithFormat:@"addr: %@  lat：%f lng: %f",((LocationMessage *)message).address, ((LocationMessage *)message).latitude, ((LocationMessage *)message).longitude] forState:UIControlStateNormal];
            [locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bubbleData  = [NSBubbleData dataWithView:locationBtn date:[NSDate date] type:BubbleTypeSomeoneElse insets:UIEdgeInsetsZero];
            locationBtn.tag = _chatDataSource.count;
            
        } else if (message.messageType == IMMessageTypeCityPoiMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld cityId：%@", (long)message.localId, (long)message.serverId, ((IMCityMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeSpotMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld spotId：%@", (long)message.localId, (long)message.serverId, ((IMSpotMessage *)message).spotName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeGuideMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld guide：%@", (long)message.localId, (long)message.serverId, ((IMGuideMessage *)message).guideName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeTravelNoteMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld note：%@", (long)message.localId, (long)message.serverId, ((IMTravelNoteMessage *)message).name];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeRestaurantMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld restaurant：%@", (long)message.localId, (long)message.serverId, ((IMRestaurantMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeShoppingMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld ShopId：%@", (long)message.localId, (long)message.serverId, ((IMShoppingMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        } else if (message.messageType == IMMessageTypeHotelMessageType) {
            NSString *content = [NSString stringWithFormat:@"localId:%ld,  serverId:%ld hotelId：%@", (long)message.localId, (long)message.serverId, ((IMRestaurantMessage *)message).poiName];
            
            bubbleData = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        }

    }
    return bubbleData;
    
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
        for (int i = 0; i < self.chatDataSource.count; i++) {
            BaseMessage *msg = self.conversation.chatMessageList[i];
            if (message.localId == msg.localId) {
                NSBubbleData *bubbleData = [self getBubbleDataWith:message];
                [self.chatDataSource replaceObjectAtIndex:i withObject:bubbleData];
                [self.bubbleTable reloadData];
                return;
            }
        }
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
    
    BaseMessage *message = [imClientManager.messageSendManager sendTextMessage:_messageToSend.text receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
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
- (IBAction)sendLocation:(id)sender {
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    LocationModel *model = [[LocationModel alloc] init];
    model.longitude = 116.24;
    model.latitude = 39.28;
    model.address = @"北京";
    
    BaseMessage *message = [imClientManager.messageSendManager sendLocationMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}
- (IBAction)sendCityPoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"100032132";
    model.poiName = @"北京";
    model.poiType = IMPoiTypeCity;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];

    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];

}
- (IBAction)sendSpotPoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"100001231";
    model.poiName = @"天安门";
    model.poiType = IMPoiTypeSpot;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}
- (IBAction)sendGuidePoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"10000123";
    model.poiName = @"东莞一晚游";
    model.poiType = IMPoiTypeGuide;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}
- (IBAction)sendTravelnotePoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"100002121";
    model.poiName = @"山东游记";
    model.poiType = IMPoiTypeTravelNote;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}

- (IBAction)sendShopPoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"1000212";
    model.poiName = @"香港购物";
    model.poiType = IMPoiTypeShopping;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}

- (IBAction)sendFoodPoi:(id)sender {
    IMPoiModel *model = [[IMPoiModel alloc] init];
    model.poiId = @"10000123";
    model.poiName = @"吃遍天下";
    model.poiType = IMPoiTypeRestaurant;
    model.image = @"http://imageurl....";
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendPoiMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [_messageToSend setText:@""];
    [self addMessageToDataSource:message];
}

- (void)audioRecordEnd:(NSString * __nonnull)audioPath
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    BaseMessage *audioMessage = [imClientManager.messageSendManager sendAudioMessageWithWavFormat:_conversation.chatterId conversationId:_conversation.conversationId wavAudioPath:audioPath chatType:_conversation.chatType progress:^(float progress) {
        
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
    
    BaseMessage *imageMessage = [imClientManager.messageSendManager sendImageMessage:_conversation.chatterId conversationId:_conversation.conversationId image:headerImage chatType:_conversation.chatType progress:^(float progressValue) {
        
    }];
    
    NSLog(@"info: %@", info);
    [self addMessageToDataSource:imageMessage];
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










