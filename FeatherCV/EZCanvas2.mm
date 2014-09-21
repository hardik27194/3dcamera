//
//  EZCanvas2.m
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCanvas2.h"

@implementation EZCanvas1

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
    //[shape setParent:self];
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
    //[shape setParent:self];
    [_shapes insertObject:shape atIndex:pos];
    
}

- (void) removeShape:(EZDrawable*)drawable
{
    [_shapes removeObject:drawable];
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
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.width, self.height));
    for(EZDrawable* drawable in _shapes){
        [drawable drawContext:context];
    }
}



 - (void) renderToMat:(cv::Mat&)outMat
 {
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 //CGFloat cols = image.size.width;
 //CGFloat rows = image.size.height;
 cv::Mat cvMat( self.height, self.width, CV_8UC4);
 EZDEBUG(@"Before create, color space:%i", (int)colorSpace);
 CGContextRef contextRef = CGBitmapContextCreate( cvMat.data, cvMat.cols, cvMat.rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaLast | kCGBitmapByteOrderDefault );
 //EZDEBUG(@"before draw");
 //CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
 [self renderTo:contextRef];
 CGContextRelease( contextRef );
 CGColorSpaceRelease( colorSpace );
 //cv::Mat outMat(rows, cols, CV_8UC1);
 //cv::cvtColor(cvMat, outMat, CV_BGRA2BGR);
 for(int i = 0; i < cvMat.rows; i ++){
 for(int j = 0; j < cvMat.cols; j ++){
     cv::Vec4b fullColor = cvMat.at<cv::Vec4b>(i, j);
     if(EqualMatColor(fullColor, BackSureColorCV)){
         //fullMat.at<cv::Vec3b>(i, j) = BackSureColorCV;
         outMat.at<uchar>(i, j) = cv::GC_BGD;
     }else if(EqualMatColor(fullColor, BackProbableColorCV)){
         outMat.at<uchar>(i, j) = cv::GC_PR_BGD;
     }else if(EqualMatColor(fullColor, FrontSureColorCV)){
         outMat.at<uchar>(i, j) = cv::GC_FGD;
     }else if(EqualMatColor(fullColor, FrontProbableColorCV)){
         outMat.at<uchar>(i, j) = cv::GC_PR_FGD;
     }
 }
 }
 
 }


@end
