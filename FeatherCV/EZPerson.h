//
//  EZPerson.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZPerson : NSObject

@property (nonatomic, assign) int personID;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* mobile;

@property (nonatomic, strong) NSString* avatar;

@property (nonatomic, strong) NSString* email;

@property (nonatomic, strong) NSDate* joinedTime;

//If this user is already feather client or not
@property (nonatomic, assign) BOOL joined;

- (NSDictionary*) toMap;

- (id) initFromDict:(NSDictionary*)dict;

@end
