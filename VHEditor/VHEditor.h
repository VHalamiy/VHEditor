//
//  VHEditor.h
//
//
//  Created by Little Yoda on 19.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHToolInfo.h"
#import "VHEditorTheme.h"

@protocol VHEditorDelegate;
@protocol VHEditorTransitionDelegate;

@interface VHEditor : UIViewController

@property (nonatomic, weak) id<VHEditorDelegate> delegate;
@property (nonatomic, readonly) VHEditorTheme *theme;
@property (nonatomic, readonly) VHToolInfo *toolInfo;

- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image delegate:(id<VHEditorDelegate>)delegate;
- (id)initWithDelegate:(id<VHEditorDelegate>)delegate;

- (void)showInViewController:(UIViewController<VHEditorTransitionDelegate> *)controller withImageView:(UIImageView *)imageView;

@end



@protocol VHEditorDelegate <NSObject>
@optional
- (void)imageEditor:(VHEditor *)editor didFinishEditWithImage:(UIImage *)image;
- (void)imageEditorDidCancel:(VHEditor *)editor;

@end


@protocol VHEditorTransitionDelegate <VHEditorDelegate>
@optional
- (void)imageEditor:(VHEditor *)editor willDismissWithImageView:(UIImageView*)imageView canceled:(BOOL)canceled;
- (void)imageEditor:(VHEditor *)editor didDismissWithImageView:(UIImageView*)imageView canceled:(BOOL)canceled;

@end

