//
//  CLMessageTooBar.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/27.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "CLMessageTooBar.h"
#import "DXChatBarMoreView.h"
@interface CLMessageTooBar() <UITextViewDelegate>
{
    CGFloat _previousTextViewContentHeight;
}
@property (nonatomic) CGFloat version;
@property (nonatomic, strong) UIImageView *toolBarBackgraoundImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *tooBarView;
@property (nonatomic, strong) UIButton *styleChangeButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic) BOOL   isShowButtonView;
@property (nonatomic, strong) UIView *activityButtonView;

@end
@implementation CLMessageTooBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < (VERTICAL_PADDING * 2 + INPUT_TEXTVIEW_MIN_HEIGHT)) {
        frame.size.height = VERTICAL_PADDING * 2 + INPUT_TEXTVIEW_MIN_HEIGHT;
    }
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if (frame.size.height < (VERTICAL_PADDING *2 + INPUT_TEXTVIEW_MIN_HEIGHT)) {
        frame.size.height = VERTICAL_PADDING *2 + INPUT_TEXTVIEW_MIN_HEIGHT;
    }
    [super setFrame:frame];
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self setupSubviews];
    }
    [super willMoveToSuperview:newSuperview];
}
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillChangeFrameNotification
                                                 object:nil];
    _delagate = nil;
    _inputTextView = nil;
    _inputTextView.delegate = nil;
    
}

#pragma  mark - Setter
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage
{
    _toolBarBackgroundImage = toolBarBackgroundImage;
    self.toolBarBackgraoundImageView.image  = _toolBarBackgroundImage;
}
- (void)setMaxTextInputViewHeight:(CGFloat)maxTextInputViewHeight
{
    if (maxTextInputViewHeight > INPUT_TEXTVIEW_MAX_HEIGHT) {
        maxTextInputViewHeight  = INPUT_TEXTVIEW_MAX_HEIGHT;
    }
    _maxTextInputViewHeight = maxTextInputViewHeight;
}

#pragma  mark - Getter
- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _backgroundImageView;
}
- (UIImageView *)toolBarBackgraoundImageView
{
    if (_toolBarBackgraoundImageView == nil) {
        _toolBarBackgraoundImageView = [[UIImageView alloc]init];
        _toolBarBackgraoundImageView.backgroundColor = nil;
        _toolBarBackgraoundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return _toolBarBackgraoundImageView;
}
- (UIView *)tooBarView
{
    if (_tooBarView == nil) {
        _tooBarView = [[UIView alloc]init];
        _tooBarView.backgroundColor  = nil;
    }
    return _tooBarView;
}
#pragma  mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delagate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delagate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.styleChangeButton.selected = NO;
    self.moreButton.selected = NO;
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    if ([self.delagate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delagate inputTextViewDidBeginEditing:self.inputTextView];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delagate respondsToSelector:@selector(didSendText:)]) {
            [self.delagate didSendText:textView.text];
            self.inputTextView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputView]];
        }
             return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}
#pragma mark - DXFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.inputTextView.text;
    
    if (!isDelete && str.length > 0) {
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    }
    else {
        
        if (chatText.length > 0) {
            self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}
#pragma mark - private

/**
 *  设置初始属性
 */
- (void)setupConfigure
{
    
    self.version = [[[UIDevice currentDevice]systemVersion]floatValue];
    self.maxTextInputViewHeight = INPUT_TEXTVIEW_MAX_HEIGHT;
    
    self.activityButtonView = nil;
    self.isShowButtonView = NO;
    self.backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"]
                         stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:self.backgroundImageView];
    
    self.tooBarView.frame = CGRectMake(0, 0, self.frame.size.width, VERTICAL_PADDING * 2 + INPUT_TEXTVIEW_MIN_HEIGHT);
    self.toolBarBackgraoundImageView.frame = self.tooBarView.bounds;
    [self.tooBarView addSubview:self.toolBarBackgraoundImageView];
    [self addSubview:self.tooBarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (void)setupSubviews
{
    CGFloat allButtonWidth = 0.0;
    CGFloat textViewLeftMargin = 6.0;
    
    //转变输入样式
    self.styleChangeButton = [[UIButton alloc]initWithFrame:
                              CGRectMake(HORIZONTAL_PADDING,
                                         VERTICAL_PADDING,
                                         INPUT_TEXTVIEW_MAX_HEIGHT,
                                         INPUT_TEXTVIEW_MIN_HEIGHT)];
    self.styleChangeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chatBar_record"]
                            forState:UIControlStateNormal];
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chatBar_keyboard"]
                            forState:UIControlStateSelected];
    [self.styleChangeButton addTarget:self action:@selector(buttonAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
    self.styleChangeButton.tag = 0;
    allButtonWidth += CGRectGetMaxX(self.styleChangeButton.frame);
    textViewLeftMargin += CGRectGetMaxX(self.styleChangeButton.frame);
    
    //更多
    self.moreButton = [[UIButton alloc] initWithFrame:
                       CGRectMake(CGRectGetWidth(self.bounds) - HORIZONTAL_PADDING - INPUT_TEXTVIEW_MIN_HEIGHT,
                                  VERTICAL_PADDING,
                                  INPUT_TEXTVIEW_MIN_HEIGHT,
                                  INPUT_TEXTVIEW_MIN_HEIGHT)];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_more"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_moreSelected"] forState:UIControlStateHighlighted];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.tag = 2;
    allButtonWidth += CGRectGetWidth(self.moreButton.frame) + HORIZONTAL_PADDING * 2.5;
    
    //表情
    self.faceButton = [[UIButton alloc] initWithFrame:
                       CGRectMake(CGRectGetMinX(self.moreButton.frame) - INPUT_TEXTVIEW_MIN_HEIGHT - HORIZONTAL_PADDING,
                                  VERTICAL_PADDING,
                                  INPUT_TEXTVIEW_MIN_HEIGHT,
                                  INPUT_TEXTVIEW_MIN_HEIGHT)];
    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_face"]
                     forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_faceSelected"]
                     forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_keyboard"]
                     forState:UIControlStateSelected];
    [self.faceButton addTarget:self action:@selector(buttonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    self.faceButton.tag = 1;
    allButtonWidth += CGRectGetWidth(self.faceButton.frame) + HORIZONTAL_PADDING * 1.5;
    
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    // 初始化输入框
    self.inputTextView = [[XHMessageTextView  alloc] initWithFrame:CGRectMake(textViewLeftMargin, VERTICAL_PADDING, width, INPUT_TEXTVIEW_MIN_HEIGHT)];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    self.inputTextView.contentMode = UIViewContentModeCenter;
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];
    
 
    
    if (!self.moreView) {
        self.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (VERTICAL_PADDING * 2 + INPUT_TEXTVIEW_MIN_HEIGHT), self.frame.size.width, 80) type:ChatMoreTypeGroupChat];
        self.moreView.backgroundColor = [UIColor lightGrayColor];
        self.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    

    
    [self.tooBarView  addSubview:self.styleChangeButton];
    [self.tooBarView addSubview:self.moreButton];
    [self.tooBarView addSubview:self.faceButton];
    [self.tooBarView addSubview:self.inputTextView];
    [self.tooBarView addSubview:self.recodButton];
}
- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSInteger tag = button.tag;
    
    switch (tag) {
        case 0://切换状态
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                self.moreButton.selected = NO;
                //录音状态下，不显示底部扩展页面
                [self willShowBottomView:nil];
                
                //将inputTextView内容置空，以使toolbarView回到最小高度
                self.inputTextView.text = @"";
                [self textViewDidChange:self.inputTextView];
                [self.inputTextView resignFirstResponder];
            }
            else{
                //键盘也算一种底部扩展页面
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.recodButton.hidden = !button.selected;
                self.inputTextView.hidden = button.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delagate respondsToSelector:@selector(didStyleChangeToRecord:)]) {
                [self.delagate didStyleChangeToRecord:button.selected];
            }
        }
            break;
        case 1://表情
        {
            if (button.selected) {
                self.moreButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                }
                else{//如果处于文字输入状态，使文字输入框失去焦点
                    [self.inputTextView resignFirstResponder];
                }
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recodButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                if (!self.styleChangeButton.selected) {
                    [self.inputTextView becomeFirstResponder];
                }
                else{
                    [self willShowBottomView:nil];
                }
            }
        }
            break;
        case 2://更多
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                }
                else{//如果处于文字输入状态，使文字输入框失去焦点
                    [self.inputTextView resignFirstResponder];
                }
                
                [self willShowBottomView:self.moreView];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recodButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                self.styleChangeButton.selected = NO;
                [self.inputTextView becomeFirstResponder];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - change frame

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.tooBarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x,
                                fromFrame.origin.y + (fromFrame.size.height - toHeight),
                                fromFrame.size.width,
                                toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if (bottomHeight == 0 && self.frame.size.height == self.tooBarView.frame.size.height) {
        return;
    } if (bottomHeight == 0) {
        self.isShowButtonView = NO;
    } else {
        self.isShowButtonView = YES;
    }
    self.frame = toFrame;
    if (_delagate && [_delagate respondsToSelector:@selector(didChangeFrameToHeigh:)]) {
        [_delagate didChangeFrameToHeigh:toHeight];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtonView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.tooBarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtonView) {
            [self.activityButtonView removeFromSuperview];
        }
        self.activityButtonView = bottomView;
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        //一定要把self.activityButtomView置为空
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtonView) {
            [self.activityButtonView removeFromSuperview];
        }
        self.activityButtonView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self willShowBottomHeight:0];
    }
    else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < INPUT_TEXTVIEW_MIN_HEIGHT) {
        toHeight = INPUT_TEXTVIEW_MIN_HEIGHT;
    }
    if (toHeight > self.maxTextInputViewHeight) {
        toHeight = self.maxTextInputViewHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight)
    {
        return;
    }
    else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.tooBarView.frame;
        rect.size.height += changeHeight;
        self.tooBarView.frame = rect;

        _previousTextViewContentHeight = toHeight;
        
        if (_delagate && [_delagate respondsToSelector:@selector(didChangeFrameToHeigh:)]) {
            [_delagate didChangeFrameToHeigh:self.frame.size.height];
        }
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    if (self.version >= 7.0)
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

#pragma mark - public 
- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    self.faceButton.selected = NO;
    self.moreButton.selected = NO;
    [self willShowBottomView:nil];
    
    return result;
}
+ (CGFloat)defalutHeight
{
    return VERTICAL_PADDING *2 + INPUT_TEXTVIEW_MIN_HEIGHT;
}

@end
