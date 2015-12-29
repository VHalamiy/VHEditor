//
//  VHEditorTheme.m
//
//
//  Created by Little Yoda on 21.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHEditorTheme.h"

@implementation VHEditorTheme

#pragma mark - singleton

static VHEditorTheme *_sharedInstance = nil;

+ (VHEditorTheme*)theme {
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[VHEditorTheme alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.bundleName = @"VHEditor";
        self.backgroundColor = [UIColor whiteColor];
        self.toolbarColor = [UIColor colorWithWhite:1 alpha:0.8];
        self.toolbarTextColor = [UIColor blackColor];
        self.toolbarSelectedButtonColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        self.toolbarTextFont = [UIFont systemFontOfSize:10];
    }
    return self;
}

@end
