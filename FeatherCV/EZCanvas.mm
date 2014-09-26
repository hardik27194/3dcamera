//
//  EZOpencvObj.m
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCanvas.h"
#import "EZImageConverter.h"
#import "EZImageObject.h"

@implementation EZCanvas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _shapes = [[NSMutableArray alloc] init];
        _redoList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addShapeObject:(EZDrawable*)shape
{
    [shape setParent:self];
    [_shapes addObject:shape];
}

- (EZDrawable*) getLastDrawable
{
    if(_shapes.count){
        return [_shapes objectAtIndex:_shapes.count - 1];
    }
    return nil;
}

- (void) insertShape:(EZDrawable*)shape pos:(NSInteger)pos
{
    [shape setParent:self];
    [_shapes insertObject:shape atIndex:pos];
    
}

- (void) removeShape:(EZDrawable*)drawable
{
    [_shapes removeObject:drawable];
}

- (void) drawImage:(UIImage*)image
{
    EZImageObject* im = [EZImageObject createImage:image frame:CGRectMake(0, 0, self.width, self.height)];
    [self addShapeObject:im];
    [self setNeedsDisplay];
}

- (void) undoAll
{
    for(int i = _shapes.count - 1; i >= 0; i --){
        EZDrawable* drawAble = [_shapes objectAtIndex:i];
        [_shapes removeObjectAtIndex:i];
        [_redoList addObject:drawAble];
    }
    [self setNeedsDisplay];
}

- (void) undo
{
    if(_shapes.count){
        EZDrawable* drawAble = [_shapes objectAtIndex:_shapes.count - 1];
        [_shapes removeObjectAtIndex:_shapes.count - 1];
        [_redoList addObject:drawAble];
        [self setNeedsDisplay];
    }
}

- (void) redo
{
    if(_redoList.count){
        EZDrawable* drawAble = [_redoList objectAtIndex:_redoList.count - 1];
        [_shapes addObject:drawAble];
        [_redoList removeObjectAtIndex:_redoList.count - 1];
        [self setNeedsDisplay];
    }
}

- (EZDrawable*) getShapeAtPoint:(CGPoint)pt
{
    
    for(int i = _shapes.count-2; i >= 0; i --){
        EZDrawable* shape = [_shapes objectAtIndex:i];
        EZDEBUG(@"rect:%@, point:%@", NSStringFromCGRect(shape.boundingRect), NSStringFromCGPoint(pt));
        if(CGRectContainsPoint(shape.boundingRect, pt)){
            EZDEBUG(@"find rect");
            return shape;
        }
    }
    return nil;
}

- (UIImage*) generateImage
{
    return [self contentAsImage];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self renderTo:context];
}

- (void) renderTo:(CGContextRef)context
{
    //EZDEBUG(@"Before fill");
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    //EZDEBUG(@"before clear");
    CGContextFillRect(context, CGRectMake(0, 0, self.width, self.height));
    //EZDEBUG(@"before full render");
    
    for(EZDrawable* drawable in _shapes){
        [drawable drawContext:context];
    }
    //EZDEBUG(@"Render completed");
}


//I have some issue to mapping directly from the data to a matrix.
- (void) renderToMat:(cv::Mat&)outMat orgMat:(cv::Mat&)cvMat;
 {
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 //CGFloat cols = image.size.width;
 //CGFloat rows = image.size.height;
 CGFloat scale = [UIScreen mainScreen].scale;
 scale = 2.0;
 cvMat.create( self.height*scale, self.width*scale, CV_8UC4);
 outMat.create(self.height*scale, self.width*scale, CV_8UC1);
 //EZDEBUG(@"Update Before create, color space:%i", (int)colorSpace);
 CGContextRef contextRef = CGBitmapContextCreate( NULL, self.width*scale, self.height*scale, 8, self.width * scale * 4, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault );
 EZDEBUG(@"before draw");
 //CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
 [self renderTo:contextRef];
 CGContextFlush(contextRef);
 UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
 CGContextRelease( contextRef );
 CGColorSpaceRelease( colorSpace );
 //cv::Mat outMat(rows, cols, CV_8UC1);
 //cv::cvtColor(cvMat, outMat, CV_BGRA2BGR);
     int frontCount = 0;
     int backCount = 0;
     int probBack = 0;
     int probFront = 0;
 for(int i = 0; i < cvMat.rows; i ++){
 for(int j = 0; j < cvMat.cols; j ++){
 cv::Vec4b fullColor = cvMat.at<cv::Vec4b>(i, j);
 if(EqualMatColor(fullColor, BackSureColorCV)){
 //fullMat.at<cv::Vec3b>(i, j) = BackSureColorCV;
     backCount ++;
     outMat.at<uchar>(i, j) = cv::GC_BGD;
 }else if(EqualMatColor(fullColor, BackProbableColorCV)){
     probBack ++;
     outMat.at<uchar>(i, j) = cv::GC_PR_BGD;
 }else if(EqualMatColor(fullColor, FrontSureColorCV)){
     frontCount ++;
     EZDEBUG(@"the front end");
     outMat.at<uchar>(i, j) = cv::GC_FGD;
 }else if(EqualMatColor(fullColor, FrontProbableColorCV)){
     probFront ++;
     outMat.at<uchar>(i, j) = cv::GC_PR_FGD;
 }else{
     probBack ++;
     outMat.at<uchar>(i, j) = cv::GC_PR_BGD;
 }
 }
 }
     EZDEBUG(@"final outMat:%i, %i, frontCount:%i, backCount:%i, probFront:%i, probBack:%i", outMat.cols, outMat.rows, frontCount, backCount, probFront, probBack);
 
 }



@end
