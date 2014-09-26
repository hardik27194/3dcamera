//
//  EZOpencvObj.h
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "EZDrawable.h"

//@class EZDrawable;
@interface EZCanvas : UIView

@property (nonatomic, strong) NSMutableArray* shapes;
@property (nonatomic, strong) NSMutableArray* redoList;

- (void) addShapeObject:(EZDrawable*)shape;

- (EZDrawable*) getLastDrawable;

- (UIImage*) generateImage;

- (EZDrawable*) getShapeAtPoint:(CGPoint)pt;

- (void) drawImage:(UIImage*)image;

- (void) removeShape:(EZDrawable*)drawable;

- (void) insertShape:(EZDrawable*)shape pos:(NSInteger)pos;

- (void) renderToMat:(cv::Mat&)outMat orgMat:(cv::Mat&)orgMat;

- (void) undoAll;

- (void) undo;

- (void) redo;

@end
