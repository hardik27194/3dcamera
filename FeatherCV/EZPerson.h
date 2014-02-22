//
//  EZPerson.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZPerson : NSObject

@property (nonatomic, strong) NSString* personID;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* mobile;

@property (nonatomic, strong) NSString* avatar;

@property (nonatomic, strong) NSString* email;

//A default user
//Anything need a mock user to success
@property (nonatomic, assign) BOOL mock;

@property (nonatomic, strong) NSDate* joinedTime;

//If this user is already feather client or not
@property (nonatomic, assign) BOOL joined;

- (NSDictionary*) toJson;

- (void) fromJson:(NSDictionary*)dict;

@end
