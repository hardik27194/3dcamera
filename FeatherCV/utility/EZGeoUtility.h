//
//  EZGeoUtility.h
//  ShowHair
//
//  Created by xietian on 13-4-2.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreLocation/CLLocationManagerDelegate.h>
#include <CoreLocation/CLError.h>
#include <CoreLocation/CLLocation.h>
#include <CoreLocation/CLLocationManager.h>
#include <CoreLocation/CLGeocoder.h>
#import "EZConstants.h"

#define LocationUpdated @"LocationUpdated"

#define num2loc(lati, longi)  [[CLLocation alloc] initWithLatitude:lati longitude:longi]; 

@interface EZGeoUtility : NSObject<CLLocationManagerDelegate>

+ (EZGeoUtility*) getInstance;

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) CLGeocoder *geocoder;

@property (strong, nonatomic) CLLocation* currentLocation;

@property (assign, nonatomic) BOOL currLocationStatus;

- (void) findCurrentLocation:(EZEventBlock)serviceBlock once:(BOOL)once;


- (void) locationToAddress:(CLLocation*)loc success:(EZEventBlock)success failure:(EZEventBlock)failure;


@end
