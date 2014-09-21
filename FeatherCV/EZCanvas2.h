//
//  EZCanvas2.h
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import "EZDrawable.h"

@interface EZCanvas1 : UIView

@property (nonatomic, strong) NSMutableArray* shapes;
@property (nonatomic, strong) NSMutableArray* redoList;

- (void) addShapeObject:(EZDrawable*)shape;

- (EZDrawable*) getLastDrawable;

- (UIImage*) generateImage;

- (EZDrawable*) getShapeAtPoint:(CGPoint)pt;

- (void) removeShape:(EZDrawable*)drawable;

- (void) insertShape:(EZDrawable*)shape pos:(NSInteger)pos;

- (void) renderToMat:(cv::Mat&)outMat;

- (void) undo;

- (void) redo;


@end
