//
//  VHToolInfo+Private.h
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHToolInfo.h"

@protocol VHToolProtocol;

@interface VHToolInfo (Private)

+ (VHToolInfo*)toolInfoForToolClass:(Class<VHToolProtocol>)toolClass;
+ (NSArray*)toolsWithToolClass:(Class<VHToolProtocol>)toolClass;

@end
