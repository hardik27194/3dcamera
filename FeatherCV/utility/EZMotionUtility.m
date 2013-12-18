//
//  EZMotionUtility.m
//  MotionGraphs
//
//  Created by xietian on 13-11-6.
//
//

#import "EZMotionUtility.h"

//Mean 50 time per seconds
#define EZMotionUpdateFreq 0.02
#define EZMaxQueueLength 200

@implementation EZMotionData

@end

@implementation EZRegisteredHandler

@end


static EZMotionUtility* instance;

@implementation EZMotionUtility

+ (EZMotionUtility*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZMotionUtility alloc] init];
    });
    return instance;
}

- (id) init
{
    self = [super init];
    _motionManager = [[CMMotionManager alloc] init];
    _registeredHandler = [[NSMutableDictionary alloc] init];
    _updateStatus = [[NSMutableDictionary alloc] init];
    _storedMotions = [[NSMutableArray alloc] init];
    return self;
}

- (void) registerHandler:(EZEventBlock)handler key:(NSString*)key type:(EZMotionType)type
{
    NSMutableArray* updateList = [_updateStatus objectForKey:@(type)];
    //EZDEBUG(@"type:%i, list size:%i", type, _updateStatus.count);
    if(!updateList){
        updateList = [[NSMutableArray alloc] init];
        [_updateStatus setObject:updateList forKey:@(type)];
    }
    EZRegisteredHandler* rh = [[EZRegisteredHandler alloc] init];
    rh.type = type;
    rh.key = key;
    rh.handler = handler;
    [updateList addObject:rh];
    [self addHandlerToMap:rh];
    if(updateList.count == 1){
        [self startUpdate:type];
    }

}

- (void) addHandlerToMap:(EZRegisteredHandler*)handler
{
    NSMutableArray* handlerList = [_registeredHandler objectForKey:handler.key];
    if(!handlerList){
        handlerList = [[NSMutableArray alloc] init];
        [_registeredHandler setObject:handlerList forKey:handler.key];
    }
    [handlerList addObject:handler];
}

- (void) unregisterHandler:(NSString*)key
{
    NSMutableArray* handlerList = [_registeredHandler objectForKey:key];
    [_registeredHandler removeObjectForKey:key];
    for(EZRegisteredHandler* rh in handlerList){
        [self removeHandler:rh];
    }
    
}

- (void) removeHandler:(EZRegisteredHandler*)rh
{
    NSMutableArray* handerList = [_updateStatus objectForKey:@(rh.type)];
    //EZDEBUG(@"before remove typ:%i, count:%i", rh.type, handerList.count);
    int oldSize = handerList.count;
    [handerList removeObject:rh];
    if(oldSize == 1){
        // EZDEBUG(@"I will stop update since no handler exist");
        [self stopUpdate:rh.type];
    }
}

- (void) updateHandler:(EZMotionData*)md type:(EZMotionType)type
{
    //EZDEBUG(@"update handle get called, type:%i", type);
    NSMutableArray* handlerList = [_updateStatus objectForKey:@(type)];
    EZDEBUG(@"handlerlist is:%i, for type:%i", handlerList.count, type);
    for(EZRegisteredHandler* rh in handlerList){
        rh.handler(md);
    }
}

//from my logic seems I will only get called when the first time I get here.
//Let's just do what I suppose to do, no extra-work.
- (void) startUpdate:(EZMotionType)type
{
    EZDEBUG(@"startUpdate:%i", type);
    __weak EZMotionUtility* weakSelf = self;
    switch (type) {
        case kEZGravity:{
            if([_motionManager isAccelerometerAvailable]){
                [_motionManager setAccelerometerUpdateInterval:EZMotionUpdateFreq];
                [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                    if(accelerometerData){
                        EZMotionData* md = [[EZMotionData alloc] init];
                        md.x = accelerometerData.acceleration.x;
                        md.y = accelerometerData.acceleration.y;
                        md.z = accelerometerData.acceleration.z;
                        [weakSelf updateHandler:md type:type];
                    }else{
                        EZDEBUG(@"Encounter error during accelerometer %@", error);
                    }
                }];
            }
            break;
            }
        case kEZRotation:{
            EZDEBUG(@"rotate will called:%i", [_motionManager isDeviceMotionAvailable]);
            if([_motionManager isDeviceMotionAvailable]){
                [_motionManager setDeviceMotionUpdateInterval:EZMotionUpdateFreq];
                [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
                    EZDEBUG(@"The motion uppdated:%i",(int)error);
                    if(motion){
                        EZMotionData* md = [[EZMotionData alloc] init];
                        md.pitch = motion.attitude.pitch;
                        md.roll = motion.attitude.roll;
                        md.yaw = motion.attitude.yaw;
                        md.currentMotion = motion.attitude;
                        md.storedMotion = _storedMotions;
                        [_storedMotions addObject:motion.attitude];
                        if(_storedMotions.count > EZMaxQueueLength){
                            [_storedMotions removeObjectAtIndex:0];
                        }
                        [weakSelf updateHandler:md type:type];
                    }else{
                        EZDEBUG(@"Encounter error during motion update:%@", error);
                    }
                }];
            }
            break;
        }
        case kEZGyro:{
            if([_motionManager isGyroAvailable]){
            [_motionManager setGyroUpdateInterval:EZMotionUpdateFreq];
            [_motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
                if(gyroData){
                    EZMotionData* md = [[EZMotionData alloc] init];
                    md.x = gyroData.rotationRate.x;
                    md.y = gyroData.rotationRate.y;
                    md.z = gyroData.rotationRate.z;
                    [weakSelf updateHandler:md type:type];
                }else{
                    EZDEBUG(@"Encounter error during motion update:%@", error);
                }
            }];
        }
            break;
        }
        default:
            break;
    }
    
}

//Yes, We will stop the update. 
- (void) stopUpdate:(EZMotionType)type
{
    EZDEBUG(@"stopUpdate:%i", type);
    switch (type) {
        case kEZGravity:{
            if([_motionManager isAccelerometerAvailable] && _motionManager.isAccelerometerActive){
                [_motionManager stopAccelerometerUpdates];
            }
            break;
        }
        case kEZGyro:{
            if([_motionManager isGyroAvailable] && _motionManager.isGyroActive){
                [_motionManager stopGyroUpdates];
            }
            break;
        }
        case kEZRotation:{
            if([_motionManager isDeviceMotionAvailable] && _motionManager.isDeviceMotionActive){
                [_motionManager stopDeviceMotionUpdates];
            }
            break;
        }
        default:
            break;
    }
}


@end
