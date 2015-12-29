//
//  VHToolInfo.h
//
//
//  Created by Little Yoda on 19.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHToolInfo : NSObject

@property (nonatomic, readonly) NSString *toolName;
@property (nonatomic, strong)   NSString *title;
@property (nonatomic, assign)   BOOL      available;
@property (nonatomic, assign)   CGFloat   dockedNumber;
@property (nonatomic, strong)   NSString *iconImagePath;
@property (nonatomic, readonly) UIImage  *iconImage;
@property (nonatomic, readonly) NSArray  *subtools;
@property (nonatomic, strong) NSMutableDictionary *optionalInfo;


- (NSArray *)sortedSubtools;

@end
