//
//  SQChatVC+Category.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/25.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "SQChatVC+Category.h"

@implementation SQChatVC (Category)
- (void)registerBecomActive
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBcomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:self];
}
- (void)didBcomeActive
{
    [self reloadData];
}

@end
