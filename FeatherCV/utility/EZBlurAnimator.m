//
//  EZBlurAnimator.m
//  FeatherCV
//
//  Created by xietian on 14-3-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZBlurAnimator.h"
#import "EZAnimationUtil.h"


@implementation EZBlurAnimator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) setup {
	self.clipsToBounds = YES;
	self.blurRadius = 4.0f;
	self.scaleFactor = 1.0f;
	self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.25f];
	self.opaque = NO;
	self.userInteractionEnabled = NO;
	self.layer.actions = @{
                           @"contents": [NSNull null]
                           };
	//_shouldLiveBlur = YES;
	//_frameInterval = 1;
	//_currentFrameInterval = 0;
}

- (void) animateBlur:(CGFloat)from to:(CGFloat)toBlur duration:(CGFloat)duration srcView:(UIView*)srcView completed:(EZEventBlock)completed
{
    
    //[container addSubview:self];
    if(!_bufferCreated){
        _bufferCreated = true;
        [self recreateImageBuffers];
    }
    EZDEBUG(@"Will animate the blur level from:%f, to:%f", from, toBlur);
    _srcView = srcView;
    _startBlurRadius = from;
    _endBlurRadius = toBlur;
    _currentFrameCount = 0;
    _totalFrameCount = duration / 0.165f;
    _completed = completed;
    [[EZAnimationUtil sharedEZAnimationUtil] addAnimation:^(){
        return [self refresh];
    }];
    //[self refresh];
    
}


- (void) recreateImageBuffers {
    //EZDEBUG(@"recreateImageBuffer frame:%@, bound:%@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
	CGRect visibleRect = self.frame;
	CGSize bufferSize = CGSizeMake(self.bounds.size.width * _scaleFactor, self.bounds.size.height * _scaleFactor);
	if (bufferSize.width == 0 || bufferSize.height == 0) {
		return;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef effectInContext = CGBitmapContextCreate(NULL, bufferSize.width, bufferSize.height, 8, bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //EZDEBUG(@"Create first context");
	
	CGContextRef effectOutContext = CGBitmapContextCreate(NULL, bufferSize.width, bufferSize.height, 8, bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(colorSpace);
	
	CGContextConcatCTM(effectInContext, (CGAffineTransform){
		1, 0, 0, -1, 0, bufferSize.height
	});
	CGContextScaleCTM(effectInContext, _scaleFactor, _scaleFactor);
	CGContextTranslateCTM(effectInContext, -visibleRect.origin.x, -visibleRect.origin.y);
	
	if (_effectInContext) {
		CGContextRelease(_effectInContext);
	}
	_effectInContext = effectInContext;
	
	if (_effectOutContext) {
		CGContextRelease(_effectOutContext);
	}
	_effectOutContext = effectOutContext;
	
	_effectInBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(effectInContext),
		.width = CGBitmapContextGetWidth(effectInContext),
		.height = CGBitmapContextGetHeight(effectInContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext)
	};
	
	_effectOutBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(effectOutContext),
		.width = CGBitmapContextGetWidth(effectOutContext),
		.height = CGBitmapContextGetHeight(effectOutContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext)
	};
}


- (uint32_t) calBlurKernel:(CGFloat)blurRadius
{
	uint32_t radius = (uint32_t)floor(blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
	radius += (radius + 1) % 2;
	return radius;
}

- (int) refresh {
    _currentFrameCount ++;
    CGFloat blurRatio = _currentFrameCount/_totalFrameCount;
    if(blurRatio > 1.0){
        [[EZAnimationUtil sharedEZAnimationUtil] removeAnimation:_animBlock];
        if(_completed){
            _completed(self);
        }
        return TRUE;
    }
    
	CGFloat finalBlurRadius = _startBlurRadius + (_endBlurRadius - _startBlurRadius) * blurRatio;
    EZDEBUG(@"finalBlurRadius:%f", finalBlurRadius);
    
	CGContextRef effectInContext = CGContextRetain(_effectInContext);
	CGContextRef effectOutContext = CGContextRetain(_effectOutContext);
	vImage_Buffer effectInBuffer = _effectInBuffer;
	vImage_Buffer effectOutBuffer = _effectOutBuffer;
	
	//self.hidden = YES;
	//[superview.layer renderInContext:effectInContext];
	//self.hidden = NO;
    [_srcView.layer renderInContext:effectInContext];
	
	uint32_t blurKernel = [self calBlurKernel:finalBlurRadius];
	
	vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
	
    if (_tintColor) {
        CGContextSaveGState(effectOutContext);
        CGContextSetFillColorWithColor(effectOutContext, _tintColor.CGColor);
        CGContextFillRect(effectOutContext, self.bounds);
        CGContextRestoreGState(effectOutContext);
    }
    
	CGImageRef outImage = CGBitmapContextCreateImage(effectOutContext);
	self.layer.contents = (__bridge id)(outImage);
	CGImageRelease(outImage);
    
	CGContextRelease(effectInContext);
	CGContextRelease(effectOutContext);
    
    return false;
}


- (void) dealloc
{
    if (_effectInContext) {
		CGContextRelease(_effectInContext);
	}
	if (_effectOutContext) {
		CGContextRelease(_effectOutContext);
	}
	[[EZAnimationUtil sharedEZAnimationUtil] removeAnimation:_animBlock];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
