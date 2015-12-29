//
//  UIView+VHToolInfo.m
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//


#import "UIView+VHToolInfo.h"

#import <objc/runtime.h>

@implementation UIView (VHToolInfo)

- (VHToolInfo*)toolInfo
{
    return objc_getAssociatedObject(self, @"UIView+VHToolInfo_toolInfo");
}

- (void)setToolInfo:(VHToolInfo *)toolInfo
{
    objc_setAssociatedObject(self, @"UIView+VHToolInfo_toolInfo", toolInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary*)userInfo
{
    return objc_getAssociatedObject(self, @"UIView+VHToolInfo_userInfo");
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    objc_setAssociatedObject(self, @"UIView+VHToolInfo_userInfo", userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
