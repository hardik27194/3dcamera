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
        _testImages = @[@"hou_1.JPG",@"yue_1.JPG",@"tian_1.JPG",@"test.JPG",@"img01.jpg",@"tian_2.jpg"];
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

- (void) iterateImages:(NSString*)imageName
{
    EZFaceUtil faceUtil = singleton<EZFaceUtil>();
    std::vector<EZFaceResult*> faces;
    UIImage* testImage = [UIImage imageNamed:imageName];
    cv::Mat target = testImage.toMat;
    EZDEBUG(@"The test image name:%@ row:%d, col:%d",imageName, target.rows, target.cols);
    faceUtil.detectFace(target, faces);
    EZDEBUG(@"Final face is:%lu", faces.size());
    for(int i = 0; i < faces.size(); i++){
        EZDEBUG(@"Found face at:%d, %d,%d,%d resized to %d, %d",faces[i]->orgRect.x, faces[i]->orgRect.y,faces[i]->orgRect.width, faces[i]->orgRect.height, faces[i]->destRect.width, faces[i]->destRect.height);
        faceUtil.drawRegion(target, faces[i]->orgRect);
        cropped.image = [UIImage imageWithMat:*(faces[i]->face) andImageOrientation:testImage.imageOrientation];
    }
    EZDEBUG(@"Test image orientation:%i", testImage.imageOrientation);
    
    original.image = [UIImage imageWithMat:target andImageOrientation:testImage.imageOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
