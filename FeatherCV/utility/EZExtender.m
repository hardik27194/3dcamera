//
//  EZTaskHelper.m
//  SqueezitProto
//
//  Created by Apple on 12-5-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EZExtender.h"
#import "EZNetworkUtility.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "EZAppConstants.h"
#import "EZAnimationUtil.h"
#import "EZDataUtil.h"
#import "EZFileUtil.h"

static NSArray* starList;

static NSDateFormatter* staticFormatter;


@interface BlockCarrier : NSObject

- (id) initWithBlock:(EZOperationBlock)bk;

@property (strong, nonatomic) EZOperationBlock block;

- (void) runBlock;

@end

@implementation BlockCarrier
@synthesize block;

- (id) initWithBlock:(EZOperationBlock)bk
{
    self = [super init];
    block = bk;
    return self;
}

- (void) runBlock
{
    if(block){
        block();
    }
}

@end

NSString* doubleString(NSString* str)
{
    return [NSString stringWithFormat:@"%@%@", str, str];
}


@implementation NSIndexPath(EZPrivate)

- (NSString*) getKey
{
    return [NSString stringWithFormat:@"%i.%i", self.section, self.row];
}

@end

@implementation UINavigationBar(EZPrivate)

- (void) setTitleColor:(UIColor*)color
{
    [self setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      color,
      UITextAttributeTextColor,
      nil]];
}

- (void) setFunctionalTitle
{
    [self setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      functionalBarTitleColor,
      UITextAttributeTextColor,
      [UIFont boldSystemFontOfSize:15],
      UITextAttributeFont,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
      UITextAttributeTextShadowColor,
      nil]];
}

- (void) setNormalTitle
{
    [self setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      normalBarTitleColor,
      UITextAttributeTextColor,
      [UIFont boldSystemFontOfSize:17],
      UITextAttributeFont,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
      UITextAttributeTextShadowColor,
      nil]];
}

@end

@implementation UITextField(EZPrivate)

- (void) setPlainPassword
{
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
}

@end

@implementation UIImageView(EZPrivate)


+ (UIImage*) getCachedImage:(NSURL*)url
{
    
    //return [[UIImageView af_sharedImageCache] cachedImageForURL:url];
    return nil;
}

- (void) loadImageURL:(NSString*)url haveThumb:(BOOL)thumb loading:(BOOL)loading
{
    //if(thumb){
    //NSString* thumbURL = url2thumb(url);
    UIActivityIndicatorView* activity = nil;
    NSString* localURL = [[EZDataUtil getInstance] preloadImage:url success:^(NSString* fileURL){
        
        [activity stopAnimating];
        [activity removeFromSuperview];
        self.image = [UIImage imageWithContentsOfFile:url2fullpath(fileURL)];
        EZDEBUG(@"Image fully loaded, url:%@", fileURL);
        } failed:^(id obj){
            [activity stopAnimating];
            [activity removeFromSuperview];
        }];
    if(localURL){
        EZDEBUG(@"Do nothing");
    }else if(loading){
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
        [self addSubview:activity];
        [activity startAnimating];
    }
    //}
}


@end

@implementation UILabel(EZPrivate)
/**
- (CGSize) calcRegion:(NSString*)string
{
    UIFont *font = self.font;
    CGSize orgSize = self.bounds.size;
    CGSize size = [(string ? string : @"") sizeWithFont:font constrainedToSize:CGSizeMake(self.bounds.size.width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    EZDEBUG(@"Wrapped size is:%@, %@", NSStringFromCGSize(size), NSStringFromCGSize(orgSize));
    return size;
}

- (CGSize) calcRegion:(NSString*)string height:(CGFloat)height
{
    UIFont *font = self.font;
    CGSize orgSize = self.bounds.size;
    CGSize size = [(string ? string : @"") sizeWithFont:font constrainedToSize:CGSizeMake(9999, height) lineBreakMode:UILineBreakModeWordWrap];
    EZDEBUG(@"Wrapped size is:%@, %@", NSStringFromCGSize(size), NSStringFromCGSize(orgSize));
    return size;
}

- (CGSize) calcRegion:(NSString *)string width:(CGFloat)width
{
    UIFont *font = self.font;
    CGSize orgSize = self.bounds.size;
    CGSize size = [(string ? string : @"") sizeWithFont:font constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    EZDEBUG(@"Wrapped size is:%@, %@", NSStringFromCGSize(size), NSStringFromCGSize(orgSize));
    return size;
}


- (CGFloat) calcRegionDelta:(NSString*)string
{
    UIFont *font = self.font;
    CGSize orgSize = self.bounds.size;
    CGSize size = [(string ? string : @"") sizeWithFont:font constrainedToSize:CGSizeMake(self.bounds.size.width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    EZDEBUG(@"Wrapped size is:%@, %@", NSStringFromCGSize(size), NSStringFromCGSize(orgSize));
    CGFloat res  =  size.height - orgSize.height;
    return res > 0 ? res: 0;
}

- (CGSize) adjustRegion
{
    CGSize region = [self calcRegion:self.text];
    CGSize orginSize = self.frame.size;
    CGFloat res = region.height - orginSize.height;
    if(res > 0){
        self.numberOfLines = 0;
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, region.width, region.height);
    }
    return region;
}

- (NSString*) getEqualSpace
{
    return [self getEqualSpace:self.text];
}
- (void) enableTextWrap
{
    self.numberOfLines = 0;
    self.lineBreakMode = UILineBreakModeWordWrap;
}

- (NSString*) getEqualSpace:(NSString*)str
{
    if(!str){
        return @" ";
    }
    NSMutableString* res = str.toMutableSpace;
    
    CGSize orgSize = [(str ? str : @"") sizeWithFont:self.font constrainedToSize:CGSizeMake(999, self.bounds.size.height) lineBreakMode:UILineBreakModeWordWrap];
    
    for(int i = 0; i< 4*str.length; i++){
        CGSize spaceSize = [res sizeWithFont:self.font constrainedToSize:CGSizeMake(999, self.bounds.size.height) lineBreakMode:UILineBreakModeWordWrap];
        if(spaceSize.width > orgSize.width){
            return res;
        }
        [res appendString:@" "];
    }
    return res;
}

- (CGFloat) adjustHorizonDelta
{
    CGSize orginSize = self.bounds.size;
    CGSize adjusted = [self calcRegion:self.text size:CGSizeMake(999, orginSize.height)];
    EZDEBUG(@"adjustedHorizonDelta:%@, origin:%@, for string:%@", NSStringFromCGSize(adjusted), NSStringFromCGSize(orginSize), self.text);
    self.numberOfLines = 0;
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, adjusted.width, orginSize.height);
    return adjusted.width - orginSize.width;
}

- (CGSize) calcDelta:(NSString*)string region:(CGSize)region originSize:(CGSize)originSize
{
    CGSize adjusted = [self calcRegion:self.text size:region];
    return CGSizeMake(adjusted.width-originSize.width, adjusted.height - originSize.height);
}


- (CGSize) calcRegion:(NSString*)string size:(CGSize)size
{
    UIFont *font = self.font;
    CGSize adjusted = [(string ? string : @"") sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    return adjusted;
}

- (CGFloat) adjustRegionDelta
{
    CGSize region = [self calcRegion:self.text];
    CGSize orginSize = self.frame.size;
    
    CGFloat res = region.height - orginSize.height;
    
    if(res > 0){
        self.numberOfLines = 0;
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, region.width, region.height);
    }
    return res > 0? res:0;
}

**/

- (void) enableTextWrap
{
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void) disableShadow
{
    self.layer.shadowOpacity = 0.0;
}

- (void) enableShadow:(UIColor *)color
{
    //self.layer.shadowColor = color.CGColor;
    //self.layer.shadowRadius = 1.0;
    //self.layer.shadowOpacity = 0.7;
    //self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
}

@end

@implementation NSString(EZPrivate)


- (BOOL) isEmpty
{
    return [@"" isEqualToString:self.trim];
}
//Why this method is better.
//If the string is nil, this one is valid.
//Interesting. To avoid some subtle bugs.
- (BOOL) isNotEmpty
{
    return ![@"" isEqualToString:self.trim];
}

- (BOOL) isValidEmail
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    EZDEBUG(@"%i", regExMatches);
    if (regExMatches == 0) {
            return NO;
    }
    return YES;
    
}
//Implement the traditional trim, space new line etc...
- (NSString*) trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSInteger) hexToInt
{
    return strtoul([self cStringUsingEncoding:NSASCIIStringEncoding], 0, 16);
}

- (NSString*) toSpace
{
    NSMutableString* ms = [[NSMutableString alloc] initWithCapacity:self.length];
    for(int i =0; i < self.length; i++){
        [ms appendString:@""];
    }
    return ms;
}

- (NSString *)urlEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSMutableString*) toMutableSpace
{
    NSMutableString* ms = [[NSMutableString alloc] initWithCapacity:self.length];
    for(int i =0; i < self.length; i++){
        [ms appendString:@""];
    }
    return ms;
}


- (NSString*) getIntegerStr
{
    //NSMutableString* res = [[NSMutableString alloc] init];
    NSString* res = nil;
    unichar chars[self.length];// = malloc(sizeof(unichar) * self.length);
    //EZDEBUG(@"The whole length is:%i", self.length);
    int pos = 0;
    for(int i =0; i < self.length; i++){
        unichar val = [self characterAtIndex:i];
        if(val >= '0' && val <= '9'){
            chars[pos++] = val;
        }
    }
    //EZDEBUG(@"The final pos is:%i", pos);
    if(pos > 0){
        res = [NSString stringWithCharacters:chars length:pos];
        //chars[pos] = 0;
        //free(chars);
    }
    
    //EZDEBUG(@"Final string length:%i", res.length);
    //free(chars);
    return res;
}

- (NSString*) truncate:(NSInteger)length
{
    if(self.length > length){
        return [NSString  stringWithFormat:@"%@...", [self substringToIndex:length]];
    }
    return self;
}

@end

@implementation NSObject(EZPrivate)

- (void) performBlock:(EZOperationBlock)block withDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(executeBlock:) withObject:block afterDelay:delay];
}

- (void) executeBlock:(EZOperationBlock)block
{
    if(block){
        block();
    }
}

//If Most of the time it is ok
- (void) executeBlockInBackground:(EZOperationBlock)block inThread:(NSThread *)thread
{
    //[EZTaskHelper executeBlockInBG:block];
    BlockCarrier* bc = [[BlockCarrier alloc] initWithBlock:block];
    if(thread == nil){
        [bc performSelectorInBackground:@selector(runBlock) withObject:nil];
    }else{
        [bc performSelector:@selector(runBlock) onThread:thread withObject:nil waitUntilDone:NO];
    }
}

- (void) executeBlockInMainThread:(EZOperationBlock)block
{
    [EZTaskHelper executeBlockInMain:block];
}

- (NSString*) toJSONString
{
    NSDictionary* dict = [EZNetworkUtility object2Dict:self];
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end

@implementation NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned *dataBuffer = (const unsigned*)[self bytes];
    
    NSInteger dataLength = self.length;
    
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer]];
    
    return [NSString stringWithString:hexString];
}

@end


@implementation UIBarButtonItem(EZPrivate)

//Don't be perfectionism. Complete on method at a time.
+ (UIBarButtonItem*) createButton:(NSString*)normal hightlight:(NSString*)highlight target:(id)target sel:(SEL)sel
{
    UIImageView* contactsButton = [[UIImageView
                                    alloc] initWithImage:[UIImage imageNamed:normal]     highlightedImage:[UIImage imageNamed:highlight]];
    UIGestureRecognizer* recog = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
    [contactsButton addGestureRecognizer:recog];
    contactsButton.userInteractionEnabled = true;
    return [[UIBarButtonItem alloc] initWithCustomView:contactsButton];
}

@end


@implementation NSDictionary(EZPrivate)

- (id) objectForKeyPath:(NSString*)path
{
    NSArray* arr = [path componentsSeparatedByString:@"."];
    NSDictionary* dict = self;
    for(NSString* subPath in arr){
        dict =[dict objectForKey:subPath];
    }
    return dict;
}

@end

@implementation UIView(EZPrivate)

//UIView seems like the right place to put this functionality
//I love this game.
+ (void) flipTransitionOld:(UIView*)src dest:(UIView*)dest container:(UIView*)container isLeft:(BOOL)isLeft duration:(float)duration complete:(EZEventBlock)complete
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:isLeft?UIViewAnimationTransitionFlipFromLeft:UIViewAnimationTransitionFlipFromRight forView:container cache:YES];
    [src removeFromSuperview];
    [container addSubview:dest];
    [UIView commitAnimations];
}

//I use a new method, which will make the transation complete better.
+ (void) flipTransition:(UIView*)src dest:(UIView*)dest container:(UIView*)container isLeft:(BOOL)isLeft duration:(float)duration complete:(EZEventBlock)complete
{
    
    UIViewAnimationOptions direction = isLeft?UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromRight;
    
    [UIView transitionFromView:src toView:dest duration:duration options:direction|UIViewAnimationOptionCurveEaseOut completion:^(BOOL finished) {
        if(complete){
            complete(nil);
        }
    }];
}

//Then we are in good shape now.
- (void) rotateAngle:(CGFloat)angle
{
    EZDEBUG(@"Original center:%@", NSStringFromCGPoint(self.center));
    //self.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    //rotate rect
    self.transform = CGAffineTransformMakeRotation(angle);
}

- (void) runSpinAnimation:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    self.layer.zPosition = 400;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}



+ (void) sequenceAnimation:(NSArray*)animations completion:(EZOperationBlock)complete
{
    if(animations.count > 0){
        NSArray* anim = [animations objectAtIndex:0];
        CGFloat duration = [[anim objectAtIndex:0] floatValue];
        EZOperationBlock animBlock = [anim objectAtIndex:1];
        [UIView animateWithDuration:duration animations:animBlock completion:^(BOOL completed){
            [UIView sequenceAnimation:[animations removeHeader] completion:complete];
        }];
    }else{
        if(complete){
            complete();
        }
    }
}

- (void) enableRoundEdge
{
    self.layer.cornerRadius = self.bounds.size.height/2;
    self.contentMode  = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
}

- (void) enableRoundImage
{
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.contentMode  = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
}

- (uint32_t) calBlurKernel:(CGFloat)blurRadius
{
	uint32_t radius = (uint32_t)floor(blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
	radius += (radius + 1) % 2;
	return radius;
}


- (void) blurSwitch:(UIView*)src dest:(UIView*)dest blurRadius:(CGFloat)radius duration:(CGFloat)duration complete:(EZEventBlock)completion
{
    [[EZAnimationUtil sharedEZAnimationUtil] addAnimation:^(){
        
        return 1;
    }];
    
}

- (UIImage*) createBlurImage:(CGFloat)blurRadius
{
    return [[[UIImageView alloc] initWithImage:[self contentAsImage]] createBlurImageInner:blurRadius];
}

- (UIImage*) createBlurImageInner:(CGFloat)blurRadius
{
    
    //UIImage* contentImage = [self contentAsImage];
    CGFloat scaleFactor = 1.0;
    CGRect visibleRect = self.frame;
	CGSize bufferSize = CGSizeMake(self.bounds.size.width * scaleFactor, self.bounds.size.height * scaleFactor);
	if (bufferSize.width == 0 || bufferSize.height == 0) {
		return nil;
	}
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef effectInContext = CGBitmapContextCreate(NULL, bufferSize.width, bufferSize.height, 8, bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGContextRef effectOutContext = CGBitmapContextCreate(NULL, bufferSize.width, bufferSize.height, 8, bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(colorSpace);
	
	CGContextConcatCTM(effectInContext, (CGAffineTransform){
		1, 0, 0, -1, 0, bufferSize.height
	});
	CGContextScaleCTM(effectInContext,  scaleFactor, scaleFactor);
	CGContextTranslateCTM(effectInContext, -visibleRect.origin.x, -visibleRect.origin.y);
	

	vImage_Buffer effectInBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(effectInContext),
		.width = CGBitmapContextGetWidth(effectInContext),
		.height = CGBitmapContextGetHeight(effectInContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext)
	};
	
	vImage_Buffer effectOutBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(effectOutContext),
		.width = CGBitmapContextGetWidth(effectOutContext),
		.height = CGBitmapContextGetHeight(effectOutContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext)
	};
    

    //CGContextRef effectInContext = CGContextRetain(_effectInContext);
	//CGContextRef effectOutContext = CGContextRetain(_effectOutContext);
	//vImage_Buffer effectInBuffer = _effectInBuffer;
	//vImage_Buffer effectOutBuffer = _effectOutBuffer;
	
	//self.hidden = YES;
	[self.layer renderInContext:effectInContext];
    //UIGraphicsPushContext(effectInContext);
    //BOOL updateSuccess = [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    //UIGraphicsPopContext();
    //[self.layer renderInContext:effectInContext];
    //EZDEBUG(@"update Success:%i", updateSuccess);
    //CGContextDrawImage(effectInContext, self.bounds, contentImage.CGImage);
    //self.hidden = NO;

	uint32_t blurKernel = [self calBlurKernel:blurRadius];
	
	vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	
	CGImageRef outImage = CGBitmapContextCreateImage(effectOutContext);
	//self.layer.contents = (__bridge id)(outImage);
    UIImage* res = [[UIImage alloc] initWithCGImage:outImage];
	CGImageRelease(outImage);
    
	CGContextRelease(effectInContext);
	CGContextRelease(effectOutContext);
    
    return res;
}


- (UIImage*) contentAsImage
{
    UIGraphicsBeginImageContext(self.frame.size);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //[self.layer renderInContext:context];
    [self drawViewHierarchyInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) afterScreenUpdates:YES];
    UIImage *res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return res;
}

//Added the Halo Effects
- (void) addHaloEffects
{
    self.layer.cornerRadius = 2.0;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(1.5,1.5);
    self.layer.shadowOpacity = 0.5;
    self.backgroundColor = [UIColor whiteColor];
}

- (void) shakeEffects
{
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = [ NSArray arrayWithObjects:
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ],
                   [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ],
                   nil ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 2.0f ;
    anim.duration = 0.07f ;
    
    [self.layer addAnimation:anim forKey:nil] ;
}

- (void) removeAllSubviews
{
    for(UIView* view in self.subviews){
        [view removeFromSuperview];
    }
}

- (void) setPosition:(CGPoint)pos
{
    [self setFrame:CGRectMake(pos.x, pos.y, self.frame.size.width, self.frame.size.height)];
}

- (void) setSize:(CGSize)size
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (CGFloat) getY
{
    return self.frame.origin.y;
}

- (CGFloat) getX
{
    return self.frame.origin.x;
}


- (void) setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);

}

- (void) setY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (void) moveY:(CGFloat)deltaY
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + deltaY, self.frame.size.width, self.frame.size.height);
}

- (void) moveX:(CGFloat)deltaX
{
    self.frame = CGRectMake(self.frame.origin.x + deltaX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);

}

- (void) addHeight:(CGFloat)delta
{
    [self setHeight:delta + self.frame.size.height];
}

- (void) addWidth:(CGFloat)delta
{
    [self setWidth:delta + self.frame.size.width];
}

- (void) setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void) setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}




///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
    return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (void) disableShadow
{
    self.layer.shadowOpacity = 0.0;
}

- (void) enableShadow:(UIColor *)color
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
    return self.frame.size.width;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
    return self.frame.size.height;
}



- (CGFloat) alignBottom
{
    if(self.superview == nil){
        return 0;
    }
    CGFloat totalHeight = self.superview.bounds.size.height;
    CGRect changed = self.frame;
    CGFloat selfHeight = changed.size.height;
    return totalHeight - (selfHeight + changed.origin.y);
}

- (void) setAlignBottom:(CGFloat)distance
{
    if(self.superview == nil){
        return;
    }
    CGFloat totalHeight = self.superview.bounds.size.height;
    CGRect changed = self.frame;
    CGFloat selfHeight = changed.size.height;
    changed.origin.y = totalHeight - selfHeight - distance;
    [self setFrame:changed];
}

- (UIView*) getCoverView:(NSInteger)tag
{
    return [self viewWithTag:tag];
}

//I can add gradient effects to wherever UIView I want.
//I really love this.
- (void) addGradient:(NSArray*)colors points:(NSArray*)points corner:(CGFloat)corner
{
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors = [self colorToCGColorRef:colors];
    layer.locations = points;
    if(corner > 0){
        layer.cornerRadius = corner;
    }
    layer.masksToBounds = YES;
    [self.layer addSublayer:layer];
    EZDEBUG(@"Added sublayer");
}
- (void) addGradient:(NSArray*)colors points:(NSArray*)points
{
    [self addGradient:colors points:points corner:0];
}

- (NSArray*) colorToCGColorRef:(NSArray*)colors
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:colors.count];
    for(UIColor* col in colors){
        [res addObject:(id)col.CGColor];
    }
    return res;
}

- (void) addBackGradient:(NSArray *)colors points:(NSArray *)points
{
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors = [self colorToCGColorRef:colors];
    layer.locations = points;
    [self.layer insertSublayer:layer atIndex:0];
    EZDEBUG(@"Added sublayer,total count:%i",self.layer.sublayers.count);
}

//Will keep the apect of current size and fit the most.
- (void) fitTo:(CGRect)frame
{
    CGSize curSize = self.bounds.size;
    
    CGFloat scaleX = frame.size.width/curSize.width;
    CGFloat scaleY = frame.size.height/curSize.height;
    
    CGFloat scale = scaleX > scaleY?scaleY:scaleX;
    EZDEBUG(@"Before transform:%@, scale:%f", NSStringFromCGRect(self.frame), scale);
    self.transform = CGAffineTransformMakeScale(scale,scale);
    EZDEBUG(@"after transform:%@, scale:%f", NSStringFromCGRect(self.frame), scale);
    //CGFloat startX = count * self.view.bounds.size.width;
    CGFloat posX = (frame.size.width - self.frame.size.width)/2;
    CGFloat posY = (frame.size.height - self.frame.size.height)/2;
    [self setPosition:CGPointMake(posX, posY)];
}

//I assume the fit To is correct, which is not the case?
//Let's try it.
- (void) fitToMode:(CGRect)frame
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.frame = frame;
}

- (void) addShadow:(UIColor*)color opacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
}


//I don't know what's the cost for the weak,
//Which may give me some trouble later, anyway, let's enjoy our life now.
//Put a question mark here,
//performance concern
- (EZEventBlock) createResetBlock
{
    CGRect currFrame = self.frame;
    __weak UIView* weakSelf = self;
    return ^(id sender){
        weakSelf.frame = currFrame;
    };
}
//What's the purpose of this method?
//Generate a gradients which repeat several times
//Why do we do this?
//To make the cell without data look more consistent.
- (void) addRepeatGradient:(NSArray *)colors points:(NSArray *)points repeatTimes:(NSInteger)repeats
{
    NSMutableArray* repColors = [[NSMutableArray alloc] initWithCapacity:colors.count*repeats];
    NSMutableArray* repPoints = [[NSMutableArray alloc] initWithCapacity:points.count*repeats];
    CGFloat previous = 0.0;
    for(int i = 1; i <= repeats; i++){
        [repColors addObjectsFromArray:colors];
        for(NSNumber* num in points){
            NSNumber* cur = num;
            if(cur.floatValue == 0.0){
                cur = [[NSNumber alloc] initWithFloat:previous];
                //EZDEBUG(@"Gradient start:%f, previous:%f",cur.floatValue, previous);
            }else{
                cur = [[NSNumber alloc] initWithFloat:cur.floatValue*i];
                //EZDEBUG(@"Gradient end:%f", cur.floatValue);
                previous = cur.floatValue;
                //EZDEBUG(@"After set previous:%f",previous);
            }
            [repPoints addObject:cur];
        }
    }
    [self addGradient:repColors points:repPoints];
}

- (UIView*) createCoverView:(NSInteger)tag
{
    UIView* coverView = [[UIView alloc] initWithFrame:self.frame];
    coverView.userInteractionEnabled = false;
    coverView.tag = tag;
    [self addSubview:coverView];
    return coverView;
}



@end

@implementation UIButton(EZPrivate)

- (void) addBlockWrapper:(EZBlockWrapper *)bw
{
    [self addTarget:bw action:@selector(invokeMethod:) forControlEvents:UIControlEventTouchUpInside];
}

//I can add gradient effects to wherever UIView I want.
//I really love this.
- (void) addGradient:(NSArray*)colors points:(NSArray*)points corner:(CGFloat)corner
{
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors = [self colorToCGColorRef:colors];
    layer.locations = points;
    if(corner > 0){
        layer.cornerRadius = corner;
    }
    layer.masksToBounds = YES;
    [self.layer addSublayer:layer];
    EZDEBUG(@"Added sublayer");
}
- (void) addGradient:(NSArray*)colors points:(NSArray*)points
{
    [self addGradient:colors points:points corner:0];
}

- (NSArray*) colorToCGColorRef:(NSArray*)colors
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:colors.count];
    for(UIColor* col in colors){
        [res addObject:(id)col.CGColor];
    }
    return res;
}

- (void) addBackGradient:(NSArray *)colors points:(NSArray *)points
{
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors = [self colorToCGColorRef:colors];
    layer.locations = points;
    [self.layer insertSublayer:layer atIndex:0];
    EZDEBUG(@"Added sublayer,total count:%i",self.layer.sublayers.count);
}

- (void) addRepeatGradient:(NSArray *)colors points:(NSArray *)points repeatTimes:(NSInteger)repeats
{
    NSMutableArray* repColors = [[NSMutableArray alloc] initWithCapacity:colors.count*repeats];
    NSMutableArray* repPoints = [[NSMutableArray alloc] initWithCapacity:points.count*repeats];
    CGFloat previous = 0.0;
    for(int i = 1; i <= repeats; i++){
        [repColors addObjectsFromArray:colors];
        for(NSNumber* num in points){
            NSNumber* cur = num;
            if(cur.floatValue == 0.0){
                cur = [[NSNumber alloc] initWithFloat:previous];
                //EZDEBUG(@"Gradient start:%f, previous:%f",cur.floatValue, previous);
            }else{
                cur = [[NSNumber alloc] initWithFloat:cur.floatValue*i];
                //EZDEBUG(@"Gradient end:%f", cur.floatValue);
                previous = cur.floatValue;
                //EZDEBUG(@"After set previous:%f",previous);
            }
            [repPoints addObject:cur];
        }
    }
    [self addGradient:repColors points:repPoints];
}


@end


@implementation UIColor(EZPrivate)

//Make my life easier.
+ (UIColor*) colorFromDecimal:(NSString*)hexStr
{
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 1;
    if(hexStr.length == 9){
        NSString* redStr = [hexStr substringWithRange:NSMakeRange(0,3)];
        red = redStr.intValue/255.0;
        
        NSString* greenStr = [hexStr substringWithRange:NSMakeRange(3,3)];
        green = greenStr.intValue/255.0;
        
        NSString* blueStr = [hexStr substringWithRange:NSMakeRange(6,3)];
        blue = blueStr.intValue/255.0;
    }else if(hexStr.length == 12){
        NSString* redStr = [hexStr substringWithRange:NSMakeRange(0,3)];
        red = redStr.intValue/255.0;
        
        NSString* greenStr = [hexStr substringWithRange:NSMakeRange(3,3)];
        green = greenStr.intValue/255.0;
        
        NSString* blueStr = [hexStr substringWithRange:NSMakeRange(6,3)];
        blue = blueStr.intValue/255.0;
        
        NSString* alphaStr = [hexStr substringWithRange:NSMakeRange(9,3)];
        alpha = alphaStr.intValue/255.0;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}



//We support 3Hex like CCC or ccc or 6Hex bcbcbc. etc
+ (UIColor*) colorFromHex:(NSString*)hexStr
{
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 1;
    if(hexStr.length == 3){
        NSString* redStr = [hexStr substringWithRange:NSMakeRange(0,1)];
        redStr = doubleString(redStr);
        red = redStr.hexToInt/255.0;
        
        NSString* greenStr = [hexStr substringWithRange:NSMakeRange(1,1)];
        greenStr = doubleString(greenStr);
        green = greenStr.hexToInt/255.0;
        
        NSString* blueStr = [hexStr substringWithRange:NSMakeRange(2,1)];
        blueStr = doubleString(blueStr);
        blue = blueStr.hexToInt/255.0;
        
    }else if(hexStr.length == 6){
        NSString* redStr = [hexStr substringWithRange:NSMakeRange(0,2)];
        red = redStr.hexToInt/255.0;
        
        NSString* greenStr = [hexStr substringWithRange:NSMakeRange(2,2)];
        green = greenStr.hexToInt/255.0;
        
        NSString* blueStr = [hexStr substringWithRange:NSMakeRange(4,2)];
        blue = blueStr.hexToInt/255.0;
        
    }else if(hexStr.length == 8){
        NSString* redStr = [hexStr substringWithRange:NSMakeRange(0,2)];
        red = redStr.hexToInt/255.0;
        
        NSString* greenStr = [hexStr substringWithRange:NSMakeRange(2,2)];
        green = greenStr.hexToInt/255.0;
        
        NSString* blueStr = [hexStr substringWithRange:NSMakeRange(4,2)];
        blue = blueStr.hexToInt/255.0;
        
        NSString* alphaStr = [hexStr substringWithRange:NSMakeRange(6,2)];
        alpha = alphaStr.hexToInt/255.0;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString*) toHexString
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    int redInt = red*255;
    int greenInt = green*255;
    int blueInt = blue*255;
    return [NSString stringWithFormat:@"%X%X%X", redInt, greenInt, blueInt]; 
}

@end


@implementation UIImage(EZPrivate)

- (NSData*) toData
{
    return UIImagePNGRepresentation(self);
}

- (NSData*) toJpegData
{
    return UIImageJPEGRepresentation(self, 0.7);
}

-(UIImage *) cutout: (CGRect) coords {
    UIGraphicsBeginImageContext(coords.size);
    [self drawAtPoint: CGPointMake(-coords.origin.x, -coords.origin.y)];
    UIImage *rslt = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rslt;
}

-(UIImage *) stretchImageWithCapInsets: (UIEdgeInsets) cornerCaps toSize: (CGSize) size {
    UIGraphicsBeginImageContext(size);
    
    [[self cutout: CGRectMake(0,0,cornerCaps.left,cornerCaps.top)] drawAtPoint: CGPointMake(0,0)]; //topleft
    [[self cutout: CGRectMake(self.size.width-cornerCaps.right,0,cornerCaps.right,cornerCaps.top)] drawAtPoint: CGPointMake(size.width-cornerCaps.right,0)]; //topright
    [[self cutout: CGRectMake(0,self.size.height-cornerCaps.bottom,cornerCaps.left,cornerCaps.bottom)] drawAtPoint: CGPointMake(0,size.height-cornerCaps.bottom)]; //bottomleft
    [[self cutout: CGRectMake(self.size.width-cornerCaps.right,self.size.height-cornerCaps.bottom,cornerCaps.right,cornerCaps.bottom)] drawAtPoint: CGPointMake(size.width-cornerCaps.right,size.height-cornerCaps.bottom)]; //bottomright
    
    [[self cutout: CGRectMake(cornerCaps.left,0,self.size.width-cornerCaps.left-cornerCaps.right,cornerCaps.top)]
     drawInRect: CGRectMake(cornerCaps.left,0,size.width-cornerCaps.left-cornerCaps.right,cornerCaps.top)]; //top
    
    [[self cutout: CGRectMake(0,cornerCaps.top,cornerCaps.left,self.size.height-cornerCaps.top-cornerCaps.bottom)]
     drawInRect: CGRectMake(0,cornerCaps.top,cornerCaps.left,size.height-cornerCaps.top-cornerCaps.bottom)]; //left
    
    [[self cutout: CGRectMake(cornerCaps.left,self.size.height-cornerCaps.bottom,self.size.width-cornerCaps.left-cornerCaps.right,cornerCaps.bottom)]
     drawInRect: CGRectMake(cornerCaps.left,size.height-cornerCaps.bottom,size.width-cornerCaps.left-cornerCaps.right,cornerCaps.bottom)]; //bottom
    
    [[self cutout: CGRectMake(self.size.width-cornerCaps.right,cornerCaps.top,cornerCaps.right,self.size.height-cornerCaps.top-cornerCaps.bottom)]
     drawInRect: CGRectMake(size.width-cornerCaps.right,cornerCaps.top,cornerCaps.right,size.height-cornerCaps.top-cornerCaps.bottom)]; //right
    
    [[self cutout: CGRectMake(cornerCaps.left,cornerCaps.top,self.size.width-cornerCaps.left-cornerCaps.right,self.size.height-cornerCaps.top-cornerCaps.bottom)]
     drawInRect: CGRectMake(cornerCaps.left,cornerCaps.top,size.width-cornerCaps.left-cornerCaps.right,size.height-cornerCaps.top-cornerCaps.bottom)]; //interior
    
    UIImage *rslt = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [rslt resizableImageWithCapInsets: cornerCaps];
}



- (UIImage*) resizableImage:(UIEdgeInsets)insects
{
    if([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    {
        return [self resizableImageWithCapInsets:insects resizingMode:UIImageResizingModeStretch];
    }else{
        return [self resizableImageWithCapInsets:insects];
    }
}

@end

@implementation UIApplication (EZPrivate)

- (void)addSubViewOnFrontWindow:(UIView *)view {
    int count = [self.windows count];
    EZDEBUG(@"Current count:%i", count);
    UIWindow *w = [self.windows objectAtIndex:count - 1];
    [w addSubview:view];
}

+ (void) addTopView:(UIView*)view
{
    UIApplication *app = [UIApplication sharedApplication];
    [app addSubViewOnFrontWindow:view];
}

@end


@implementation NSArray(EZPrivate)

- (NSArray*) filter:(FilterOperation)opts
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self iterate:^(id obj){
        if(opts(obj)){
            [res addObject:obj];
        }
    }];
    return res;
}

- (void) iterate:(IterateOperation) opts
{
    for(int i = 0; i < self.count; i++){
        opts([self objectAtIndex:i]);
    }
}

- (NSArray*) removeObject:(id)obj
{
    EZDEBUG(@"array before remove object:%i", self.count);
    if(self.count == 0){
        return nil;
    }
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(id innerObj in self){
        if(innerObj != obj){
            [res addObject:innerObj];
        }
    }
    EZDEBUG(@"array after remove object:%i, res:%i", self.count, res.count);
    return res;
}

- (NSArray*) insertObject:(id)obj
{
    if(self.count > 0){
        NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:self];
        [ma insertObject:obj atIndex:0];
        return  ma;
    }else{
        return @[obj];
    }
}

- (NSArray*) insertObjects:(id)objs
{
    if(self.count > 0){
        NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:self];
        //[ma insertObjects:objs atIndexes:[NSIndexSet indexSetWithIndex:0]];
        for(id oj in objs){
            [ma insertObject:oj atIndex:0];
        }
        return  ma;
    }else{
        return objs ;
    }
    
}

- (NSArray*) addObject:(id)obj
{
    if(self.count > 0){
        NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:self];
        [ma addObject:obj];
        return ma;
    }else{
        return @[obj];
    }
}


//I am worry about performance.
//Man, it is not a worry at this stage. 
- (NSArray*) removeHeader
{
    if(self.count > 1){
        NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:self];
        [ma removeObjectAtIndex:0];
        return ma;
    }else{
        return nil;
    }
}

- (NSArray*) reverse
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id obj in self){
        [res insertObject:obj atIndex:0];
    }
    return res;
}


- (NSArray*) mapcar:(MapCarOperation)opts
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id obj in self){
        id resObj = opts(obj);
        if(resObj){
            [res addObject:resObj];
        }
    }
    return res;
}

@end

@implementation NSNumber(EZPrivate)

+ (NSNumber*) initFloat:(CGFloat)ft
{
    return [[NSNumber alloc] initWithFloat:ft];
}

@end


@implementation NSDate(EZPrivate)


- (BOOL) isPassed:(NSDate*)date
{
    return [self timeIntervalSinceDate:date] <= 0;
}

- (BOOL) InBetween:(NSDate*)start end:(NSDate*)end
{
    NSTimeInterval selfInt = [self timeIntervalSince1970];
    return selfInt > [start timeIntervalSince1970] && selfInt < [end timeIntervalSince1970];
}

//Get the beginning of this date
- (NSDate*) beginning
{
    return [NSDate stringToDate:@"yyyyMMdd" dateString:[self stringWithFormat:@"yyyyMMdd"]];
}

- (NSString*) showStarString
{
    NSArray* starLists = @[@"白羊座",@"金牛座",@"双子座",
                           @"巨蟹座", @"狮子座", @"处女座", @"天秤座", @"天蝎座", @"射手座", @"魔羯座", @"水瓶座", @"双鱼座"];
    int ID = 0;
    NSInteger month = [self stringWithFormat:@"MM"].intValue;
    NSInteger day = [self stringWithFormat:@"dd"].intValue;
    
    switch (month) {
		case 1:
			if (day <= 20) {
				ID = 9;
			} else {
				ID = 10;
			}
			break;
		case 2:
			if (day <= 19) {
				ID = 10;
			} else {
				ID = 11;
			}
			break;
		case 3:
			if (day <= 20) {
				ID = 11;
			} else {
				ID = 0;
			}
			break;
		case 4:
			if (day <= 20) {
				ID = 0;
			} else {
				ID = 1;
			}
			break;
		case 5:
			if (day <= 21) {
				ID = 1;
			} else {
				ID = 2;
			}
			break;
		case 6:
			if (day <= 21) {
				ID = 2;
			} else {
				ID = 3;
			}
			break;
		case 7:
			if (day <= 22) {
				ID = 3;
			} else {
				ID = 4;
			}
			break;
		case 8:
			if (day <= 23) {
				ID = 4;
			} else {
				ID = 5;
			}
			break;
		case 9:
			if (day <= 23) {
				ID = 5;
			} else {
				ID = 6;
			}
			break;
		case 10:
			if (day <= 23) {
				ID = 6;
			} else {
				ID = 7;
			}
			break;
		case 11:
			if (day <= 22) {
				ID = 7;
			} else {
				ID = 8;
			}
			break;
		case 12:
			if (day <= 21) {
				ID = 8;
			} else {
				ID = 9;
			}
			break;
		default:
			break;
    }
    EZDEBUG(@"star of the date is:%@, month:%i, day:%i",[starLists objectAtIndex:ID], month, day);
    return [starLists objectAtIndex:ID];
    
}



//What's the puspose of this class?
//To show local time detail based on the timestamp.
- (NSString*) showTimeDetail
{
    if([self equalWith:[NSDate date] format:@"YYYYMMdd"]){
        return [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"Today", @"EZTimelineMain", nil),[self stringWithFormat:@"HH:mm"]];
    }else{
        return [self stringWithFormat:@"YYYY-MM-dd"];
        //return [self getLocalWeekName];
    }
}

- (NSString*) getLocalWeekName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

//Combine the date with the time. 
//I love this, relentlessly refractor.
//Since I only need minutes precision,
//So I will only combine minutes
- (NSDate*) combineTime:(NSDate*)time
{
    NSString* dateStr = [self stringWithFormat:@"yyyy-MM-dd"];
    NSString* timeStr = [time stringWithFormat:@"HH:mm"];
    NSString* combineStr = [NSString stringWithFormat:@"%@ %@",dateStr,timeStr];
    return [NSDate stringToDate:@"yyyy-MM-dd HH:mm" dateString:combineStr];
}

- (NSDate*) adjustMinutes:(int)minutes
{
    return [self adjust:minutes*60];
}

- (NSDate*) adjustDays:(int)days
{
    return [self adjust:60*24*days];
}

- (NSDate*) adjustYears:(int)years
{
    //return [self adjust:60*24*365*years];
    int curYears = [self stringWithFormat:@"yyyy"].integerValue;
    int resultYears = curYears + years;
    NSString* md = [self stringWithFormat:@"MM-dd"];
    NSString* finalStr = [NSString stringWithFormat:@"%i-%@", resultYears, md];
    return [NSDate stringToDate:@"yyyy-MM-dd" dateString:finalStr];
}

- (NSComparisonResult) compareTime:(NSDate*)date
{
    NSDate* combinedTime = [self combineTime:date];
    return [self compare:combinedTime];
}

- (NSDate*) adjust:(NSTimeInterval)delta
{
    NSTimeInterval seconds = [self timeIntervalSince1970];
    return [[NSDate alloc] initWithTimeIntervalSince1970:(seconds+delta)];
}


- (int) monthDay
{
    return [[self stringWithFormat:@"dd"] intValue];
}

- (int) getYear
{
    return [self getComponent:0];
}

- (int) getMonthDay
{
    return [self getComponent:2];
}

- (int) getMonth
{
    return [self getComponent:1];
}

- (int) getComponent:(int)types
{
  
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    if(types == 0){
        return  [components year];
    }
    if(types == 1){
        return [components month];
    }
   
    return [components day];
}

- (int) orgWeekDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    uint unitFlags = NSWeekdayCalendarUnit;
    NSDateComponents* dcomponent = [calendar components:unitFlags fromDate:self];
    return [dcomponent weekday];
}


- (BOOL) equalWith:(NSDate*)date format:(NSString*)format
{
    return [[self stringWithFormat:format] compare:[date stringWithFormat:format]] == NSOrderedSame;
}

+ (NSDate*) stringToDate:(NSString*)format dateString:(NSString*)dateStr
{
    if(!dateStr || [dateStr isKindOfClass:[NSNull class]]){
        EZDEBUG(@"date type: return nil");
        return nil;
    }
    //if(staticFormatter == nil){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    //}
    
    NSDate* res = [formatter dateFromString:dateStr];
    EZDEBUG(@"date type: result %@", res);
    return res;
}

- (NSString*) stringWithFormat:(NSString*)format
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df stringFromDate:self];
}

@end

@implementation EZTaskHelper

+ (int) getMonthLength:(NSDate*)date
{
    int month = [[date stringWithFormat:@"MM"] intValue];
    if(month == 2){
        NSString* year = [date stringWithFormat:@"yyyy"];
        NSDate* endFeb = [NSDate stringToDate:@"yyyyMMdd" dateString:[NSString stringWithFormat:@"%@0228",year]];
        NSDate* addedDay = [endFeb adjustDays:1];
        if([addedDay monthDay] == 29){
            return 29;
        }
        return 28;
        
    } else {
        if(month > 7){
            return (month % 2) == 1 ? 30:31; 
        }else{
            return (month % 2) == 1 ? 31:30;
        }
    }
}




+ (void) innerTaskLoop:(id)__unused object
{
    do{
        @autoreleasepool{
            [[NSRunLoop currentRunLoop] run];
        }
    }while(YES);
}

+ (NSThread*) getBackgroundThread
{
    static NSThread* res;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        res = [[NSThread alloc] initWithTarget:self selector:@selector(innerTaskLoop:) object:nil];
        [res start];
    });
    return res;
}

//This will be executed in the natural background.
//I am afraid, if long time task executed in this will block many things
//Relay on this background.
//Don't necessary.
//Change directly NSObject.
//+ (void) executeBlockInBackground:(EZOperationBlock)block
//{
//    BlockCarrier* bc = [[BlockCarrier alloc] initWithBlock:block];
//    [bc performSelectorInBackground:@selector(runBlock) withObject:nil];
//}

+ (void) executeBlockInBG:(EZOperationBlock)block
{
    BlockCarrier* bc = [[BlockCarrier alloc] initWithBlock:block];
    [bc performSelector:@selector(runBlock) onThread:[EZTaskHelper getBackgroundThread] withObject:nil waitUntilDone:NO];
}

+ (void) executeBlockInMain:(EZOperationBlock)block
{
    BlockCarrier* bc = [[BlockCarrier alloc] initWithBlock:block];
    [bc performSelectorOnMainThread:@selector(runBlock) withObject:nil waitUntilDone:NO];
}

        
BOOL isPrime(NSUInteger divider)
{
    if(divider == 2){
        return YES;
    }
    NSUInteger half = divider/2;
    for(int i = 2; i <= half; i++){
        if(divider % i){
            continue;
        }else{
            return NO;
        }
    }
    return YES;
}

NSUInteger findPrimeAfter(NSUInteger prime){
    if(prime == 0 || prime == 1){
        return 2;
    }
    NSUInteger odd = prime % 2;
    if(odd){
        prime += 2;
    }else{
        ++prime;
    }
    EZDEBUG(@"Will start at:%i", prime);
    for(NSUInteger i = prime; i < NSUIntegerMax; i += 2){
        if(isPrime(i)){
            return i;
        }
    }
    return 0;
}


@end
