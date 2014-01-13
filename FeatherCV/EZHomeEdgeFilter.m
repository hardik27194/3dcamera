//
//  EZHomeEdgeFilter.m
//  FeatherCV
//
//  Created by xietian on 14-1-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHomeEdgeFilter.h"

@implementation EZHomeEdgeFilter

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    
    CGFloat minEdgeWidth = 0.001;
    CGFloat width = 1.0 / filterFrameSize.width;
    CGFloat height = 1.0 / filterFrameSize.height;
    
    CGFloat miniSize = MIN(width, height);
    
    if(miniSize < minEdgeWidth){
        if(width < height){
            //width = minEdgeWidth;
            height = (height/width)*minEdgeWidth;
            width = minEdgeWidth;
        }else{
            width = (width/height)*minEdgeWidth;
            height = minEdgeWidth;
        }
    }
    
    NSLog(@"Home made size is:%@,org:%f, %f, hasOverridden:%i, adjusted size:%f, %f", NSStringFromCGSize(filterFrameSize),1.0/filterFrameSize.width, 1.0/filterFrameSize.height,self.hasOverriddenImageSizeFactor, width,height);
    //if (!hasOverriddenImageSizeFactor)
    //{
        self.texelWidth = width;
        self.texelHeight = height;
    
        runSynchronouslyOnVideoProcessingQueue(^{
            [self setFloat:self.texelWidth forUniform:texelWidthUniform program:secondFilterProgram];
            [self setFloat:self.texelHeight forUniform:texelHeightUniform program:secondFilterProgram];
        });
        
    //}
}


@end
