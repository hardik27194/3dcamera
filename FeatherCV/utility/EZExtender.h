//
//  EZTaskHelper.h
//  SqueezitProto
//
//  Created by Apple on 12-5-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"


typedef void (^ EZEventOpsBlock) (id sender);

typedef BOOL (^ FilterOperation)(id obj);

typedef id (^ MapCarOperation)(id obj);

typedef void  (^ IterateOperation)(id obj);

@class NSManagedObject, EZArray, EZBlockWrapper;

@protocol EZValueObject <NSObject>


@required
- (id) initWithVO:(id<EZValueObject>) valueObj;

- (id) cloneVO;

- (id) initWithPO:(NSManagedObject*)mtk;

- (NSManagedObject*) createPO;

- (NSManagedObject*) populatePO:(NSManagedObject*)po;

- (NSManagedObject*) PO;

- (void) setPO:(NSManagedObject*)po;

//Will fetch the value from the database again.
- (void) refresh;

@end


@interface UINavigationBar(EZPrivate)

- (void) setTitleColor:(UIColor*)color;

- (void) setFunctionalTitle;

- (void) setNormalTitle;

@end

@interface NSIndexPath(EZPrivate)

- (NSString*) getKey;

@end

@interface UIImageView(EZPrivate)


+ (UIImage*) getCachedImage:(NSURL*)url;

- (void) loadImageURL:(NSString*)url haveThumb:(BOOL)thumb loading:(BOOL)loading;

@end

@interface UILabel(EZPrivate)

- (CGFloat) calcRegionDelta:(NSString*)string;

- (CGSize) calcRegion:(NSString*)text;

- (CGSize) calcRegion:(NSString*)string height:(CGFloat)height;

- (CGSize) calcRegion:(NSString *)text width:(CGFloat)width;

- (CGSize) adjustRegion;

- (CGFloat) adjustRegionDelta;

- (CGFloat) adjustHorizonDelta;

//It based on the mistunderstand I have. Let's fix the misunderstand. 
- (CGSize) calcRegion:(NSString*)string size:(CGSize)size;

- (NSString*) getEqualSpace;

- (NSString*) getEqualSpace:(NSString*)str;

//Finally get a more general method to handle this
- (CGSize) calcDelta:(NSString*)string region:(CGSize)region originSize:(CGSize)originSize;

- (void) enableTextWrap;

//- (void) enableShadow:(UIColor*)color;

@end

@interface NSString(EZPrivate)

- (NSString*) trim;

- (NSInteger) hexToInt;

- (NSString*) toSpace;

- (NSString*) urlEncode;

- (NSMutableString*) toMutableSpace;

- (NSString*) truncate:(NSInteger)length;

- (NSString*) getIntegerStr;

- (BOOL) isEmpty;

- (BOOL) isNotEmpty;

- (BOOL) isValidEmail;

@end

@interface NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexString;

@end


@interface UIBarButtonItem(EZPrivate)

+ (UIBarButtonItem*) createButton:(NSString*)normal hightlight:(NSString*)highlight target:(id)target sel:(SEL)sel;

@end

@interface UIView(EZPrivate)

- (UIImage*) createBlurImage:(CGFloat)blurRadius;

- (void) blurSwitch:(UIView*)src dest:(UIView*)dest blurRadius:(CGFloat)radius duration:(CGFloat)duration complete:(EZEventBlock)completion;

- (void) runSpinAnimation:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;

+ (void) sequenceAnimation:(NSArray*)animation completion:(EZOperationBlock)complete;

+ (void) flipTransition:(UIView*)src dest:(UIView*)dest container:(UIView*)container isLeft:(BOOL)isLeft duration:(float)duration complete:(EZEventBlock)complete;

//The code which can rotate the view to a particlar angle.
- (void) rotateAngle:(CGFloat)angle;

- (void) enableRoundImage;

- (UIImage*) contentAsImage;

- (void) addHaloEffects;

- (void) removeAllSubviews;

- (void) setPosition:(CGPoint)pos;

- (void) setSize:(CGSize)size;

- (void) setLeft:(CGFloat)distance;
- (CGFloat) left;

- (CGFloat) getY;

- (CGFloat) getX;

- (void) setX:(CGFloat)x;

- (void) setY:(CGFloat)y;

- (void) moveY:(CGFloat)deltaY;

- (void) moveX:(CGFloat)deltaX;

- (void) setWidth:(CGFloat)width;

- (void) setHeight:(CGFloat)height;

- (void) addHeight:(CGFloat)delta;

- (void) addWidth:(CGFloat)delta;

- (void) setTop:(CGFloat)distance;
- (CGFloat) top;

- (void) setRight:(CGFloat)distance;
- (CGFloat) right;

- (CGFloat) bottom;

- (void) setBottom:(CGFloat)bottom;

- (CGFloat) width;

- (CGFloat) height;

- (CGFloat) centerX;

- (CGFloat) centerY;

- (void) setCenterX:(CGFloat)x;

- (void) enableShadow:(UIColor*)color;

- (void) setCenterY:(CGFloat)y;

//Will align with the bottom of the super.
//Enjoy this, you have infinite number of time to do this. 
- (void) setAlignBottom:(CGFloat)distance;
- (CGFloat) alignBottom;


- (UIView*) getCoverView:(NSInteger)tag;

- (UIView*) createCoverView:(NSInteger)tag;

- (void) addGradient:(NSArray*)colors points:(NSArray*)points corner:(CGFloat)corner;

- (void) addGradient:(NSArray*)colors points:(NSArray*)points;

- (void) addBackGradient:(NSArray *)colors points:(NSArray *)points;

//What's the purpose of this method?
//Generate a gradients which repeat several times
//Why do we do this?
//To make the cell without data look more consistent.
- (void) addRepeatGradient:(NSArray *)colors points:(NSArray *)points repeatTimes:(NSInteger)repeats;

//Will keep the apect of current size and fit the most.
- (void) fitTo:(CGRect)frame;

- (void) fitToMode:(CGRect)frame;

- (void) addShadow:(UIColor*)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;

- (EZEventBlock) createResetBlock;

@end

@interface UIButton(EZPrivate)

- (void) addBlockWrapper:(EZBlockWrapper*)bw;

@end
/**
@interface UIButton(EZPrivate)

- (void) addGradient:(NSArray*)colors points:(NSArray*)points corner:(CGFloat)corner;

- (void) addGradient:(NSArray*)colors points:(NSArray*)points;

- (void) addBackGradient:(NSArray *)colors points:(NSArray *)points;

//What's the purpose of this method?
//Generate a gradients which repeat several times
//Why do we do this?
//To make the cell without data look more consistent.
- (void) addRepeatGradient:(NSArray *)colors points:(NSArray *)points repeatTimes:(NSInteger)repeats;


@end
**/
@interface UIColor(EZPrivate)

+ (UIColor*) colorFromHex:(NSString*)hexStr;

+ (UIColor*) colorFromDecimal:(NSString*)hexStr;

- (NSString*) toHexString;


@end

//Turn the image into data;
@interface UIImage(EZPrivate)

- (NSData*) toData;

- (NSData*) toJpegData;

- (UIImage*) resizableImage:(UIEdgeInsets)insects;

@end

@interface UIApplication (EZPrivate)

- (void)addSubViewOnFrontWindow:(UIView *)view;

+ (void) addTopView:(UIView*)view;

@end



@interface NSArray(EZPrivate)

- (NSArray*) filter:(FilterOperation)opts;

- (NSArray*) mapcar:(MapCarOperation)opts;

- (NSArray*) reverse;

- (void) iterate:(IterateOperation) opts;

- (NSArray*) insertObject:(id)obj;

- (NSArray*) removeObject:(id)obj;

- (NSArray*) insertObjects:(id)objs;

- (NSArray*) addObject:(id)obj;

- (NSArray*) removeHeader;

@end

@interface NSMutableArray(EZPrivate)



@end

@interface NSDictionary(EZPrivate)

- (id) objectForKeyPath:(NSString*)path;

@end


@interface NSNumber(EZPrivate)

+ (NSNumber*) initFloat:(CGFloat)ft;

@end

@interface NSObject(EZPrivate)

- (void) performBlock:(EZOperationBlock)block withDelay:(NSTimeInterval)delay;

- (void) executeBlock:(EZOperationBlock)block;

- (void) executeBlockInBackground:(EZOperationBlock)block inThread:(NSThread*)thread;

- (void) executeBlockInMainThread:(EZOperationBlock)block;

- (NSString*) toJSONString;


@end

@interface NSDate(EZPrivate) 

- (NSInteger) convertDays;

- (NSDate*) beginning;

- (NSDate*) ending;

- (NSString*) getLocalWeekName;

- (NSString*) showTimeDetail;

- (NSString*) showStarString;

- (int) orgWeekDay;

- (int) monthDay;

- (int) getYear;

- (int) getMonth;

- (int) getMonthDay;

+ (NSDate*) stringToDate:(NSString*)format dateString:(NSString*)dateStr;

- (NSString*) stringWithFormat:(NSString*)format;

- (NSDate*) adjustDays:(int)days;

- (NSDate*) adjustYears:(int)years;

- (NSDate*) adjustMinutes:(int)minutes;

- (NSDate*) adjust:(NSTimeInterval)delta;

- (NSComparisonResult) compareTime:(NSDate*)date;

- (NSDate*) combineTime:(NSDate*)time;

//True mean they are equal with the format, False mean not equal. 
- (BOOL) equalWith:(NSDate*)date format:(NSString*)format;

//Check if the date fall inbetween the specified start and end.
//It will including the stat and end date.
- (BOOL) InBetweenDays:(NSDate*)start end:(NSDate*)end;

- (BOOL) InBetween:(NSDate*)start end:(NSDate*)end;

//Wether have passed the passin time or not
- (BOOL) isPassed:(NSDate*)date;

@end

@class EZAvailableDay, EZQuotas;

NSUInteger removeFrom(NSUInteger flag, NSUInteger envFlags);

BOOL isContained(NSUInteger flag, NSUInteger envFlags);

//Find in the fractors array if any number could be divided from the target
NSUInteger findFractor(NSUInteger target, EZArray* flags);

NSUInteger combineFlags(NSUInteger flag, NSUInteger envFlags);

//The flags mean all the existed prime number, make sure the all the prime number are found on sequence
NSUInteger findNextFlag(EZArray* flags);

NSUInteger findPrimeAfter(NSUInteger primed);

@interface EZTaskHelper : NSObject


+ (int) getMonthLength:(NSDate*)date;

+ (NSString*) weekFlagToWeekString:(NSInteger)weekFlags;

+ (NSThread*) getBackgroundThread;

//This will be executed in the natural background.
//+ (void) executeBlockInBackground:(EZOperationBlock)block;

+ (void) executeBlockInBG:(EZOperationBlock)block;

+ (void) executeBlockInMain:(EZOperationBlock)block;
//+ (NSString*) envTraitsToString:(NSInteger)envTraits;

@end
