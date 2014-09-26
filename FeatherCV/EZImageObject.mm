//
//  EZImageObject.m
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZImageObject.h"
#import "EZCanvas.h"

@implementation EZImageObject

+ (EZImageObject*) createImage:(UIImage*)image frame:(CGRect)frame
{
    EZImageObject* imgObj = [[EZImageObject alloc] init];
    imgObj.point = frame.origin;
    if(frame.size.width == 0){
        imgObj.size = image.size;
    }else{
        imgObj.size = frame.size;
    }
    imgObj.image = image;
    return imgObj;
}

- (void) drawContext:(CGContextRef)ctx
{
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(!_image){
        return;
    }
    //EZDEBUG(@"Begin to draw image, %@, parent:%f, size:%@", NSStringFromCGSize(_image.size), self.parent.height, NSStringFromCGSize(_size));
    CGContextSaveGState(ctx);
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.parent.height);
    //CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    CGContextDrawImage(ctx, CGRectMake(_point.x, _point.y, _size.width, _size.height), _image.CGImage);
    CGContextRestoreGState(ctx);
	//}
}


@end
