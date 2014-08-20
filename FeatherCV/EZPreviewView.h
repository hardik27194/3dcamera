//
//  EZPreviewView.h
//  3DCamera
//
//  Created by xietian on 14-8-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

//What the purpose of the preview view?
//it call preview of all the shot photo and simulate the effects of 3D effects.
@interface EZPreviewView : UIView

- (id) initWithFrame:(CGRect)frame images:(NSArray*)image;

@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, assign) NSInteger currentPos;

@property (nonatomic, strong) EZEventBlock completeBlock;
@property (nonatomic, strong) EZEventBlock editBlock;
@property (nonatomic, weak) UIView* overLay;
@property (nonatomic, strong) UIView* toolBar;

//Once edit selected, this view will quit, not necessarily, you can use currentPosition to recover
//This is really great
+ (void) showPreview:(NSArray*)images inCtrl:(UIViewController*)viewCtrl complete:(EZEventBlock)complete edit:(EZEventBlock)edit;

@end
