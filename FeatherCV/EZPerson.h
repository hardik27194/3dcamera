//
//  EZPerson.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalPersons.h"

typedef enum {
    kMale,
    kFemale,
    kUnknown
}EZGender;

@interface EZPerson : NSObject

@property (nonatomic, strong) NSString* personID;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* mobile;

@property (nonatomic, strong) NSString* avatar;

@property (nonatomic, strong) NSString* email;

@property (nonatomic, strong) NSString* pushToken;

@property (nonatomic, assign) EZGender gender;

@property (nonatomic, strong) NSString* signature;

//A default user
//Anything need a mock user to success
@property (nonatomic, assign) BOOL mock;

@property (nonatomic, strong) NSDate* joinedTime;

@property (nonatomic, assign) EZFilterType filterType;

//If this user is already feather client or not
//joined is good enough
//What's the meaning of not jointed?
//Which is really confusing.
//joined is false, mean this is a mock user. 
@property (nonatomic, assign) BOOL joined;

@property (nonatomic, assign) BOOL isFriend;

//Mean this person are querying.
//You can add key-value pair to listen to this value.
@property (nonatomic, assign) BOOL isQuerying;

@property (nonatomic, assign) BOOL isReloading;

@property (nonatomic, assign) BOOL uploaded;

@property (nonatomic, assign) int photoCount;

@property (nonatomic, assign) int touchCount;

//Used to sort the user in the array.
@property (nonatomic, strong) NSDate* lastActive;

//My touch time for this person.
@property (nonatomic, strong) NSDate* lastMineActive;

@property (nonatomic, assign) NSInteger activityCount;

@property (nonatomic, strong) LocalPersons* localPerson;

@property (nonatomic, strong) NSDate* lastUpdate;



//Will be use to remind how many pending event on this user.
@property (nonatomic, assign) int pendingEventCount;

- (NSDictionary*) toJson;

- (NSDictionary*) toLocalJson;

- (void) fromJson:(NSDictionary*)dict;

- (void) fromLocalJson:(NSDictionary*)dict;

- (void) copyValue:(EZPerson*)ps;

- (void) adjustPendingEventCount:(NSInteger)inc;

- (void) save;

@end
