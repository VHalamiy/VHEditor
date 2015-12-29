//
//  VHFilterBase.h
//
//
//  Created by Little Yoda on 25.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHToolSettings.h"

@protocol VHFilterBaseProtocol <NSObject>

@required
+ (UIImage *)applyFilter:(UIImage *)image;

@end


@interface VHFilterBase : NSObject<VHToolProtocol, VHFilterBaseProtocol>

@end
