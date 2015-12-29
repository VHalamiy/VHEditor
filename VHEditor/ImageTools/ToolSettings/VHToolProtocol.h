//
//  VHToolProtocol.h
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VHToolProtocol

@required
+ (NSString *)defaultIconImagePath;
+ (CGFloat)defaultDockedNumber;
+ (NSString *)defaultTitle;
+ (BOOL)isAvailable;
+ (NSArray *)subtools;
+ (NSDictionary *)optionalInfo;

@end
