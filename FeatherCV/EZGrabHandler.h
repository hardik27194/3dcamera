//
//  EZGrabHandler.h
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#ifndef ___DCamera__EZGrabHandler__
#define ___DCamera__EZGrabHandler__

#include <iostream>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;


typedef enum {
    kCycleShape,
    kRectShape
} EZShapeType;



struct EZEraseShape
{
public:
    //cv::Point point;
    cv::Rect frame;
    EZShapeType shapeType;

    cv::Size getRadius();
    void setRadius(cv::Size radius);
    
};



struct EZGrabHandler
{
public:
    EZGrabHandler(){
        std::cout << "GrabHandler init" << endl;
        //bgdModel = Mat(1, 65,CV_64F, cvScalar(0.));
        //fgdModel = Mat(1, 65,CV_64F, cvScalar(0.));
        
    };
    ~EZGrabHandler(){
        std::cout << "GrabHandler released" << endl;
        if(image){
            delete image;
            image = NULL;
        }
    };
    enum{ NOT_SET = 0, IN_PROCESS = 1, SET = 2 };
    static const int radius = 2;
    static const int thickness = 2;
    
    void reset();
    void setImage( const Mat& image);
    
    void mergeMask(const Mat& extMask);
    
    void setImageOnly(const Mat& image);
    void showImage(int showSign, Mat& res) const;
    void mouseClick( int event, int x, int y, int flags, void* param );
    int nextIter();
    int getIterCount() const { return iterCount; };
    
    void setMaskRect(cv::Rect rect);
    
    void setMaskCycle(cv::Point p,int front, int radius, bool isPr);

    void setLblsInMask(int isFront, cv::Point p, bool isPr );
    
    int renderByMask();
    void copyMat(cv::Mat& dest, cv::Mat& mask, bool alpha) const;
private:
    void setRectInMask();
    const string* winName;
    const Mat* image;
    Mat mask;
    Mat bgdModel;//(1,1, CV_64F, Scalar(0.));
    
    Mat fgdModel;//(1,1, CV_64F, Scalar(0.));
    
    uchar rectState, lblsState, prLblsState;
    bool isInitialized;
    
    cv::Rect rect;
    vector<cv::Point> fgdPxls, bgdPxls, prFgdPxls, prBgdPxls;
    int iterCount;

    
};

#endif /* defined(___DCamera__EZGrabHandler__) */
