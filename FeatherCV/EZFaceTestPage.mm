//
//  EZFaceTestPage.m
//  FeatherCV
//
//  Created by xietian on 13-11-22.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZFaceTestPage.h"
#import "EZFaceUtil.h"
#import "UIImage2OpenCV.h"
#import "EZClickView.h"
//#import <GraphicsServices/GraphicsServices.h>

@interface EZFaceTestPage (){
    UIImageView* original;
    UIImageView* cropped;
    EZClickView* clickedView;
    

}

@end

@implementation EZFaceTestPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _currentPos = 0;
    if (self) {
        // Custom initialization
        _testImages = @[@"hou_1.JPG",@"smile_face.png",@"yue_1.JPG",@"tian_1.JPG",@"test.JPG",@"img01.jpg",@"tian_2.jpg"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    original = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    original.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:original];
    
    cropped = [[UIImageView alloc] initWithFrame:CGRectMake(0, 320, 40, 40)];
    cropped.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:cropped];
    
    NSLog(@"Screen Brightness: %f",[[UIScreen mainScreen] brightness]);
    int upper = 1;
    int bottum = 2;
    
    int final = 190 * ((float)upper/(float)bottum);
    EZDEBUG(@"final is:%i", final);
    
    clickedView = [[EZClickView alloc] initWithFrame:CGRectMake(0, 400, 60, 60)];
    clickedView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:clickedView];
    __weak __typeof(self)weakSelf = self;
    clickedView.releasedBlock = ^(id sender){
        ++weakSelf.currentPos;
        if(weakSelf.currentPos >= weakSelf.testImages.count){
            weakSelf.currentPos = 0;
        }
        [weakSelf iterateImages:[weakSelf.testImages objectAtIndex:weakSelf.currentPos]];
    };
    
    cropped.backgroundColor = [UIColor greenColor];
}

- (UIImage*) scaleImage:(UIImage*)inputImg
{
    int maxLine = MAX(inputImg.size.width, inputImg.size.height);
    int limit = 720;
    if(maxLine <= limit){
        return inputImg;
    }else{
        float ratio = (float)limit/(float)maxLine;
        //calcedSize.width = org.width * ratio;
        //calcedSize.height = org.height * ratio;
        return [inputImg scaleToSize:CGSizeMake(inputImg.size.width*ratio, inputImg.size.height*ratio)];
    }

}

- (void) iterateImages:(NSString*)imageName
{
    EZFaceUtil faceUtil = singleton<EZFaceUtil>();
    std::vector<EZFaceResult*> faces;
    std::vector<EZFaceResult*> filteredFaces;
    UIImage* srcImage = [UIImage imageNamed:imageName];
    UIImage* testImage = [srcImage resizedImageWithMaximumSize:CGSizeMake(720, 720)];
    cv::Mat target;
    [testImage toMat:target];
    EZDEBUG(@"The test image name:%@ row:%d, col:%d",imageName, target.rows, target.cols);
    faceUtil.detectFace(target, faces, true);
    
    faceUtil.filterFaces(target, faces, filteredFaces);
    EZDEBUG(@"Final face is:%lu, filtered faces:%lu", faces.size(), filteredFaces.size());
    for(int i = 0; i < filteredFaces.size(); i++){
        /**
        EZDEBUG(@"Found face at:%d, %d,%d,%d resized to %d, %d",filteredFaces[i]->orgRect.x, filteredFaces[i]->orgRect.y,filteredFaces[i]->orgRect.width, filteredFaces[i]->orgRect.height, filteredFaces[i]->destRect.width, filteredFaces[i]->destRect.height);
        faceUtil.drawRegion(target, filteredFaces[i]->orgRect);
        cropped.image = [UIImage imageWithMat:*(filteredFaces[i]->face) andImageOrientation:testImage.imageOrientation];
        faceUtil.containsSmiles(srcImage, ^(NSNumber* num){
            if(num.intValue > 0){
                EZDEBUG(@"detected smile for:%i, %i, %i,%i", filteredFaces[i]->orgRect.x, filteredFaces[i]->orgRect.y, filteredFaces[i]->orgRect.width, filteredFaces[i]->orgRect.height);
            }
        });
         **/
        //original.image = [UIImage imageWithMat:*(faces[i]->resizedImage) andImageOrientation:testImage.imageOrientation];
    }
    //EZDEBUG(@"Test image orientation:%i", testImage.imageOrientation);
    
    //if(faces.size() == 0){
    original.image = [UIImage imageWithMat:target andImageOrientation:testImage.imageOrientation];
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
