//
//  ViewController.m
//
//
//  Created by Little Yoda on 18.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "ViewController.h"

#import "VHEditor.h"

@interface ViewController () <VHEditorDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshImageView {
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:YES];
}

- (void)clickedNewButton {
    UIActionSheet *mysheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [mysheet showInView:self.view.window];
}

- (void)clickedEditButton {
    if(self._imageView.image) {
        VHEditor *myeditor = [[VHEditor alloc] initWithImage:self._imageView.image delegate:self];
        [self presentViewController:myeditor animated:YES completion:nil];
    }
    else {
        [self clickedNewButton];
    }
}

- (void)clickedSaveButton {
    if(self._imageView.image) {
        UIActivityViewController *myactivityView = [[UIActivityViewController alloc] initWithActivityItems:@[self._imageView.image] applicationActivities:nil];
        NSArray *excludedActivityTypes = @[UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAirDrop,
                                           UIActivityTypeMessage,
                                           UIActivityTypeMail];
        myactivityView.excludedActivityTypes = excludedActivityTypes;
        myactivityView.completionHandler = ^(NSString *activityType, BOOL completed) {
            if(completed && [activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Saved successfully"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        };
        
        [self presentViewController:myactivityView animated:NO completion:nil];
    }
    else {
        [self clickedNewButton];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *myimage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    VHEditor *myeditor = [[VHEditor alloc] initWithImage:myimage];
    myeditor.delegate = self;
    
    [picker pushViewController:myeditor animated:YES];
}


- (void)imageEditor:(VHEditor *)editor didFinishEditWithImage:(UIImage *)image {
    self._imageView.image = image;
    [self refreshImageView];
    
    [editor dismissViewControllerAnimated:YES completion:nil];
}


- (void)deselectTabBarItem:(UITabBar*)tabBar {
    tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self performSelector:@selector(deselectTabBarItem:) withObject:tabBar afterDelay:0.5];
    
    switch (item.tag) {
        case 0:
            [self clickedNewButton];
            break;
        case 1:
            [self clickedEditButton];
            break;
        case 2:
            [self clickedSaveButton];
            break;
        default:
            break;
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }
    
    UIImagePickerControllerSourceType mytype = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:mytype]){
        if(buttonIndex==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            mytype = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = mytype;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark- ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self._imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat Ws = self._scrollView.frame.size.width - self._scrollView.contentInset.left - self._scrollView.contentInset.right;
    CGFloat Hs = self._scrollView.frame.size.height - self._scrollView.contentInset.top - self._scrollView.contentInset.bottom;
    CGFloat W = self._imageView.superview.frame.size.width;
    CGFloat H = self._imageView.superview.frame.size.height;
    
    CGRect rct = self._imageView.superview.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    self._imageView.superview.frame = rct;
}

- (void)resetImageViewFrame {
    CGSize mysize = (self._imageView.image) ? self._imageView.image.size : self._imageView.frame.size;
    CGFloat myratio = MIN(self._scrollView.frame.size.width / mysize.width, self._scrollView.frame.size.height / mysize.height);
    CGFloat W = myratio * mysize.width;
    CGFloat H = myratio * mysize.height;
    self._imageView.frame = CGRectMake(0, 0, W, H);
    self._imageView.superview.bounds = self._imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated {
    CGFloat Rw = self._scrollView.frame.size.width / self._imageView.frame.size.width;
    CGFloat Rh = self._scrollView.frame.size.height / self._imageView.frame.size.height;
    
    Rw = MAX(Rw, self._imageView.image.size.width / ( self._scrollView.frame.size.width));
    Rh = MAX(Rh, self._imageView.image.size.height / ( self._scrollView.frame.size.height));
    
    self._scrollView.contentSize = self._imageView.frame.size;
    self._scrollView.minimumZoomScale = 1;
    self._scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [self._scrollView setZoomScale:self._scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:self._scrollView];
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
