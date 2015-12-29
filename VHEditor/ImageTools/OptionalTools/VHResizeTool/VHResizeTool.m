//
//  VHResizeTool.m
//
//
//  Created by Little Yoda on 10.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHResizeTool.h"

static NSString* const kVHResizeToolPresetSizes = @"pSizes";
static NSString* const kVHResizeToolLimitSize = @"lSize";

@interface VHResizePanel : UIView <UITextFieldDelegate>

- (id)initWithFrame:(CGRect)frame originalSize:(CGSize)size;
- (void)setImageW:(CGFloat)width;
- (void)setImageH:(CGFloat)height;
- (void)setlSize:(CGFloat)limit;
- (CGSize)imageSize;

@end


@implementation VHResizeTool {
    UIImage *_originalImage;
    
    UIView *_menuContainer;
    UIScrollView *_menuScroll;
    VHResizePanel *_resizePanel;
}


+ (NSArray *)defaultpSizes {
    return @[@240, @320, @480, @640, @800, @960, @1024, @2048];
}

+ (NSNumber *)defaultlSize {
    return @3200;
}

+ (BOOL)isAvailable {
    return ([UIDevice iosVersion] >= 6.0);
}

+ (CGFloat)defaultDockedNumber {
    return 4;
}

+ (NSString *)defaultTitle {
    return NSLocalizedStringWithDefaultValue(@"VHResizeTool_DefaultTitle", nil, [VHEditorTheme bundle], @"Resize", @"");
}

+ (NSDictionary *)optionalInfo {
    return @{kVHResizeToolPresetSizes:[self defaultpSizes], kVHResizeToolLimitSize:[self defaultlSize]};
}


- (void)setup {
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:NO];
    
    _menuContainer = [[UIView alloc] initWithFrame:self.editor.menuView.frame];
    
    [self.editor.view addSubview:_menuContainer];
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _menuContainer.width - 71, _menuContainer.height)];
    
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _menuScroll.clipsToBounds = NO;
    [_menuContainer addSubview:_menuScroll];
    
    UIView *buttonPanel = [[UIView alloc] initWithFrame:CGRectMake(_menuScroll.right, 0, 71, _menuContainer.height)];
    buttonPanel.backgroundColor = [_menuContainer.backgroundColor colorWithAlphaComponent:0.95];
    [_menuContainer addSubview:buttonPanel];
    
    NSNumber *limit = self.toolInfo.optionalInfo[kVHResizeToolLimitSize];
    if(limit==nil){ limit = [self.class defaultlSize]; }
    
    _resizePanel = [[VHResizePanel alloc] initWithFrame:self.editor.imageView.superview.frame originalSize:_originalImage.size];
    _resizePanel.backgroundColor = [[VHEditorTheme toolbarColor] colorWithAlphaComponent:0.5];
    [_resizePanel setlSize:limit.floatValue];
    [self.editor.view addSubview:_resizePanel];
    
    [self setResizeMenuPanel];
    
    _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup {
    [self.editor resetZoomScaleWithAnimated:NO];
    
    [_resizePanel endEditing:YES];
    [_resizePanel removeFromSuperview];
    
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuContainer removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGSize size = _resizePanel.imageSize;
        
        if(size.width>0 && size.height>0){
            UIImage *image = [_originalImage resize:size];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, nil, nil);
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, nil, nil);
            });
        }
    });
}


- (UIImage *)imageWithString:(NSString *)string {
    UILabel *mylabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    mylabel.backgroundColor = [UIColor colorWithWhite:0 alpha:2];
    mylabel.textColor = [UIColor colorWithWhite:1 alpha:2];
    mylabel.textAlignment = NSTextAlignmentCenter;
    mylabel.text = string;
    mylabel.font = [UIFont boldSystemFontOfSize:30];
    mylabel.minimumScaleFactor = 0.5;
    
    UIGraphicsBeginImageContext(mylabel.frame.size);
    [mylabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myimage;
}

- (void)setResizeMenuPanel {
    CGFloat W = 71;
    CGFloat H = _menuScroll.height;
    CGFloat x = 0;
    
    NSArray *mysizes = self.toolInfo.optionalInfo[kVHResizeToolPresetSizes];
    if(mysizes==nil || ![mysizes isKindOfClass:[NSArray class]] || mysizes.count==0){
        mysizes = [[self class] defaultpSizes];
    }
    
    for(NSNumber *mysize in mysizes){
        VHToolbarMenuItem *view = [VHEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, H) target:self action:@selector(tappedResizePanel:) toolInfo:nil];
        view.userInfo = @{@"size":mysize};
        view.iconImage = [self imageWithString:[NSString stringWithFormat:@"%@", mysize]];
        
        [_menuScroll addSubview:view];
        x += W;
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedResizePanel:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    
    NSNumber *size = view.userInfo[@"size"];
    if(size){
            [_resizePanel setImageW:size.floatValue];
    }
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
}

@end





@implementation VHResizePanel {
    UIView *_infoPanel;
    CGSize _originalSize;
    
    CGFloat _lSize;
    UITextField *_fieldW;
    UITextField *_fieldH;

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _infoPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
        _infoPanel.backgroundColor = [[VHEditorTheme toolbarColor] colorWithAlphaComponent:0.5];
        _infoPanel.layer.cornerRadius = 5;
        _infoPanel.center = CGPointMake(self.width/2, self.height/2);
        _infoPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_infoPanel];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChange:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChange:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame originalSize:(CGSize)size; {
    self = [self initWithFrame:frame];
    if(self) {
        _originalSize = size;
        [self initMenuPanel];
    }
    return self;
}

- (void)initMenuPanel {
    UIFont *font = [VHEditorTheme toolbarTextFont];
    
    CGFloat y = 0;
    UILabel *mylabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, _infoPanel.width-30, 30)];
    mylabel.backgroundColor = [UIColor clearColor];
    mylabel.font = [font fontWithSize:18];
    mylabel.text = NSLocalizedStringWithDefaultValue(@"VHResizeTool_InfoPanelTextOriginalSize", nil, [VHEditorTheme bundle], @"Original Size:", @"");
    [_infoPanel addSubview:mylabel];
    y = mylabel.bottom;
    
    mylabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, _infoPanel.width-30, 50)];
    mylabel.backgroundColor = [UIColor clearColor];
    mylabel.font = [font fontWithSize:30];
    mylabel.text = [NSString stringWithFormat:@"%ld x %ld", (long)_originalSize.width, (long)_originalSize.height];
    mylabel.textAlignment = NSTextAlignmentCenter;
    [_infoPanel addSubview:mylabel];
    y = mylabel.bottom;
    
    mylabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _infoPanel.height/2, _infoPanel.width-20, 30)];
    mylabel.backgroundColor = [UIColor clearColor];
    mylabel.font = [font fontWithSize:17];
    mylabel.text = NSLocalizedStringWithDefaultValue(@"VHResizeTool_InfoPanelTextNewSize", nil, [VHEditorTheme bundle], @"New Size:", @"");
    [_infoPanel addSubview:mylabel];
    y = mylabel.bottom;
    
    _fieldW = [[UITextField alloc] initWithFrame:CGRectMake(30, y+5, 100, 40)];
    _fieldW.font = [font fontWithSize:30];
    _fieldW.textAlignment = NSTextAlignmentCenter;
    _fieldW.keyboardType = UIKeyboardTypeNumberPad;
    _fieldW.borderStyle = UITextBorderStyleLine;
    _fieldW.text = [NSString stringWithFormat:@"%ld", (long)_originalSize.width];
    _fieldW.delegate = self;
    [_fieldW addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [_infoPanel addSubview:_fieldW];
    
    _fieldH = [[UITextField alloc] initWithFrame:CGRectMake(_infoPanel.center.x + 10, y+5, 100, 40)];
    _fieldH.font = [font fontWithSize:30];
    _fieldH.textAlignment = NSTextAlignmentCenter;
    _fieldH.keyboardType = UIKeyboardTypeNumberPad;
    _fieldH.borderStyle = UITextBorderStyleLine;
    _fieldH.text = [NSString stringWithFormat:@"%ld", (long)_originalSize.height];
    _fieldH.delegate = self;
    [_fieldH addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [_infoPanel addSubview:_fieldH];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidTap:(UITapGestureRecognizer *)sender {
    [self endEditing:YES];
}

- (void)keyBoardWillChange:(NSNotification *)notificatioin {
    CGRect mykeyboardFrame = [[notificatioin.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    mykeyboardFrame = [self.superview convertRect:mykeyboardFrame fromView:self.window];
    
    UIViewAnimationCurve animationCurve = [[notificatioin.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[notificatioin.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | (animationCurve<<16)
                     animations:^{
                         CGFloat H = MIN(self.height, mykeyboardFrame.origin.y - self.top);
                         _infoPanel.center = CGPointMake(_infoPanel.center.x, H/2);
                     } completion:^(BOOL finished) {
                         
                     }
     ];
}


- (void)setlSize:(CGFloat)limit {
    _lSize = limit;
    [self setImageW:_fieldW.text.floatValue];
}

- (void)setImageW:(CGFloat)width {
    width = MIN(width, _lSize);
    
    if(width>0){
        CGFloat height = MAX(1, width * _originalSize.height / _originalSize.width);
        
        if(height>_lSize){
            [self setImageH:_lSize];
        }
        else{
            _fieldW.text = [NSString stringWithFormat:@"%ld", (long)width];
            _fieldH.text = [NSString stringWithFormat:@"%ld", (long)height];
        }
    }
    else{
        _fieldH.text = @"";
    }
    
}

- (void)setImageH:(CGFloat)height {
    height = MIN(height, _lSize);
    
    if(height>0){
        CGFloat width = MAX(1, height * _originalSize.width / _originalSize.height);
        
        if(width>_lSize){
            [self setImageW:_lSize];
        }
        else{
            _fieldW.text = [NSString stringWithFormat:@"%ld", (long)width];
            _fieldH.text = [NSString stringWithFormat:@"%ld", (long)height];
        }
    }
    else{
        _fieldW.text = @"";
    }
    
}

- (void)textFieldDidChanged:(id)sender {
    if(sender==_fieldW){
        [self setImageW:_fieldW.text.floatValue];
    }
    else if(sender==_fieldH){
        [self setImageH:_fieldH.text.floatValue];
    }
}


- (CGSize)imageSize {
    return CGSizeMake(_fieldW.text.floatValue, _fieldH.text.floatValue);
}

@end

