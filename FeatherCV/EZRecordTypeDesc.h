//
//  EZRecordTypeDesc.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZRecordTypeDesc : NSObject

- (id) initWith:(NSString*) name type:(EZTrackRecordType)type icon:(NSString*)iconURL blueIcon:(NSString*)blueIcon headerIcon:(NSString*)headerIcon unitName:(NSString*)unitName  selected:(BOOL)selected;

@property (nonatomic, assign) EZTrackRecordType type;

@property (nonatomic, strong) NSString* iconURL;

@property (nonatomic, strong) NSString* blueIconURL;

@property (nonatomic, strong) NSString* unitName;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* headerIcon;

@property (nonatomic, assign) int priority;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) BOOL tmpSelected;

@end
