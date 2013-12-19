//
//  EZMotionUtility.h
//  MotionGraphs
//
//  Created by xietian on 13-11-6.
//
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "EZAppConstants.h"

typedef enum {
    kEZGravity,
    kEZGyro,
    kEZRotation
} EZMotionType;

@interface EZMotionData : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat z;

@property (nonatomic, assign) CGFloat yaw;
@property (nonatomic, assign) CGFloat pitch;
@property (nonatomic, assign) CGFloat roll;

@property (nonatomic, strong) NSMutableArray* storedMotion;
@property (nonatomic, strong) CMAttitude* currentMotion;
@property (nonatomic, strong) CMAttitude* previousMotion;

@end

@interface EZRegisteredHandler : NSObject

@property (nonatomic, strong) EZEventBlock handler;

@property (nonatomic, assign) EZMotionType type;

@property (nonatomic, strong) NSString* key;

@end

@interface EZMotionUtility : NSObject

@property(nonatomic, strong) CMMotionManager* motionManager;

@property(nonatomic, assign) BOOL isUpdating;

@property(nonatomic, strong) NSMutableDictionary* registeredHandler;

@property(nonatomic, strong) NSMutableDictionary* updateStatus;

@property(nonatomic, strong) NSMutableArray* storedMotions;

+ (EZMotionUtility*) getInstance;


- (void) registerHandler:(EZEventBlock)handler key:(NSString*)handler type:(EZMotionType)type;

- (void) unregisterHandler:(NSString*)handler;

@end
