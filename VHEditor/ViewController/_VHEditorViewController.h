//
//  _VHEditorViewController.h
//
//
//  Created by Little Yoda on 20.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHEditor.h"

@interface _VHEditorViewController : VHEditor <UIScrollViewDelegate, UIBarPositioningDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *_scrollView;
@property (nonatomic, weak) IBOutlet UINavigationBar *_navigationBar;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;

@property (nonatomic, strong) UIImageView  *imageView;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;


- (id)initWithImage:(UIImage *)image;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
