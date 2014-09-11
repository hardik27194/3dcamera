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

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image type:(int)type;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;

@end
