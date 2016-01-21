//
//  UIResponder+SQRouter.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "UIResponder+SQRouter.h"

@implementation UIResponder (SQRouter)
- (void)routerEvenWithName:(NSString *)evenName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder]routerEvenWithName:evenName userInfo:userInfo];
}
@end
