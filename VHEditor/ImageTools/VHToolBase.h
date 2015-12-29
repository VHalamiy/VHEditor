//
//  VHToolBase.h
//
//
//  Created by Little Yoda on 21.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_VHEditorViewController.h"
#import "VHToolSettings.h"


static const CGFloat kVHToolAnimationDuration = 0.3;
static const CGFloat kVHToolFadeoutDuration   = 0.2;



@interface VHToolBase : NSObject<VHToolProtocol>

@property (nonatomic, weak) _VHEditorViewController *editor;
@property (nonatomic, weak) VHToolInfo *toolInfo;

- (id)initWithImageEditor:(_VHEditorViewController *)editor withToolInfo:(VHToolInfo *)info;

- (void)setup;
- (void)cleanup;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
