//
//  VHFilterTool.m
//
//
//  Created by Little Yoda on 25.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHFilterTool.h"

#import "VHFilterBase.h"


@implementation VHFilterTool {
    UIImage *_originalImage;
    
    UIScrollView *_menuScroll;
}

+ (NSArray *)subtools {
    return [VHToolInfo toolsWithToolClass:[VHFilterBase class]];
}

+ (NSString *)defaultTitle {
    return NSLocalizedStringWithDefaultValue(@"VHFilterTool_DefaultTitle", nil, [VHEditorTheme bundle], @"Filter", @"");
}

+ (BOOL)isAvailable {
    return ([UIDevice iosVersion] >= 6.0);
}

- (void)setup {
    _originalImage = self.editor.imageView.image;
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:self.editor.menuView.frame];
    _menuScroll.backgroundColor = self.editor.menuView.backgroundColor;
    _menuScroll.showsHorizontalScrollIndicator = NO;
    [self.editor.view addSubview:_menuScroll];
    
    [self setFilterMenu];
    
    _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup {
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuScroll removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
    completionBlock(self.editor.imageView.image, nil, nil);
}

#pragma mark- 

- (void)setFilterMenu {
    CGFloat W = 70;
    CGFloat x = 0;
    
    UIImage *iconThumnail = [_originalImage aspectFill:CGSizeMake(50, 50)];
    
    for(VHToolInfo *info in self.toolInfo.sortedSubtools){
        if(!info.available){
            continue;
        }
        
        VHToolbarMenuItem *view = [VHEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, _menuScroll.height) target:self action:@selector(tappedFilterPanel:) toolInfo:info];
        [_menuScroll addSubview:view];
        x += W;
        
        if(view.iconImage==nil){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *iconImage = [self filteredImage:iconThumnail withToolInfo:info];
                [view performSelectorOnMainThread:@selector(setIconImage:) withObject:iconImage waitUntilDone:NO];
            });
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedFilterPanel:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self filteredImage:_originalImage withToolInfo:view.toolInfo];
        [self.editor.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    });
}

- (UIImage *)filteredImage:(UIImage *)image withToolInfo:(VHToolInfo *)info {
        Class filterClass = NSClassFromString(info.toolName);
        if([(Class)filterClass conformsToProtocol:@protocol(VHFilterBaseProtocol)]){
            return [filterClass applyFilter:image];
        }
    return nil;
}

@end
