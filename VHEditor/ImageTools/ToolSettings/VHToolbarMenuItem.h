//
//  VHToolbarMenuItem.h
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "UIView+VHToolInfo.h"

@interface VHToolbarMenuItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) UIImage *iconImage;
@property (nonatomic, assign) BOOL selected;

 - (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action toolInfo:(VHToolInfo *)toolInfo;

@end
