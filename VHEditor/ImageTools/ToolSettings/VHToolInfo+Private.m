//
//  VHToolInfo+Private.m
//
//
//  Created by Little Yoda on 03.12.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHToolInfo+Private.h"

#import "VHToolProtocol.h"
#import "VHClassList.h"


@interface VHToolInfo()
@property (nonatomic, strong) NSString *toolName;
@property (nonatomic, strong) NSArray *subtools;
@end

@implementation VHToolInfo (Private)

+ (VHToolInfo*)toolInfoForToolClass:(Class<VHToolProtocol>)toolClass;
{
    if([(Class)toolClass conformsToProtocol:@protocol(VHToolProtocol)] && [toolClass isAvailable]){
        VHToolInfo *info = [VHToolInfo new];
        info.toolName  = NSStringFromClass(toolClass);
        info.title     = [toolClass defaultTitle];
        info.available = YES;
        info.dockedNumber = [toolClass defaultDockedNumber];
        info.iconImagePath = [toolClass defaultIconImagePath];
        info.subtools = [toolClass subtools];
        info.optionalInfo = [[toolClass optionalInfo] mutableCopy];
        
        return info;
    }
    return nil;
}

+ (NSArray*)toolsWithToolClass:(Class<VHToolProtocol>)toolClass
{
    NSMutableArray *array = [NSMutableArray array];
    
    VHToolInfo *info = [VHToolInfo toolInfoForToolClass:toolClass];
    if(info){
        [array addObject:info];
    }
    
    NSArray *list = [VHClassList subclassesOfClass:toolClass];
    for(Class subtool in list){
        info = [VHToolInfo toolInfoForToolClass:subtool];
        if(info){
            [array addObject:info];
        }
    }
    return [array copy];
}

@end
