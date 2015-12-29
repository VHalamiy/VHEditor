//
//  VHEditorTheme+Private.h
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHEditorTheme.h"

#import "VHToolbarMenuItem.h"

@interface VHEditorTheme (Private)

+ (NSString*)bundleName;
+ (NSBundle*)bundle;
+ (UIImage*)imageNamed:(NSString*)path;

+ (UIColor*)backgroundColor;
+ (UIColor*)toolbarColor;
+ (UIColor*)toolbarTextColor;
+ (UIColor*)toolbarSelectedButtonColor;

+ (UIFont*)toolbarTextFont;

+ (UIActivityIndicatorView*)indicatorView;
+ (VHToolbarMenuItem*)menuItemWithFrame:(CGRect)frame target:(id)target action:(SEL)action toolInfo:(VHToolInfo*)toolInfo;

@end
