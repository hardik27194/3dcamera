//
//  EZImageConverter.h
//  OpenCVTinkering
//
//  Created by xietian on 13-11-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

#define FrontProbableColor RGBACOLOR(255, 128, 128, 128)

#define FrontProbableColorCV cv::Vec4b(255, 128, 128, 128)

#define FrontSureColor RGBACOLOR(255, 255, 255, 0)
#define FrontSureColorCV cv::Vec4b(255, 255, 255, 0)


#define BackSureColor RGBACOLOR(255, 255, 255, 170)
#define BackSureColorCV cv::Vec4b(255, 255, 255, 170)

#define BackProbableColor RGBACOLOR(255, 255, 255, 80)
#define BackProbableColorCV cv::Vec4b(255, 255, 255, 80)

#define EqualMatColor(cl, cr)  (cl[0] == cr[0] && cl[1] == cr[1] && cl[2] == cr[2] && cl[3] == cr[3])



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


+ (void) imageMaskToMat:(cv::Mat&)mat image:(UIImage*)image;

+ (UIImage*) matMaskToImage:(cv::Mat&)mat;


@end
