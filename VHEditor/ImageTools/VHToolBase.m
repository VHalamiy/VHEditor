//
//  VHToolBase.m
//
//
//  Created by Little Yoda on 21.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHToolBase.h"

@implementation VHToolBase

- (id)initWithImageEditor:(_VHEditorViewController *)editor withToolInfo:(VHToolInfo *)info {
    self = [super init];
    if(self){
        self.editor = editor;
        self.toolInfo = info;
    }
    return self;
}

+ (NSString *)defaultIconImagePath {
    return [NSString stringWithFormat:@"%@.bundle/%@/icon.png", [VHEditorTheme bundleName], NSStringFromClass([self class])];
}

+ (CGFloat)defaultDockedNumber {

    NSArray *tools = @[@"VHFilterTool",
                       @"VHAdjustmentTool",                       
                       @"VHRotateTool"];
    return [tools indexOfObject:NSStringFromClass(self)];
}

+ (NSArray *)subtools {
    return nil;
}

+ (NSString *)defaultTitle {
    return @"DefaultTitle";
}

+ (BOOL)isAvailable {
    return NO;
}

+ (NSDictionary *)optionalInfo {
    return nil;
}


- (void)setup {
    
}

- (void)cleanup {
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock {
    completionBlock(self.editor.imageView.image, nil, nil);
}

@end
