//
//  EZImageConverter.h
//  OpenCVTinkering
//
//  Created by xietian on 13-11-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>


@interface EZImageConverter : NSObject {
    
}

+ (UIImage *)matToImageEx:(cv::Mat)image;
+ (UIImage *)matToImage:(cv::Mat)cvMat;
+ (UIImage *)matToImage2:(cv::Mat)cvMat withUIImage:(UIImage*)image;

+ (void) cvMatFromUIImage:(UIImage *)image outMat:(cv::Mat&)cvMat;
+ (void) cvMatFromUIImage:(UIImage *)image outMat:(cv::Mat&)cvMat type:(int)type;
+ (void) cvMatGrayFromUIImage:(UIImage *)image outMat:(cv::Mat&)cvMat;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;

+ (void) flagToMask:(cv::Mat&)mat mask:(cv::Mat&)outMat;
+ (void) maskToFlag:(cv::Mat&)cvMat flag:(cv::Mat&)outMat;

+ (void) imageMaskToMat:(cv::Mat&)mat image:(UIImage*)image;

+ (UIImage*) matMaskToImage:(cv::Mat&)mat;

- (void) imageAny:(cv::Mat&)mat image:(UIImage*)image;


@end
