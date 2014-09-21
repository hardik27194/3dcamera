//
//  EZGrabHandler.cpp
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#include "EZGrabHandler.h"

using namespace std;
/**
EZGrabHandler::EZGrabHandler(){
    cout << "create get called" << endl;
};
EZGrabHandler::~EZGrabHandler(){
    cout << "release object" << endl;
};
**/
const int BGD_KEY = cv::EVENT_FLAG_CTRLKEY;
const int FGD_KEY = cv::EVENT_FLAG_SHIFTKEY;

const cv::Scalar RED = cv::Scalar(0,0,255);
const cv::Scalar PINK = cv::Scalar(230,130,255);
const cv::Scalar BLUE = cv::Scalar(255,0,0);
const cv::Scalar LIGHTBLUE = cv::Scalar(255,255,160);
const cv::Scalar GREEN = cv::Scalar(0,255,0);

#define grabIterateCount 1

cv::Size EZEraseShape::getRadius()
{
    return cv::Size(frame.width/2,frame.height/2);
}
void EZEraseShape::setRadius(cv::Size radius)
{
    cv::Point center =cv::Point(frame.x + frame.width/2, frame.y + frame.height/2);
    frame = cv::Rect(center.x - radius.width, center.y - radius.height, 2 * radius.width, 2 * radius.height);
}

static void getBinMask( const Mat& comMask, Mat& binMask )
{
    if( comMask.empty() || comMask.type()!=CV_8UC1 )
        CV_Error( 12, "comMask is empty or has incorrect type (not CV_8UC1)" );
    if( binMask.empty() || binMask.rows!=comMask.rows || binMask.cols!=comMask.cols )
        binMask.create( comMask.size(), CV_8UC1 );
    binMask = comMask & 1;
}


void EZGrabHandler::reset()
{
    if( !mask.empty() )
        mask.setTo(Scalar::all(GC_BGD));
    bgdPxls.clear(); fgdPxls.clear();
    prBgdPxls.clear();  prFgdPxls.clear();
    
    isInitialized = false;
    rectState = NOT_SET;
    lblsState = NOT_SET;
    prLblsState = NOT_SET;
    iterCount = 0;
}

void EZGrabHandler::setImageOnly(const Mat& _image)
{
    image = new Mat(_image);
}

void EZGrabHandler::copyMat(cv::Mat& dst, cv::Mat& mask, bool isAlpha) const
{
    
    int count = 0;
    cout << "element Size:" << image->elemSize() << endl;
    for (int i = 0; i < image->rows; i++)
    {        for (int j = 0; j < image->cols; j++)
    {
        uchar alpha_value = mask.at<uchar>(i, j);
        
        if (alpha_value != 0)
        {
            Vec3b src3b = image->at<Vec3b>(i, j);
            
            if(++count < 10){
                cout << (int)alpha_value << ",0:" << src3b[0] << endl;
            }
            //float weight = float(alpha_value) / 255.f;
            dst.at<Vec4b>(i, j) = Vec4b(src3b[0],src3b[1],src3b[2],255);
        }
        else
        {
            dst.at<Vec4b>(i, j) = Vec4b(0, 0, 0, 0);
        }
    }
    }
}


void EZGrabHandler::copyByBinMask(cv::Mat& src, cv::Mat& dst, cv::Mat& mask, bool isAlpha) const
{
 
    int count = 0;
    cout << "element Size:" << src.elemSize() << endl;
    for (int i = 0; i < src.rows; i++)
    {        for (int j = 0; j < src.cols; j++)
            {
                uchar alpha_value = mask.at<uchar>(i, j);
                
                if (alpha_value != 0)
                {
                    Vec3b src3b = src.at<Vec3b>(i, j);

                    if(++count < 10){
                        cout << (int)alpha_value << ",0:" << src3b[0] << endl;
                    }
                    //float weight = float(alpha_value) / 255.f;
                    dst.at<Vec4b>(i, j) = Vec4b(src3b[0],src3b[1],src3b[2],255);
                }
                else
                {
                    dst.at<Vec4b>(i, j) = Vec4b(0, 0, 0, 0);
                }
            }
    }
}

void EZGrabHandler::mergeMask(const Mat& extMask)
{
    int count = 0;
    
    for (int i = 0; i < extMask.rows; i++)
    {
        for (int j = 0; j < extMask.cols; j++)
    {
        uchar alpha_value = extMask.at<uchar>(i, j);
        
        if (alpha_value != 0)
        {
            /**
            Vec3b src3b = image->at<Vec3b>(i, j);
            
            if(++count < 10){
                cout << (int)alpha_value << ",0:" << src3b[0] << endl;
            }
            //float weight = float(alpha_value) / 255.f;
            dst.at<Vec4b>(i, j) = Vec4b(src3b[0],src3b[1],src3b[2],255);
             **/
            mask.at<uchar>(i, j) = GC_PR_BGD;
            count ++;
        }
        else
        {
            //dst.at<Vec4b>(i, j) = Vec4b(0, 0, 0, 0);
        }
    }
    }
    cout << "mask element Size:" << extMask.elemSize() << ",mask row/col:" << extMask.rows << "/" << extMask.cols << ", count:" << count << endl;

}

void EZGrabHandler::setImage( const Mat& _image)
{
    cout << "before set image" << endl;
    if(image){
        delete image;
    }
    image = new Mat(_image);
    //_image.copyTo(image);
    
    mask.create(image->size(), CV_8UC1);
    cout << "after set image, mask:" << mask.rows << "," << mask.cols << ", image:" << image->rows << "," << image->cols << endl;
    reset();
}



void EZGrabHandler::showImage(int showSign, Mat& res) const
{
    //if( image->empty() || winName->empty() )
    //    return NULL;
    //cout << "show image called initialized:" << isInitialized << endl;
    //Mat res;
    res.create(image->size(), CV_8UC4);
    cout << "show image called initialized:" << isInitialized << "res element:" << res.elemSize() << " size:" << res.rows << "," << res.cols << endl;
    Mat binMask;
    if( !isInitialized )
        image->copyTo(res);
    else
    {
        getBinMask(mask, binMask);
        //image->copyTo(res, binMask );
        copyMat(res, binMask, true);
    }
    
    cout << "copyTo is over" << endl;
    if(showSign){
    vector<cv::Point>::const_iterator it;
    for( it = bgdPxls.begin(); it != bgdPxls.end(); ++it )
        circle( res, *it, radius, BLUE, thickness );
    for( it = fgdPxls.begin(); it != fgdPxls.end(); ++it )
        circle( res, *it, radius, RED, thickness );
    for( it = prBgdPxls.begin(); it != prBgdPxls.end(); ++it )
        circle( res, *it, radius, LIGHTBLUE, thickness );
    for( it = prFgdPxls.begin(); it != prFgdPxls.end(); ++it )
        circle( res, *it, radius, PINK, thickness );
    
    if( rectState == IN_PROCESS || rectState == SET )
        rectangle( res, cv::Point( rect.x, rect.y ), cv::Point(rect.x + rect.width, rect.y + rect.height ), GREEN, 2);
    }
    cout << "final res is done" << endl;
    //imshow( *winName, res );
    //return res;
}

void EZGrabHandler::setMaskRect(cv::Rect rt)
{
    rect = rt;
    //rect = cv::Rect(cv::Point(rt.x * image->rows, rt.y * image->cols), cv::Point(rt.width * image->rows, rt.height * image->cols));
    cout << "rect:" << rect.x <<"," << rect.y << "," << rect.width << "," << rect.height << endl;
    rectState = SET;
    setRectInMask();
}

void EZGrabHandler::setRectInMask()
{
    CV_Assert( !mask.empty() );
    mask.setTo( GC_BGD );
    rect.x = max(0, rect.x);
    rect.y = max(0, rect.y);
    rect.width = min(rect.width, image->cols-rect.x);
    rect.height = min(rect.height, image->rows-rect.y);
    (mask(rect)).setTo( Scalar(GC_PR_FGD) );
}

void EZGrabHandler::setMaskCycle(cv::Point p,int front, int radius, bool isPr)
{
    vector<cv::Point> *bpxls, *fpxls;
    uchar bvalue, fvalue;
    if( !isPr )
    {
        bpxls = &bgdPxls;
        fpxls = &fgdPxls;
        bvalue = GC_BGD;
        fvalue = GC_FGD;
    }
    else
    {
        bpxls = &prBgdPxls;
        fpxls = &prFgdPxls;
        bvalue = GC_PR_BGD;
        fvalue = GC_PR_FGD;
    }
    if(!front)
    {
        bpxls->push_back(p);
        circle( mask, p, radius, bvalue, thickness);
    }
    if(front)
    {
        fpxls->push_back(p);
        circle( mask, p, radius, fvalue, thickness);
    }
}

void EZGrabHandler::setLblsInMask(int isFront, cv::Point p, bool isPr )
{
    vector<cv::Point> *bpxls, *fpxls;
    uchar bvalue, fvalue;
    if( !isPr )
    {
        bpxls = &bgdPxls;
        fpxls = &fgdPxls;
        bvalue = GC_BGD;
        fvalue = GC_FGD;
    }
    else
    {
        bpxls = &prBgdPxls;
        fpxls = &prFgdPxls;
        bvalue = GC_PR_BGD;
        fvalue = GC_PR_FGD;
    }
    if(!isFront)
    {
        bpxls->push_back(p);
        circle( mask, p, radius, bvalue, thickness );
    }
    if(isFront)
    {
        fpxls->push_back(p);
        circle( mask, p, radius, fvalue, thickness );
    }
}

void EZGrabHandler::renderImageByMask(cv::Mat& image, cv::Mat& maskExt, cv::Mat& res)
{
    cv::Mat* dest = &image;
    bool deleteFlag = false;
    if(image.elemSize() == 4){
        dest = new cv::Mat();
        dest->create(image.size(), CV_8UC3);
        cvtColor(image, *dest, CV_BGRA2BGR);
        deleteFlag = true;
    }
    grabCut(*dest, maskExt, rect, bgdModel, fgdModel, grabIterateCount, GC_INIT_WITH_MASK);
    res.create(image.size(), CV_8UC4);
    cout << "show image called initialized:" << isInitialized << "res element:" << res.elemSize() << " size:" << res.rows << "," << res.cols << endl;
    Mat binMask;
    getBinMask(maskExt, binMask);
    //image->copyTo(res, binMask );
    copyByBinMask(*dest, res, binMask, true);
    if(deleteFlag){
        delete dest;
    }
}

int EZGrabHandler::renderByMask()
{
    iterCount++;
    grabCut( *image, mask, rect, bgdModel, fgdModel, grabIterateCount, GC_INIT_WITH_MASK);
    return iterCount;
}

void EZGrabHandler::setExternalMask(cv::Mat& extMask)
{
    extMask.copyTo(mask);
}

int EZGrabHandler::nextIter()
{
    if( isInitialized )
        grabCut( *image, mask, rect, bgdModel, fgdModel, grabIterateCount);
    else
    {
        if( rectState != SET )
            return iterCount;
        
        if( lblsState == SET || prLblsState == SET )
            grabCut( *image, mask, rect, bgdModel, fgdModel, grabIterateCount, GC_INIT_WITH_MASK );
        else
            grabCut( *image, mask, rect, bgdModel, fgdModel, grabIterateCount, GC_INIT_WITH_RECT );
        
        isInitialized = true;
    }
    iterCount++;
    
    bgdPxls.clear(); fgdPxls.clear();
    prBgdPxls.clear(); prFgdPxls.clear();
    
    return iterCount;
}
