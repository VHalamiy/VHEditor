//
//  _VHEditorViewController.m
//
//
//  Created by Little Yoda on 20.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "_VHEditorViewController.h"

#import "VHToolBase.h"


#pragma mark- _VHEditorViewController

@interface _VHEditorViewController() <VHToolProtocol>

@property (nonatomic, strong) VHToolBase *currentTool;
@property (nonatomic, strong) VHToolInfo *toolInfo;
@property (nonatomic, strong) UIImageView *targetImageView;

@end


@implementation _VHEditorViewController {
    UIImage *_originalImage;
    UIView *_bgView;
}
@synthesize toolInfo = _toolInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)init {
    self = [self initWithNibName:@"_VHEditorViewController" bundle:nil];
    if (self){
        self.toolInfo = [VHToolInfo toolInfoForToolClass:[self class]];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    return [self initWithImage:image delegate:nil];
}

- (id)initWithImage:(UIImage*)image delegate:(id<VHEditorDelegate>)delegate {
    self = [self init];
    if (self){
        _originalImage = [image deepCopy];
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithDelegate:(id<VHEditorDelegate>)delegate {
    self = [self init];
    if (self){
        self.delegate = delegate;
    }
    return self;
}

- (void)showInViewController:(UIViewController *)controller withImageView:(UIImageView *)imageView; {
    _originalImage = imageView.image;
    
    self.targetImageView = imageView;
    
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    self.view.frame = controller.view.bounds;
    [controller.view addSubview:self.view];
    [self refreshImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.toolInfo.title;
    self.view.backgroundColor = self.theme.backgroundColor;
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    _menuView.backgroundColor = [VHEditorTheme toolbarColor];
    
    if(self.navigationController!=nil){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushedFinishBtn:)];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        self._navigationBar.hidden = YES;
        [self._navigationBar popNavigationItemAnimated:NO];
    }
    else{
        self._navigationBar.topItem.title = self.title;
    }
    
    if([UIDevice iosVersion] < 7){
        self._navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    [self setMenuView];
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        [self._scrollView addSubview:_imageView];
        [self refreshImageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    if(self.targetImageView){
        [self expropriateImageView];
    }
    else{
        [self refreshImageView];
    }
}

#pragma mark- View transition

- (void)copyImageViewInfo:(UIImageView *)fromView toView:(UIImageView *)toView {
    CGAffineTransform transform = fromView.transform;
    fromView.transform = CGAffineTransformIdentity;
    
    toView.transform = CGAffineTransformIdentity;
    toView.frame = [toView.superview convertRect:fromView.frame fromView:fromView.superview];
    toView.transform = transform;
    toView.image = fromView.image;
    toView.contentMode = fromView.contentMode;
    toView.clipsToBounds = fromView.clipsToBounds;
    
    fromView.transform = transform;
}

- (void)expropriateImageView {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIImageView *animateView = [UIImageView new];
    [window addSubview:animateView];
    [self copyImageViewInfo:self.targetImageView toView:animateView];
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_bgView atIndex:0];
    
    _bgView.backgroundColor = self.view.backgroundColor;
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:0];
    
    self.targetImageView.hidden = YES;
    _imageView.hidden = YES;
    _bgView.alpha = 0;
    self._navigationBar.transform = CGAffineTransformMakeTranslation(0, -self._navigationBar.height);
    _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
    
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         animateView.transform = CGAffineTransformIdentity;
                         
                         CGFloat dy = ([UIDevice iosVersion]<7) ? [UIApplication sharedApplication].statusBarFrame.size.height : 0;
                         
                         CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
                         if(size.width>0 && size.height>0){
                             CGFloat ratio = MIN(self._scrollView.width / size.width, self._scrollView.height / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             animateView.frame = CGRectMake((self._scrollView.width-W)/2 + self._scrollView.left, (self._scrollView.height-H)/2 + self._scrollView.top + dy, W, H);
                         }
                         
                         _bgView.alpha = 1;
                         self._navigationBar.transform = CGAffineTransformIdentity;
                         _menuView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.targetImageView.hidden = NO;
                         _imageView.hidden = NO;
                         [animateView removeFromSuperview];
                     }
     ];
}

- (void)restoreImageView:(BOOL)canceled {
    if(!canceled){
        self.targetImageView.image = _imageView.image;
    }
    self.targetImageView.hidden = YES;
    
    id<VHEditorTransitionDelegate> delegate = [self transitionDelegate];
    if([delegate respondsToSelector:@selector(imageEditor:willDismissWithImageView:canceled:)]){
        [delegate imageEditor:self willDismissWithImageView:self.targetImageView canceled:canceled];
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIImageView *animateView = [UIImageView new];
    [window addSubview:animateView];
    [self copyImageViewInfo:_imageView toView:animateView];
    
    _menuView.frame = [window convertRect:_menuView.frame fromView:_menuView.superview];
    self._navigationBar.frame = [window convertRect:self._navigationBar.frame fromView:self._navigationBar.superview];
    
    [window addSubview:_menuView];
    [window addSubview:self._navigationBar];
    
    self.view.userInteractionEnabled = NO;
    _menuView.userInteractionEnabled = NO;
    self._navigationBar.userInteractionEnabled = NO;
    _imageView.hidden = YES;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _bgView.alpha = 0;
                         _menuView.alpha = 0;
                         self._navigationBar.alpha = 0;
                         
                         _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         self._navigationBar.transform = CGAffineTransformMakeTranslation(0, -self._navigationBar.height);
                         
                         [self copyImageViewInfo:self.targetImageView toView:animateView];
                     }
                     completion:^(BOOL finished) {
                         [animateView removeFromSuperview];
                         [_menuView removeFromSuperview];
                         [self._navigationBar removeFromSuperview];
                         
                         [self willMoveToParentViewController:nil];
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                         
                         _imageView.hidden = NO;
                         self.targetImageView.hidden = NO;
                         
                         if([delegate respondsToSelector:@selector(imageEditor:didDismissWithImageView:canceled:)]){
                             [delegate imageEditor:self didDismissWithImageView:self.targetImageView canceled:canceled];
                         }
                     }
     ];
}

#pragma mark- Properties

- (id<VHEditorTransitionDelegate>)transitionDelegate {
    if([self.delegate conformsToProtocol:@protocol(VHEditorTransitionDelegate)]){
        return (id<VHEditorTransitionDelegate>)self.delegate;
    }
    return nil;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.toolInfo.title = title;
}

#pragma mark- ImageTool setting

+ (NSString *)defaultIconImagePath {
    return nil;
}

+ (CGFloat)defaultDockedNumber {
    return 0;
}

+ (NSString *)defaultTitle {
    return NSLocalizedStringWithDefaultValue(@"VHEditor_DefaultTitle", nil, [VHEditorTheme bundle], @"Edit", @"");
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSArray *)subtools {
    return [VHToolInfo toolsWithToolClass:[VHToolBase class]];
}

+ (NSDictionary *)optionalInfo {
    return nil;
}

#pragma mark- 

- (void)setMenuView {
    CGFloat x = 0;
    CGFloat W = 70;
    CGFloat H = _menuView.height;
    
    for(VHToolInfo *info in self.toolInfo.sortedSubtools){
        if(!info.available){
            continue;
        }
        
        VHToolbarMenuItem *view = [VHEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, H) target:self action:@selector(tappedMenuView:) toolInfo:info];
        [_menuView addSubview:view];
        x += W;
    }
    _menuView.contentSize = CGSizeMake(MAX(x, _menuView.frame.size.width+1), 0);
}

- (void)resetImageViewFrame {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(self._scrollView.frame.size.width / size.width, self._scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * self._scrollView.zoomScale;
        CGFloat H = ratio * size.height * self._scrollView.zoomScale;
        _imageView.frame = CGRectMake((self._scrollView.width-W)/2, (self._scrollView.height-H)/2, W, H);
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated {
    CGFloat minZoomScale = self._scrollView.minimumZoomScale;
    self._scrollView.maximumZoomScale = 0.95*minZoomScale;
    self._scrollView.minimumZoomScale = 0.95*minZoomScale;
    [self._scrollView setZoomScale:self._scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated {
    CGFloat Rw = self._scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = self._scrollView.frame.size.height / _imageView.frame.size.height;
    
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * self._scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * self._scrollView.frame.size.height));
    
    self._scrollView.contentSize = _imageView.frame.size;
    self._scrollView.minimumZoomScale = 1;
    self._scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [self._scrollView setZoomScale:self._scrollView.minimumZoomScale animated:animated];
}

- (void)refreshImageView {
    _imageView.image = _originalImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark- Tool actions

- (void)setCurrentTool:(VHToolBase *)currentTool {
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditting:(_currentTool!=nil)];
    }
}

#pragma mark- Menu actions

- (void)swapMenuViewWithEditting:(BOOL)editting {
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         if(editting){
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity;
                         }
                     }
     ];
}

- (void)swapNavigationBarWithEditting:(BOOL)editting {
    if(self.navigationController==nil){
        return;
    }
    
    [self.navigationController setNavigationBarHidden:editting animated:YES];
    
    if(editting){
        self._navigationBar.hidden = NO;
        self._navigationBar.transform = CGAffineTransformMakeTranslation(0, -self._navigationBar.height);
        
        [UIView animateWithDuration:kVHToolAnimationDuration
                         animations:^{
                             self._navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
    else {
        [UIView animateWithDuration:kVHToolAnimationDuration
                         animations:^{
                             self._navigationBar.transform = CGAffineTransformMakeTranslation(0, -self._navigationBar.height);
                         }
                         completion:^(BOOL finished) {
                             self._navigationBar.hidden = YES;
                             self._navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
}

- (void)swapToolBarWithEditting:(BOOL)editting {
    [self swapMenuViewWithEditting:editting];
    [self swapNavigationBarWithEditting:editting];
    
    if(self.currentTool){
        UINavigationItem *item  = [[UINavigationItem alloc] initWithTitle:self.currentTool.toolInfo.title];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"VHEditor_OKBtnTitle", nil, [VHEditorTheme bundle], @"OK", @"") style:UIBarButtonItemStyleDone target:self action:@selector(pushedDoneBtn:)];
        item.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"VHEditor_BackBtnTitle", nil, [VHEditorTheme bundle], @"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
        
        [self._navigationBar pushNavigationItem:item animated:(self.navigationController==nil)];
    }
    else{
        [self._navigationBar popNavigationItemAnimated:(self.navigationController==nil)];
    }
}

- (void)setupToolWithToolInfo:(VHToolInfo*)info {
    if(self.currentTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[VHToolBase class]]){
            instance = [instance initWithImageEditor:self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

- (void)tappedMenuView:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kVHToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    [self setupToolWithToolInfo:view.toolInfo];
}

- (IBAction)pushedCancelBtn:(id)sender {
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    
    self.currentTool = nil;
}

- (IBAction)pushedDoneBtn:(id)sender {
    self.view.userInteractionEnabled = NO;
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if(error){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(image){
            _originalImage = image;
            _imageView.image = image;
            
            [self resetImageViewFrame];
            self.currentTool = nil;
        }
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)pushedCloseBtn:(id)sender {
    if(self.targetImageView==nil){
        if([self.delegate respondsToSelector:@selector(imageEditorDidCancel:)]){
            [self.delegate imageEditorDidCancel:self];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        _imageView.image = self.targetImageView.image;
        [self restoreImageView:YES];
    }
}

- (void)pushedFinishBtn:(id)sender {
    if(self.targetImageView==nil){
        if([self.delegate respondsToSelector:@selector(imageEditor:didFinishEditWithImage:)]){
            [self.delegate imageEditor:self didFinishEditWithImage:_originalImage];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        _imageView.image = _originalImage;
        [self restoreImageView:NO];
    }
}

#pragma mark- ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat Ws = self._scrollView.frame.size.width - self._scrollView.contentInset.left - self._scrollView.contentInset.right;
    CGFloat Hs = self._scrollView.frame.size.height - self._scrollView.contentInset.top - self._scrollView.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

@end
