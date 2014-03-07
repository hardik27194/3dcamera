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
//joined is good enough
//What's the meaning of not jointed?
//Which is really confusing.
//joined is false, mean this is a mock user. 
@property (nonatomic, assign) BOOL joined;

//Mean this person are querying.
//You can add key-value pair to listen to this value.
@property (nonatomic, assign) BOOL isQuerying;

//Used to sort the user in the array.
@property (nonatomic, strong) NSDate* lastActive;

- (NSDictionary*) toJson;

- (void) fromJson:(NSDictionary*)dict;

@end
