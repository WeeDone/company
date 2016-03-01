//
//  UIImageView+HeadView.m
//  LoopChat
//
//  Created by XinJinquan on 2016/2/19.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "UIImageView+HeadView.h"
#import "LCUserProfileManage.h"

@implementation UIImageView (HeadView)

- (void)imageWithUsername:(NSString *)username
         placeholderImage:(UIImage *)placeholder
{
    if (placeholder == nil) {
        placeholder = [UIImage imageNamed:@"chatListCellHead"];
    }
    UserProfileEntity *profileEnrity = [[LCUserProfileManage sharedInstance]getUserProfileByUsername:username];
    
}
@end
