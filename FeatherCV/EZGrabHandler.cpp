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
const int BGD_KEY = EVENT_FLAG_CTRLKEY;
const int FGD_KEY = EVENT_FLAG_SHIFTKEY;

const Scalar RED = Scalar(0,0,255);
const Scalar PINK = Scalar(230,130,255);
const Scalar BLUE = Scalar(255,0,0);
const Scalar LIGHTBLUE = Scalar(255,255,160);
const Scalar GREEN = Scalar(0,255,0);

#define grabIterateCount 1

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

void EZGrabHandler::setImage( const Mat& _image)
{
    cout << "before set image" << endl;
    image = new Mat(_image);
    //_image.copyTo(image);
    
    mask.create(image->size(), CV_8UC1);
    cout << "after set image, mask:" << mask.rows << "," << mask.cols << ", image:" << image->rows << "," << image->cols << endl;
    reset();
}



Mat EZGrabHandler::showImage(int showSign) const
{
    //if( image->empty() || winName->empty() )
    //    return NULL;
    cout << "show image called initialized:" << isInitialized << endl;
    Mat res;
    Mat binMask;
    if( !isInitialized )
        image->copyTo( res );
    else
    {
        getBinMask( mask, binMask );
        image->copyTo( res, binMask );
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
    return res;
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

void EZGrabHandler::mouseClick( int event, int x, int y, int flags, void* )
{
    // TODO add bad args check
    switch( event )
    {
        case EVENT_LBUTTONDOWN: // set rect or GC_BGD(GC_FGD) labels
        {
            bool isb = (flags & BGD_KEY) != 0,
            isf = (flags & FGD_KEY) != 0;
            if( rectState == NOT_SET && !isb && !isf )
            {
                rectState = IN_PROCESS;
                rect = cv::Rect( x, y, 1, 1 );
            }
            if ( (isb || isf) && rectState == SET )
                lblsState = IN_PROCESS;
        }
            break;
        case EVENT_RBUTTONDOWN: // set GC_PR_BGD(GC_PR_FGD) labels
        {
            bool isb = (flags & BGD_KEY) != 0,
            isf = (flags & FGD_KEY) != 0;
            if ( (isb || isf) && rectState == SET )
                prLblsState = IN_PROCESS;
        }
            break;
        case EVENT_LBUTTONUP:
            if( rectState == IN_PROCESS )
            {
                rect = cv::Rect( cv::Point(rect.x, rect.y), cv::Point(x,y) );
                rectState = SET;
                setRectInMask();
                CV_Assert( bgdPxls.empty() && fgdPxls.empty() && prBgdPxls.empty() && prFgdPxls.empty() );
                //showImage();
            }
            if( lblsState == IN_PROCESS )
            {
                setLblsInMask(flags, cv::Point(x,y), false);
                lblsState = SET;
                //showImage();
            }
            break;
        case EVENT_RBUTTONUP:
            if( prLblsState == IN_PROCESS )
            {
                setLblsInMask(flags, cv::Point(x,y), true);
                prLblsState = SET;
                //showImage();
            }
            break;
        case EVENT_MOUSEMOVE:
            if( rectState == IN_PROCESS )
            {
                rect = cv::Rect( cv::Point(rect.x, rect.y), cv::Point(x,y) );
                CV_Assert( bgdPxls.empty() && fgdPxls.empty() && prBgdPxls.empty() && prFgdPxls.empty() );
                //showImage();
            }
            else if( lblsState == IN_PROCESS )
            {
                setLblsInMask(flags, cv::Point(x,y), false);
               // showImage();
            }
            else if( prLblsState == IN_PROCESS )
            {
                setLblsInMask(flags, cv::Point(x,y), true);
                //showImage();
            }
            break;
    }
}


int EZGrabHandler::renderByMask()
{
    iterCount++;
    grabCut( *image, mask, rect, bgdModel, fgdModel, grabIterateCount, GC_INIT_WITH_MASK);
    return iterCount;
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
