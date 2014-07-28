//
//  EZProfile.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    kMotherProfile,
    kChildProfile
}EZProfileType;

typedef enum{
    kGenderMale,
    kGenderFemale
}EZGenderCode;
//Used to represent the mother and the child.
//I would like to differentiate this with the account details.
@interface EZProfile : NSObject

- (id) initWith:(NSString*)name type:(EZProfileType)type avatar:(NSString*)avatar;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, assign) EZProfileType type;

@property (nonatomic, strong) NSDate* pregnantDate;

//孕中期,.....和其它一些值
@property (nonatomic, strong) NSString* stageDescription;

@property (nonatomic, strong) NSString* avartar;

@property (nonatomic, strong) NSString* profileID;

@property (nonatomic, assign) EZGenderCode gender;

@property (nonatomic, assign) NSDate* birthDate;

@end
