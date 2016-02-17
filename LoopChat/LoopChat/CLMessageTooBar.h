//
//  CLMessageTooBar.h
//  LoopChat
//
//  Created by XinJinquan on 2016/1/27.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageTextView.h"
#import "LCChatBarMoreView.h"

#import "DXFaceView.h"
#define INPUT_TEXTVIEW_MIN_HEIGHT 36
#define INPUT_TEXTVIEW_MAX_HEIGHT 200
#define HORIZONTAL_PADDING 8
#define VERTICAL_PADDING 5

@protocol CLMessageTooBarDelegate;

@interface CLMessageTooBar : UIView

@property (nonatomic, assign) id<CLMessageTooBarDelegate> delagate;
@property (nonatomic, strong) UIButton *recodButton;
@property (nonatomic, strong) UIImage *toolBarBackgroundImage;
@property (nonatomic, strong) UIView *moreView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) XHMessageTextView *inputTextView;
@property (nonatomic) CGFloat maxTextInputViewHeight;
@property (nonatomic, strong) UIView *faceView;
@property (nonatomic, strong) UIView *recordView;





- (instancetype)initWithFrame:(CGRect)frame;
+ (CGFloat)defalutHeight;


@end
@protocol CLMessageTooBarDelegate <NSObject>

- (void)didStyleChangeToRecord:(BOOL)changeToRecord;
- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView;
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView;
- (void)didSendText:(NSString *)text;

@required

- (void)didChangeFrameToHeigh:(CGFloat)toHeight;

@end