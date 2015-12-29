//
//  VHEditor.m
//
//
//  Created by Little Yoda on 19.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHEditor.h"

#import "_VHEditorViewController.h"

@interface VHEditor ()

@end


@implementation VHEditor

- (id)init {
    return [[_VHEditorViewController alloc] init];
}

- (id)initWithImage:(UIImage *)image {
    return [self initWithImage:image delegate:nil];
}

- (id)initWithImage:(UIImage *)image delegate:(id<VHEditorDelegate>)delegate {
    return [[_VHEditorViewController alloc] initWithImage:image delegate:delegate];
}

- (id)initWithDelegate:(id<VHEditorDelegate>)delegate {
    return [[_VHEditorViewController alloc] initWithDelegate:delegate];
}

- (void)showInViewController:(UIViewController *)controller withImageView:(UIImageView *)imageView {
    
}

- (VHEditorTheme *)theme {
    return [VHEditorTheme theme];
}

@end

