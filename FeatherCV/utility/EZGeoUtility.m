//
//  EZGeoUtility.m
//  ShowHair
//
//  Created by xietian on 13-4-2.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <CoreLocation/CLPlacemark.h>
#import "EZGeoUtility.h"
#import "EZMessageCenter.h"

static EZGeoUtility* instance;

@implementation EZGeoUtility

+ (EZGeoUtility*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZGeoUtility alloc] init];
    });
    return instance;
}

- (id) init
{
    self = [super init];
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    _locationManager.delegate = self;
    EZDEBUG(@"location service enabled:%i",[CLLocationManager locationServicesEnabled]);
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    EZDEBUG(@"location manager get error:%@", error);
    _currLocationStatus = false;
    [[EZMessageCenter getInstance] postEvent:LocationUpdated attached:self];
    [_locationManager stopUpdatingLocation];
}

- (NSString*) locationToStr:(CLLocation*)loc
{
    
    return [ NSString stringWithFormat:@"latitude:%3.6f,%3.6f" , loc.coordinate.latitude, loc.coordinate.longitude ];
}

- (void)locationManager:(CLLocationManager *)manager
didUpdateLocations:(NSArray *)locations
{
    EZDEBUG(@"Location updated, the location is:%i", locations.count);
    _currLocationStatus = TRUE;
    if(locations.count > 0){
        CLLocation *defaultLocation = [locations objectAtIndex:0];
        EZDEBUG(@"default location is:%@",[self locationToStr:defaultLocation]);
        _currentLocation = defaultLocation;
        
    }
    [[EZMessageCenter getInstance] postEvent:LocationUpdated attached:self.currentLocation];
    [_locationManager stopUpdatingLocation];
}

- (void) findCurrentLocation:(EZEventBlock)updated once:(BOOL)once
{
    [[EZMessageCenter getInstance] registerEvent:LocationUpdated block:updated once:once];
    [_locationManager startUpdatingLocation];
}

- (void) locationToAddress:(CLLocation*)loc success:(EZEventBlock)success failure:(EZEventBlock)failur
{
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:37.78583400 longitude:-122.40641700];
    [_geocoder reverseGeocodeLocation:loc
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       EZDEBUG(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       if (error){
                           EZDEBUG(@"Geocode failed with error: %@", error);
                           if(failur){
                               failur(error);
                           }
                           return;
                           
                       }
                       
                       if(placemarks && placemarks.count > 0)
                           
                       {
                           //do something
                           CLPlacemark *topResult = [placemarks objectAtIndex:0];
                           NSString *addressTxt = [NSString stringWithFormat:@"%@ %@,%@ %@",
                                                   topResult.subThoroughfare,topResult.thoroughfare,
                                                   topResult.locality, topResult.administrativeArea];
                           NSString *addressStr = [NSString stringWithFormat:@"%@,%@", topResult.administrativeArea, topResult.thoroughfare];
                           EZDEBUG(@"return address:%@",addressTxt);
                           success(addressStr);
                       }
                   }];
}

@end
