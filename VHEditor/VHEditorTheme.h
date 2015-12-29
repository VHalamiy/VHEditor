//
//  VHEditorTheme.h
//
//
//  Created by Little Yoda on 21.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VHEditorThemeDelegate;

@interface VHEditorTheme : NSObject

@property (nonatomic, weak) id<VHEditorThemeDelegate> delegate;
@property (nonatomic, strong) NSString *bundleName;
@property (nonatomic, strong) UIColor  *backgroundColor;
@property (nonatomic, strong) UIColor  *toolbarColor;
@property (nonatomic, strong) UIColor  *toolbarTextColor;
@property (nonatomic, strong) UIColor  *toolbarSelectedButtonColor;
@property (nonatomic, strong) UIFont   *toolbarTextFont;

+ (VHEditorTheme *)theme;

@end


@protocol VHEditorThemeDelegate <NSObject>
@optional
- (UIActivityIndicatorView*)imageEditorThemeActivityIndicatorView;

@end