/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

typedef enum{
    ChatMoreTypeChat,
    ChatMoreTypeGroupChat,
}ChatMoreType;

@protocol LCChatBarMoreViewDelegate;
@interface LCChatBarMoreView : UIView

@property (nonatomic,assign) id<LCChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;

- (instancetype)initWithFrame:(CGRect)frame type:(ChatMoreType)type;

- (void)setupSubviewsForType:(ChatMoreType)type;

@end

@protocol LCChatBarMoreViewDelegate <NSObject>


- (void)moreViewTakePicAction:(LCChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(LCChatBarMoreView *)moreView;
- (void)moreViewLocationAction:(LCChatBarMoreView *)moreView;
- (void)moreViewAudioCallAction:(LCChatBarMoreView *)moreView;
- (void)moreViewVideoCallAction:(LCChatBarMoreView *)moreView;

@end
