//
//  ChatViewController.h
//  FireFighting
//
//  Created by liang pengshuai on 14-3-17.
//  Copyright (c) 2014年 liang pengshuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "TZIM-swift.h"

@interface ChatViewController : UIViewController<UIBubbleTableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *messageToSend;
@property (strong, nonatomic) IBOutlet UIView *textView;
@property (strong, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UIImage *otherImage;
@property (copy, nonatomic) NSString *otherUserID;
@property (nonatomic) NSInteger userID;

@property (nonatomic, strong) ChatConversation *conversation;


@property (copy, nonatomic) NSString *chatWith;

@end
