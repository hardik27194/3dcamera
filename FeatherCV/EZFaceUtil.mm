//
//  EZFaceUtil.cpp
//  FeatherCV
//
//  Created by xietian on 13-11-22.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#include "EZFaceUtil.h"
#include "UIImage2OpenCV.h"
#include "EZFaceResultObj.h"


EZFaceUtil::EZFaceUtil()
{
    clahe = cv::createCLAHE();
    NSString* cascadeFile = @"haarcascade_frontalface_default";
    NSString* smileFile = @"haarcascade_smile";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:cascadeFile
                                                        ofType:@"xml"];
    NSString* smilePath = [[NSBundle mainBundle] pathForResource:smileFile
                                                          ofType:@"xml"];
    if(!faceCascader.load([filePath cStringUsingEncoding:NSUTF8StringEncoding])){
        NSLog(@"Fail to load %@", filePath);
    }
    
    if(!smileCascader.load([smilePath cStringUsingEncoding:NSUTF8StringEncoding])){
        NSLog(@"Failed to load %@", smilePath);
    }
    
    _ciContext = [CIContext contextWithOptions:nil];
    
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_ciContext options:nil];

}


int EZFaceUtil::convertOrientation(UIImageOrientation orientation){
    int exifOrientation;
    switch (orientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
        default:
            break;
    }
    return exifOrientation;
}
//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
//This will use the default background thread, which is good for doing the asynchronized task.
//This is really great.
void EZFaceUtil::containsSmiles(UIImage* image,EZEventBlock callback)
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        // Perform the detections
        //kCGImagePropertyOrientation;
        int exifOrientation = convertOrientation(image.imageOrientation);
    //EZDEBUG(@"Dector:%i",(int)_faceDetector);
    for(int i = 1; i < 9; i++){
        EZDEBUG(@"The image is:%i, converted:%i, faceDetector:%i", image.imageOrientation, exifOrientation, (int)_faceDetector);
        NSArray *features = [_faceDetector featuresInImage:[image CIImage]
                                                   options:@{CIDetectorEyeBlink: @YES,
                                                             CIDetectorSmile: @YES,
                                                             CIDetectorImageOrientation:@5}];
        NSLog(@"%i features, orientation:%i", [features count], i);
        BOOL happyPicture = NO;
        //if([features count] > 0) {
        //    happyPicture = YES;
        //}
        //BOOL hiddenFrame = true;
        CGRect frame;
        for(CIFeature *feature in features) {
            if ([feature isKindOfClass:[CIFaceFeature class]]) {
                CIFaceFeature *faceFeature = (CIFaceFeature *)feature;
                if(faceFeature.hasSmile) {
                    happyPicture = YES;
                    NSLog(@"Find happy face:%@", NSStringFromCGRect(feature.bounds));
                    frame = faceFeature.bounds;
                    
                }
                //if(faceFeature.leftEyeClosed || faceFeature.rightEyeClosed) {
                //    happyPicture = NO;
                //}
            }
        }
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            callback(@(happyPicture));
    }
        //});
    //});
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


//make the assumption that the inputFrame already gray out.
//I will record the number of detected face to faceResult smile scale.
//I would like to see the difference between the min-neigbor.
void EZFaceUtil::detectSmile(cv::Mat& inputFrame, EZFaceResult* faceResult)
{
    std::vector<cv::Rect> detected;
    EZDEBUG(@"The or operation:%i, %i", CV_HAAR_SCALE_IMAGE, (0 | CV_HAAR_SCALE_IMAGE));
    smileCascader.detectMultiScale(inputFrame, detected, 1.1, 1, CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    faceResult->smileDegree = detected.size();
    EZDEBUG(@"The detected face is:%lu", detected.size());
    for(int i = 0; i < detected.size(); i++){
        cv::Rect rect = detected[i];
        EZDEBUG(@"The smile region %d, %d, %d, %d", rect.x, rect.y, rect.width, rect.height);
    }
}

//This method will do following things
//1. Move the region which is smaller than the 1/10 of the image
//2. if 1 region 50% is other region, will choose the larger one.
//What you mean by larger? the area of course, any line is longer, the detector will return square, so any line longer is good enough.
//Cool, I love this game. Let's buy some good food back this afternoon
void EZFaceUtil::filterFaces(cv::Mat& inputFrame, std::vector<EZFaceResult*>& inputFaces, std::vector<EZFaceResult*>& outputFaces)
{
    float minimalRatio = 0.1;
    for(int i = 0; i < inputFaces.size(); i++){
        EZFaceResult* fr = inputFaces[i];
        float ratio = (float)fr->orgRect.width/(float)inputFrame.cols;
        if(ratio < minimalRatio){
            printf("remove small region");
            continue;
        }
        for(int j = 0; j < inputFaces.size(); j++){
            if(i != j){
                EZFaceResult* frj = inputFaces[j];
                cv::Rect overlap = fr->orgRect & frj->orgRect;
                float overArea = overlap.width * overlap.height;
                float orgArea = fr->orgRect.width * fr->orgRect.height;
                float ratio = overArea/orgArea;
                if(ratio > 0.5){
                    goto ENDLOOP;
                }
                
            }
        }
        printf("Added result");
        outputFaces.push_back(fr);
    ENDLOOP:
        continue;
    }
}



NSArray* EZFaceUtil::detectFace(UIImage* image, CGFloat miniRatio)
{
    CGFloat maxLen = 480;
    CGSize imageRatio = image.size;
    if(image.size.width > image.size.height && image.size.width > maxLen){
        imageRatio.width = maxLen;
        imageRatio.height = (image.size.height/image.size.width) * maxLen;
        image = [image resizedImageWithMaximumSize:imageRatio];
    }else if(image.size.width < image.size.height && image.size.height > maxLen){
        imageRatio.height = maxLen;
        imageRatio.width = (image.size.width/image.size.height) * maxLen;
        image = [image resizedImageWithMaximumSize:imageRatio];
    }
    EZDEBUG(@"change image:%@", NSStringFromCGSize(imageRatio));
    
    std::vector<EZFaceResult*> faces;
    cv::Mat imageFrame;
    [image toMat:imageFrame];
    detectSimpleFace(imageFrame, faces);
    NSMutableArray* res = nil;
    if(faces.size() > 0){
        EZDEBUG(@"Found face:%lu", faces.size());
        res = [[NSMutableArray alloc] init];
        for(int i = 0; i < faces.size(); i++){
            EZFaceResult* fres = faces[i];
            CGFloat widthRatio = fres->orgRect.width/imageRatio.width;
            CGFloat heightRatio = fres->orgRect.height/imageRatio.height;
             EZDEBUG(@"Find a face: %f, %f, %f, ratio: %f,%f", fres->orgRect.width, fres->orgRect.height, miniRatio, widthRatio, heightRatio);
            if(widthRatio*heightRatio > miniRatio){
                EZDEBUG(@"Find a face now");
                EZFaceResultObj* fobj = [[EZFaceResultObj alloc] init];
                fobj.orgRegion = CGRectMake(fres->orgRect.x/imageRatio.width, fres->orgRect.y/imageRatio.height, widthRatio, heightRatio);
                [res addObject:fobj];
            }
        }
    }else{
        EZDEBUG(@"Found no face");
    }
    
    return res;
}
//EZFaceResult* fr
void EZFaceUtil::detectSimpleFace(cv::Mat& inputFrame, std::vector<EZFaceResult*>& faces)
{
    
    //cv::Mat singleChannel(inputFrame.rows, inputFrame.cols, CV_8UC1);
    EZDEBUG(@"Simply get gray");
    //getGray(inputFrame, singleChannel);
    
    //clahe->apply(singleChannel, singleChannel);
    //equalizeHist(singleChannel, singleChannel);
    
    //-- Detect faces
    std::vector<cv::Rect> faceRects;
    
    faceCascader.detectMultiScale(inputFrame, faceRects, 1.1, 3, CV_HAAR_SCALE_IMAGE|0, cv::Size(30, 30), cv::Size(inputFrame.rows, inputFrame.cols));
    
    EZDEBUG(@"frame rows:%d, cols:%d, original size:%d, %d", inputFrame.rows, inputFrame.cols, inputFrame.rows, inputFrame.cols);
    //cv::resize(src, dst, Size(1024, 768), 0, 0, INTER_CUBIC)
    //CGFloat iwidth = inputFrame.cols;
    //CGFloat iheight = inputFrame.rows;
    
    for( int i = 0; i < faceRects.size(); i++ )
    {
        NSLog(@"face:%i, x:%d, y:%d, width:%d, height:%d", i, faceRects[i].x, faceRects[i].y, faceRects[i].width, faceRects[i].height);
        EZFaceResult* fres = new EZFaceResult();
        fres->orgRect = faceRects[i];
        NSLog(@"x:%f, y:%f, width:%f, height:%f", fres->orgRect.x, fres->orgRect.y, fres->orgRect.width, fres->orgRect.height);
        //fres->destRect = cv::Rect(0, 0, cropSize.width, cropSize.height);
        faces.push_back(fres);
    }
}



void EZFaceUtil::detectFace(cv::Mat& inputFrame, std::vector<EZFaceResult*>& faces,bool hasSmile, cv::Size cropSize)
{
    if(cropSize.width == 0){
        cropSize = cv::Size(40, 40);
    }
    cv::Mat singleChannel(inputFrame.rows, inputFrame.cols, CV_8UC1);
    EZDEBUG(@"Simply get gray");
    getGray(inputFrame, singleChannel);
    
    //clahe->apply(singleChannel, singleChannel);
    equalizeHist(singleChannel, singleChannel);

    //-- Detect faces
    std::vector<cv::Rect> faceRects;
    
    faceCascader.detectMultiScale( singleChannel, faceRects, 1.1, 3, CV_HAAR_SCALE_IMAGE|0, cv::Size(30, 30), cv::Size(singleChannel.rows, singleChannel.cols));
    
    EZDEBUG(@"frame rows:%d, cols:%d, original size:%d, %d", singleChannel.rows, singleChannel.cols, inputFrame.rows, inputFrame.cols);
    //cv::resize(src, dst, Size(1024, 768), 0, 0, INTER_CUBIC)
    //CGFloat iwidth = inputFrame.cols;
    //CGFloat iheight = inputFrame.rows;
    
    for( int i = 0; i < faceRects.size(); i++ )
    {
        NSLog(@"face:%i, x:%d, y:%d, width:%d, height:%d", i, faceRects[i].x, faceRects[i].y, faceRects[i].width, faceRects[i].height);
        EZFaceResult* fres = new EZFaceResult();
        fres->orgRect = faceRects[i];
         NSLog(@"x:%f, y:%f, width:%f, height:%f", fres->orgRect.x, fres->orgRect.y, fres->orgRect.width, fres->orgRect.height);
        fres->destRect = cv::Rect(0, 0, cropSize.width, cropSize.height);
        faces.push_back(fres);
    }
}