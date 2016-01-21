//
//  UIResponder+SQRouter.h
//  LoopChat
//
//  Created by XinJinquan on 2016/1/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (SQRouter)

- (void)routerEvenWithName:(NSString *)evenName userInfo:(NSDictionary *)userInfo;
@end
