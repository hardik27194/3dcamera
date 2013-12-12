//
//  EZFaceUtil.h
//  FeatherCV
//
//  Created by xietian on 13-11-22.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#ifndef __FeatherCV__EZFaceUtil__
#define __FeatherCV__EZFaceUtil__

#include <iostream>
#include <vector>
#include "EZFaceResult.h"
#include <AVFoundation/AVFoundation.h>
//What's the pupose of this class?
//I will have method to get a face list out and resize the face to the specified size
//Why do I define this?
//I would like to have a resource holder, so that I have all the resource hold at one place
//This is great.
template <class X>
X& singleton()
{
    static X x;
    return x;
}

class EZFaceUtil
{
public:
    EZFaceUtil();
    cv::Ptr<cv::CLAHE> clahe;
    cv::CascadeClassifier faceCascader;
    cv::CascadeClassifier smileCascader;
    CIDetector *_faceDetector;
    CIContext *_ciContext;
    //So each
    virtual void detectFace(cv::Mat& inputFrame, std::vector<EZFaceResult*>& faces,bool hasSimle = false, cv::Size cropSize = cv::Size());
    
    //Draw a retangle which could show where is the face
    void drawRegion(cv::Mat& inputFrame, cv::Rect& region);
    
    int convertOrientation(UIImageOrientation orientation);
    
    void containsSmiles(UIImage* image,EZEventBlock callback);
    //Will filter the detected face according to the conditon
    void filterFaces(cv::Mat& inputFrame, std::vector<EZFaceResult*>& inputFaces, std::vector<EZFaceResult*>& outputFaces);
    
    void detectSmile(cv::Mat& inputFrame, EZFaceResult* faceResult);
    //What's the purpose of this method, is to get mat gray out
    static void getGray(cv::Mat& inputFrame, cv::Mat& outputFrame);

    //I will try to get
    void detectSmile(EZFaceResult* faceResult);
};



//std::vector<cv::Mat>&



#endif /* defined(__FeatherCV__EZFaceUtil__) */
