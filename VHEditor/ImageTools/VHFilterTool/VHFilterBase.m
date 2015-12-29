//
//  VHFilterBase.m
//
//
//  Created by Little Yoda on 25.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHFilterBase.h"

@implementation VHFilterBase

+ (NSString *)defaultIconImagePath {
    return nil;
}

+ (NSArray *)subtools {
    return nil;
}

+ (CGFloat)defaultDockedNumber {
    return 0;
}

+ (NSString *)defaultTitle {
    return @"VHFilterBase";
}

+ (BOOL)isAvailable {
    return NO;
}

+ (NSDictionary *)optionalInfo {
    return nil;
}

#pragma mark-

+ (UIImage*)applyFilter:(UIImage*)image {
    return image;
}

@end




#pragma mark- Default Filters


@interface VHDefaultEmptyFilter : VHFilterBase

@end

@implementation VHDefaultEmptyFilter

+ (NSDictionary *)defaultFilterInfo {
    NSDictionary *defaultFilterInfo = nil;
    if(defaultFilterInfo==nil){
        defaultFilterInfo =
        @{
            @"VHDefaultEmptyFilter"     : @{@"name":@"VHDefaultEmptyFilter",     @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultEmptyFilter_DefaultTitle",    nil, [VHEditorTheme bundle], @"None", @""),       @"version":@(0.0), @"dockedNum":@(0.0)},
            @"VHDefaultLinearFilter"    : @{@"name":@"CISRGBToneCurveToLinear",  @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultLinearFilter_DefaultTitle",   nil, [VHEditorTheme bundle], @"Linear", @""),     @"version":@(7.0), @"dockedNum":@(1.0)},
            @"VHDefaultVignetteFilter"  : @{@"name":@"CIVignetteEffect",         @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultVignetteFilter_DefaultTitle", nil, [VHEditorTheme bundle], @"Vignette", @""),   @"version":@(7.0), @"dockedNum":@(2.0)},
            @"VHDefaultInstantFilter"   : @{@"name":@"CIPhotoEffectInstant",     @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultInstantFilter_DefaultTitle",  nil, [VHEditorTheme bundle], @"Instant", @""),    @"version":@(7.0), @"dockedNum":@(3.0)},
            @"VHDefaultProcessFilter"   : @{@"name":@"CIPhotoEffectProcess",     @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultProcessFilter_DefaultTitle",  nil, [VHEditorTheme bundle], @"Process", @""),    @"version":@(7.0), @"dockedNum":@(4.0)},
            @"VHDefaultTransferFilter"  : @{@"name":@"CIPhotoEffectTransfer",    @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultTransferFilter_DefaultTitle", nil, [VHEditorTheme bundle], @"Transfer", @""),   @"version":@(7.0), @"dockedNum":@(5.0)},
            @"VHDefaultSepiaFilter"     : @{@"name":@"CISepiaTone",              @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultSepiaFilter_DefaultTitle",    nil, [VHEditorTheme bundle], @"Sepia", @""),      @"version":@(5.0), @"dockedNum":@(6.0)},
            @"VHDefaultChromeFilter"    : @{@"name":@"CIPhotoEffectChrome",      @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultChromeFilter_DefaultTitle",   nil, [VHEditorTheme bundle], @"Chrome", @""),     @"version":@(7.0), @"dockedNum":@(7.0)},
            @"VHDefaultFadeFilter"      : @{@"name":@"CIPhotoEffectFade",        @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultFadeFilter_DefaultTitle",     nil, [VHEditorTheme bundle], @"Fade", @""),       @"version":@(7.0), @"dockedNum":@(8.0)},
            @"VHDefaultCurveFilter"     : @{@"name":@"CILinearToSRGBToneCurve",  @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultCurveFilter_DefaultTitle",    nil, [VHEditorTheme bundle], @"Curve", @""),      @"version":@(7.0), @"dockedNum":@(9.0)},
            @"VHDefaultTonalFilter"     : @{@"name":@"CIPhotoEffectTonal",       @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultTonalFilter_DefaultTitle",    nil, [VHEditorTheme bundle], @"Tonal", @""),      @"version":@(7.0), @"dockedNum":@(10.0)},
            @"VHDefaultNoirFilter"      : @{@"name":@"CIPhotoEffectNoir",        @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultNoirFilter_DefaultTitle",     nil, [VHEditorTheme bundle], @"Noir", @""),       @"version":@(7.0), @"dockedNum":@(11.0)},
            @"VHDefaultMonoFilter"      : @{@"name":@"CIPhotoEffectMono",        @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultMonoFilter_DefaultTitle",     nil, [VHEditorTheme bundle], @"Mono", @""),       @"version":@(7.0), @"dockedNum":@(12.0)},
            @"VHDefaultInvertFilter"    : @{@"name":@"CIColorInvert",            @"title":NSLocalizedStringWithDefaultValue(@"VHDefaultInvertFilter_DefaultTitle",   nil, [VHEditorTheme bundle], @"Invert", @""),     @"version":@(6.0), @"dockedNum":@(13.0)},
        };
    }
    return defaultFilterInfo;
}

+ (id)defaultInfoForKey:(NSString *)key {
    return self.defaultFilterInfo[NSStringFromClass(self)][key];
}

+ (NSString *)filterName {
    return [self defaultInfoForKey:@"name"];
}

#pragma mark- 

+ (NSString *)defaultTitle {
    return [self defaultInfoForKey:@"title"];
}

+ (BOOL)isAvailable {
    return ([UIDevice iosVersion] >= [[self defaultInfoForKey:@"version"] floatValue]);
}

+ (CGFloat)defaultDockedNumber {
    return [[self defaultInfoForKey:@"dockedNum"] floatValue];
}

#pragma mark- 

+ (UIImage *)applyFilter:(UIImage *)image {
    return [self filteredImage:image withFilterName:self.filterName];
}

+ (UIImage *)filteredImage:(UIImage *)image withFilterName:(NSString *)filterName {
    if([filterName isEqualToString:@"VHDefaultEmptyFilter"]){
        return image;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        
        CGFloat R = MIN(image.size.width, image.size.height)/2;
        CIVector *vct = [[CIVector alloc] initWithX:image.size.width/2 Y:image.size.height/2];
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end



@interface VHDefaultLinearFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultLinearFilter
@end

@interface VHDefaultVignetteFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultVignetteFilter
@end

@interface VHDefaultInstantFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultInstantFilter
@end

@interface VHDefaultProcessFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultProcessFilter
@end

@interface VHDefaultTransferFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultTransferFilter
@end

@interface VHDefaultSepiaFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultSepiaFilter
@end

@interface VHDefaultChromeFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultChromeFilter
@end

@interface VHDefaultFadeFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultFadeFilter
@end

@interface VHDefaultCurveFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultCurveFilter
@end

@interface VHDefaultTonalFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultTonalFilter
@end

@interface VHDefaultNoirFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultNoirFilter
@end

@interface VHDefaultMonoFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultMonoFilter
@end

@interface VHDefaultInvertFilter : VHDefaultEmptyFilter
@end
@implementation VHDefaultInvertFilter
@end
