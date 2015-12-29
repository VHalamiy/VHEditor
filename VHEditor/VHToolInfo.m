//
//  VHToolInfo.m
//
//
//  Created by Little Yoda on 19.11.15.
//  Copyright (c) 2015 Little Yoda. All rights reserved.
//

#import "VHToolInfo.h"

@interface VHToolInfo()

@property (nonatomic, strong) NSString *toolName;
@property (nonatomic, strong) NSArray *subtools;

@end

@implementation VHToolInfo

- (void)setObject:(id)object forKey:(NSString *)key inDictionary:(NSMutableDictionary *)dictionary {
    if(object){
        dictionary[key] = object;
    }
}

- (NSDictionary *)descriptionDictionary {
    NSMutableArray *array = [NSMutableArray array];
    for(VHToolInfo *sub in self.sortedSubtools){
        [array addObject:sub.descriptionDictionary];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self setObject:self.toolName forKey:@"toolName"  inDictionary:dict];
    [self setObject:self.title forKey:@"title" inDictionary:dict];
    [self setObject:((self.available)?@"YES":@"NO") forKey:@"available" inDictionary:dict];
    [self setObject:@(self.dockedNumber) forKey:@"dockedNumber" inDictionary:dict];
    [self setObject:self.iconImagePath forKey:@"iconImagePath" inDictionary:dict];
    [self setObject:array forKey:@"subtools" inDictionary:dict];
    if(self.optionalInfo){
        [self setObject:self.optionalInfo forKey:@"optionalInfo" inDictionary:dict];
    }
        return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.descriptionDictionary];
}

- (UIImage *)iconImage {
    return [UIImage imageNamed:self.iconImagePath];
}

- (NSString *)toolName {
    if([_toolName isEqualToString:@"_VHEditorViewController"]){
        return @"VHEditor";
    }
    return _toolName;
}

- (NSArray *)sortedSubtools {
    self.subtools = [self.subtools sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat dockedNum1 = [obj1 dockedNumber];
        CGFloat dockedNum2 = [obj2 dockedNumber];
        
        if(dockedNum1 < dockedNum2){ return NSOrderedAscending; }
        else if(dockedNum1 > dockedNum2){ return NSOrderedDescending; }
        return NSOrderedSame;
    }];
    return self.subtools;
}


@end
