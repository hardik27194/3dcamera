//
//  EZFaceUtil.cpp
//  FeatherCV
//
//  Created by xietian on 13-11-22.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#include "EZFaceUtil.h"



EZFaceUtil::EZFaceUtil()
{
    clahe = cv::createCLAHE();
    NSString* cascadeFile = @"haarcascade_frontalface_default";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:cascadeFile
                                                        ofType:@"xml"];
    if(!faceCascader.load([filePath cStringUsingEncoding:NSUTF8StringEncoding])){
        NSLog(@"Fail to load %@", filePath);
    }else{
        NSLog(@"Loaded %@", filePath);
    }

}

void EZFaceUtil::getGray(cv::Mat &inputFrame, cv::Mat &outputFrame){
 
    const int numChannes = inputFrame.elemSize();
    NSLog(@"Element size:%i, channel size:%zu", numChannes, inputFrame.elemSize());
        
    if (numChannes == 4)
    {
//#if TARGET_IPHONE_SIMULATOR
        cv::cvtColor(inputFrame, outputFrame, CV_BGRA2GRAY);
//#else
//        cv::neon_cvtColorBGRA2GRAY(inputFrame, outputFrame);
//#endif
            
    }
    else if (numChannes == 3)
    {
        cv::cvtColor(inputFrame, outputFrame, CV_BGR2GRAY);
    }
    else if (numChannes == 1)
    {
        outputFrame = inputFrame;
    }
    
}

void EZFaceUtil::drawRegion(cv::Mat& inputFrame, cv::Rect& region)
{
    cv::rectangle(inputFrame, region, CV_RGB(255,255,255), 3, 8, 0 );
}


void EZFaceUtil::resize(cv::Mat& inputFrame, cv::Mat& outputFrame, cv::Size& finalSize)
{
    cv::resize( inputFrame, outputFrame, finalSize, 0, 0, cv::INTER_LINEAR );
}


void EZFaceUtil::detectFace(cv::Mat& inputFrame, std::vector<EZFaceResult*>& faces, cv::Size cropSize)
{
    if(cropSize.width == 0){
        cropSize = cv::Size(40, 40);
    }
    cv::Mat singleChannel(inputFrame.rows, inputFrame.cols, CV_8UC1);
    getGray(inputFrame, singleChannel);
    
    //clahe->apply(singleChannel, singleChannel);
    
    equalizeHist(singleChannel, singleChannel);

    //-- Detect faces
    std::vector<cv::Rect> faceRects;
    
    
    faceCascader.detectMultiScale( singleChannel, faceRects, 1.1, 3, CV_HAAR_SCALE_IMAGE|0, cv::Size(40, 40), cv::Size(singleChannel.rows, singleChannel.cols));
    
    NSLog(@"detected face:%lu, frame rows:%d, cols:%d", faceRects.size(), singleChannel.rows, singleChannel.cols);
    //cv::resize(src, dst, Size(1024, 768), 0, 0, INTER_CUBIC)
    
    for( int i = 0; i < faceRects.size(); i++ )
    {
        NSLog(@"face:%i, x:%d, y:%d, width:%d, height:%d", i, faceRects[i].x, faceRects[i].y, faceRects[i].width, faceRects[i].height);
        //cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
        //cv::Rect adjusted(faces[i]);
        //adjusted.height = adjusted.height*1.15;
        
        //ellipse( singleChannel, center, cv::Size( faces[i].width*0.5, adjusted.height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
        //cv::Mat
        //Maybe some of the assumption is wrong.
        cv::Mat faceReg(inputFrame, faceRects[i]);
        cv::Mat* retMat = new cv::Mat(cropSize.width, cropSize.height, CV_8UC1);
        cv::resize(faceReg, *retMat, cropSize);
        EZFaceResult* fres = new EZFaceResult();
        fres->orgRect = faceRects[i];
        fres->destRect = cv::Rect(0, 0, cropSize.width, cropSize.height);
        fres->face = retMat;
        faces.push_back(fres);
    }
}