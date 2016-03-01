//
//  UIImageView+HeadView.h
//  LoopChat
//
//  Created by XinJinquan on 2016/2/19.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HeadView)
- (void)imageWithUsername:(NSString *)username placeholderImage:(UIImage *)placeholder;

@end

@interface UILabel (Parse)

- (void)setTextWithUsername:(NSString *)username;

@end