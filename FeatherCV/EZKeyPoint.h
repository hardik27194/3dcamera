//
//  EZKeyPoint.h
//  3DCamera
//
//  Created by xietian on 14-9-26.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#ifndef ___DCamera__EZKeyPoint__
#define ___DCamera__EZKeyPoint__

#include <opencv2/opencv.hpp>

/**
 * Store the image data and computed descriptors of target pattern
 */
struct EZKeyPoint
{
    //cv::Point2f              position;
    cv::KeyPoint srcPoint;
    cv::KeyPoint destPoint;
    //cv::Mat                   descriptors;
    float distance;
    //cv::Point2f adjustedOrg;
    //cv::Point2f adjustedDest;
};

#endif /* defined(___DCamera__EZKeyPoint__) */
