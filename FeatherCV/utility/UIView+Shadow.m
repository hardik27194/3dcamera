//
//  UIView+Shadow.m
//  Shadow Maker Example
//
//  Created by Philip Yu on 5/14/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import "UIView+Shadow.h"
#import "EZGradientLayerView.h"

#define kShadowViewTag 2132



#define kValidDirections [NSArray arrayWithObjects: @"top", @"bottom", @"left", @"right",nil]

@implementation UIView (Shadow)

- (UIImageView*) loadBorder:(NSString*)imageFile tag:(NSInteger)tag;
{
    UIImageView* bottomImage = [[UIImageView alloc] initWithFrame:self.bounds];
    bottomImage.contentMode = UIViewContentModeScaleToFill;
    bottomImage.tag = tag;
    bottomImage.image = [[UIImage imageNamed:imageFile] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    bottomImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bottomImage];
    [self bringSubviewToFront:bottomImage];
    return bottomImage;
}

- (void) makeImageShadow:(EZBorderType)borderType
{
    if(borderType == kBorderBottom){
        [self loadBorder:@"border_bottom" tag:kBorderBottom];
    }else if(borderType == kBorderCeil){
        [self loadBorder:@"border_ceil" tag:kBorderCeil];
    }else if(borderType == kBorderLeft){
        [self loadBorder:@"border_left" tag:kBorderLeft];
    }else if(borderType == kBorderRight){
        [self loadBorder:@"border_right" tag:kBorderRight];
    }
}

- (void) makeImageShadow
{
    [self loadBorder:@"border_bottom" tag:kBorderBottom];
    [self loadBorder:@"border_ceil" tag:kBorderCeil];
    [self loadBorder:@"border_left" tag:kBorderLeft];
    [self loadBorder:@"border_right" tag:kBorderRight];
}

- (void) removeImageShadow
{
    //[[self viewWithTag:kShadowViewTag] removeFromSuperview];
    [self removeImageBorder:kBorderAll];
}

- (void) removeImageBorder:(EZBorderType)borderType
{
    if(borderType == kBorderAll){
        [[self viewWithTag:kBorderBottom] removeFromSuperview];
        [[self viewWithTag:kBorderCeil] removeFromSuperview];
        [[self viewWithTag:kBorderLeft] removeFromSuperview];
        [[self viewWithTag:kBorderRight] removeFromSuperview];
    }else{
        [[self viewWithTag:borderType] removeFromSuperview];
    }
    
}

- (void) adjustImageShadowSize:(CGSize)size
{
    EZDEBUG(@"Final size is:%@", NSStringFromCGSize(size));
    [[self viewWithTag:kShadowViewTag] setSize:size];
}


- (void) makeInsetShadow
{
    NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.5];
    
    UIView *shadowView = [self createShadowViewWithRadius:10 Color:color Directions:shadowDirections];
    shadowView.tag = kShadowViewTag;
    
    [self addSubview:shadowView];
}

- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color
{
    UIView* shadowView = [self viewWithTag:kShadowViewTag];
    if(!shadowView){
        EZDEBUG(@"Create shadow view:%@", NSStringFromCGSize(self.bounds.size));
        NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
        shadowView = [self createShadowViewWithRadius:radius Color:color Directions:shadowDirections];
        //shadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.tag = kShadowViewTag;
        [self addSubview:shadowView];
    }
}

- (void) removeInsetShadow
{
    [[self viewWithTag:kShadowViewTag] removeFromSuperview];
}

- (void) adjustShadowSize:(CGSize)size
{
    [[self viewWithTag:kShadowViewTag] setSize:size];
}

- (UIImage*) createBlurImage
{
    return [[self contentAsImage] applyBlurWithRadius:18.0 tintColor:RGBA(240, 240, 240, 100) saturationDeltaFactor:0.5 maskImage:nil];
}

- (UIImageView*) createBlurImageView
{
    UIImageView* blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    blurredView.image = [self createBlurImage];
    return  blurredView;
}

- (UIView*) getShadowView
{
    return [self viewWithTag:kShadowViewTag];
}

- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions
{
    UIView *shadowView = [self createShadowViewWithRadius:radius Color:color Directions:directions];
    shadowView.tag = kShadowViewTag;
    [self addSubview:shadowView];
}

- (UIView *) createShadowViewWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions
{
    EZGradientLayerView *shadowView = [[EZGradientLayerView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
    shadowView.backgroundColor = [UIColor clearColor];
    
    // Ignore duplicate direction
    NSMutableDictionary *directionDict = [[NSMutableDictionary alloc] init];
    for (NSString *direction in directions) [directionDict setObject:@"1" forKey:direction];
    
    for (NSString *direction in directionDict) {
        // Ignore invalid direction
        if ([kValidDirections containsObject:direction])
        {
            CAGradientLayer *shadow = (CAGradientLayer*)[CAGradientLayer layer];
            
            if ([direction isEqualToString:@"top"]) {
                [shadow setStartPoint:CGPointMake(0.5, 0.0)];
                [shadow setEndPoint:CGPointMake(0.5, 1.0)];
                shadow.frame = CGRectMake(0, 0, self.bounds.size.width, radius);
            }
            else if ([direction isEqualToString:@"bottom"])
            {
                [shadow setStartPoint:CGPointMake(0.5, 1.0)];
                [shadow setEndPoint:CGPointMake(0.5, 0.0)];
                shadow.frame = CGRectMake(0, self.bounds.size.height - radius, self.bounds.size.width, radius);
            } else if ([direction isEqualToString:@"left"])
            {
                shadow.frame = CGRectMake(0, 0, radius, self.bounds.size.height);
                [shadow setStartPoint:CGPointMake(0.0, 0.5)];
                [shadow setEndPoint:CGPointMake(1.0, 0.5)];
            } else if ([direction isEqualToString:@"right"])
            {
                shadow.frame = CGRectMake(self.bounds.size.width - radius, 0, radius, self.bounds.size.height);
                [shadow setStartPoint:CGPointMake(1.0, 0.5)];
                [shadow setEndPoint:CGPointMake(0.0, 0.5)];
            }
            
            shadow.colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor clearColor] CGColor], nil];
            [shadowView.layer insertSublayer:shadow atIndex:0];
        }
    }
    
    return shadowView;
}

@end
