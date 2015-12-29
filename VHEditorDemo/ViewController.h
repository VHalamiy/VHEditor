//
//  ViewController.h
//
//
//  Created by Little Yoda on 18.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UITabBarDelegate,
UIScrollViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *_scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *_imageView;


@end