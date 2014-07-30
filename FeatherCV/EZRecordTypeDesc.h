//
//  EZRecordTypeDesc.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZRecordTypeDesc : NSObject

- (id) initWith:(NSString*)name type:(EZTrackRecordType)type source:(NSString*)source unitName:(NSString*)unitName  selected:(BOOL)selected;

@property (nonatomic, assign) EZTrackRecordType type;

@property (nonatomic, strong) NSString* iconURL;

@property (nonatomic, strong) NSString* blueIconURL;

@property (nonatomic, strong) NSString* unitName;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* headerIcon;

@property (nonatomic, assign) int priority;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) BOOL tmpSelected;

//It is the type from the server side.
//But the priority will be determined by the server side.
@property (nonatomic, strong) NSString* source;

//The url to get into the detail image
@property (nonatomic, strong) NSString* detailURL;

//The graphURL will display the latest graph
@property (nonatomic, strong) NSString* graphURL;


@end
