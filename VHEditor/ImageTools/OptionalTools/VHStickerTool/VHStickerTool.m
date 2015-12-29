//
//  VHStickerTool.m
//
//
//  Created by Little Yoda on 15.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHStickerTool.h"

#import "VHCircleView.h"

static NSString* const kVHStickerToolStickerPathKey = @"stickerPath";

@interface _VHStickerView : UIView

+ (void)setStickerView:(_VHStickerView *)view;
- (UIImageView *)imageView;
- (id)initWithImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;

@end



@implementation VHStickerTool {
    UIImage *_originalImage;
    UIView *_workingView;
    UIScrollView *_menuScroll;
}


+ (BOOL)isAvailable {
    return ([UIDevice iosVersion] >= 6.0);
}

+ (CGFloat)defaultDockedNumber {
    return 5;
}

+ (NSString *)defaultTitle {
    return NSLocalizedStringWithDefaultValue(@"VHStickerTool_DefaultTitle", nil, [VHEditorTheme bundle], @"Sticker", @"");
}

+ (NSString *)defaultStickerPath {
    return [[[VHEditorTheme bundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/stickers", NSStringFromClass(self)]];
}

+ (NSDictionary *)optionalInfo {
    return @{kVHStickerToolStickerPathKey:[self defaultStickerPath]};
}


- (void)setup {
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:NO];
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:self.editor.menuView.frame];
    _menuScroll.backgroundColor = self.editor.menuView.backgroundColor;
    _menuScroll.showsHorizontalScrollIndicator = NO;
    [self.editor.view addSubview:_menuScroll];
    
    _workingView = [[UIView alloc] initWithFrame:[self.editor.view convertRect:self.editor.imageView.frame fromView:self.editor.imageView.superview]];
    _workingView.clipsToBounds = YES;
    [self.editor.view addSubview:_workingView];
    [self setStickerMenu];
    
    _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup {
    [self.editor resetZoomScaleWithAnimated:YES];
    
    [_workingView removeFromSuperview];
    
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuScroll removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
    [_VHStickerView setStickerView:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}


- (void)setStickerMenu {
    CGFloat W = 71;
    CGFloat H = _menuScroll.height;
    CGFloat x = 0;
    
    NSString *stickerPath = self.toolInfo.optionalInfo[kVHStickerToolStickerPathKey];
    if(stickerPath==nil){ stickerPath = [[self class] defaultStickerPath]; }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *mylist = [fileManager contentsOfDirectoryAtPath:stickerPath error:&error];
    
    for(NSString *path in mylist){
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", stickerPath, path];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if(image){
            VHToolbarMenuItem *view = [VHEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, H) target:self action:@selector(tappedStickerPanel:) toolInfo:nil];
            view.iconImage = [image aspectFit:CGSizeMake(50, 50)];
            view.userInfo = @{@"filePath" : filePath};
            
            [_menuScroll addSubview:view];
            x += W;
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedStickerPanel:(UITapGestureRecognizer*)sender {
    UIView *view = sender.view;
    
    NSString *filePath = view.userInfo[@"filePath"];
    if(filePath){
        _VHStickerView *view = [[_VHStickerView alloc] initWithImage:[UIImage imageWithContentsOfFile:filePath]];
        CGFloat ratio = MIN( (0.5 * _workingView.width) / view.width, (0.5 * _workingView.height) / view.height);
        [view setScale:ratio];
        view.center = CGPointMake(_workingView.width/2, _workingView.height/2);
        
        [_workingView addSubview:view];
        [_VHStickerView setStickerView:view];
    }
    
    view.alpha = 0.1;
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
}

- (UIImage *)buildImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    
    [image drawAtPoint:CGPointZero];
    
    CGFloat scale = image.size.width / _workingView.width;
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [_workingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *myimage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return myimage;
}

@end


@implementation _VHStickerView {
    UIImageView *_imageView;
    UIButton *_deleteButton;
    VHCircleView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

+ (void)setStickerView:(_VHStickerView *)view {
    static _VHStickerView *activeView = nil;
    if(view != activeView){
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
    }
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width+32, image.size.height+32)];
    if(self){
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.layer.borderColor = [[UIColor blackColor] CGColor];
        _imageView.layer.cornerRadius = 3;
        _imageView.center = self.center;
        [self addSubview:_imageView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[VHEditorTheme imageNamed:@"VHStickerTool/btn_delete.png"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, 32, 32);
        _deleteButton.center = _imageView.frame.origin;
        [_deleteButton addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[VHCircleView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _circleView.center = CGPointMake(_imageView.width + _imageView.frame.origin.x, _imageView.height + _imageView.frame.origin.y);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _circleView.radius = 0.7;
        _circleView.color = [UIColor whiteColor];
        _circleView.borderColor = [UIColor blackColor];
        _circleView.borderWidth = 5;
        [self addSubview:_circleView];
        
        _scale = 1;
        _arg = 0;
        
        [self initGestures];
    }
    return self;
}

- (void)initGestures {
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view= [super hitTest:point withEvent:event];
    if(view==self){
        return nil;
    }
    return view;
}


- (UIImageView *)imageView {
    return _imageView;
}

- (void)clickedDeleteButton:(id)sender {
    _VHStickerView *nextTarget = nil;
    
    const NSInteger myindex = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=myindex+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[_VHStickerView class]]){
            nextTarget = (_VHStickerView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=myindex-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[_VHStickerView class]]){
                nextTarget = (_VHStickerView*)view;
                break;
            }
        }
    }
    
    [[self class] setStickerView:nextTarget];
    [self removeFromSuperview];
}

- (void)setAvtive:(BOOL)active {
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    _imageView.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _imageView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_imageView.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_imageView.height + 32)) / 2;
    rct.size.width  = _imageView.width + 32;
    rct.size.height = _imageView.height + 32;
    self.frame = rct;
    
    _imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _imageView.layer.borderWidth = 1/_scale;
    _imageView.layer.cornerRadius = 3/_scale;
}

- (void)viewDidTap:(UITapGestureRecognizer *)sender {
    [[self class] setStickerView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer *)sender {
    [[self class] setStickerView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

- (void)circleViewDidPan:(UIPanGestureRecognizer *)sender {
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat mytmpR = 1;
    static CGFloat mytmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        mytmpR = sqrt(p.x*p.x + p.y*p.y);
        mytmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg   = _initialArg + arg - mytmpA;
    [self setScale:MAX(_initialScale * R / mytmpR, 0.2)];
}

@end
