//
//  MyLineDrawingView.m
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EZLineDrawingView.h"


@implementation EZLineDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
                
        self.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.2];
        myPath=[[UIBezierPath alloc]init];
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=30;
        //brushPattern=[UIColor redColor];
        _brushPattern=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.2];
        _points = [[NSMutableArray alloc] init];
        self.userInteractionEnabled = YES;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //if(!_isNotFirstTime){
    //    _isNotFirstTime = YES;
    //    [[UIImage imageNamed:@"daughter.jpg"] drawInRect:rect];
    //}
    [_brushPattern setStroke];
    [myPath strokeWithBlendMode:kCGBlendModeCopy alpha:1.0];
    //Drawing code
    //[myPath stroke];
}

- (void) paintLine:(NSArray *)line
{
    [myPath removeAllPoints];
    [_points removeAllObjects];
    BOOL isFirst = true;
    for(NSValue* val in line){
        CGPoint pt = [val CGPointValue];
        if(isFirst){
            isFirst = false;
            [myPath moveToPoint:pt];
        }else{
            [myPath addLineToPoint:pt];
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    EZDEBUG(@"Touch begin");
    [myPath removeAllPoints];
    [_points removeAllObjects];
    if(_ignoreTouch){
        return;
    }
    if(touches.count > 1){
        return;
    }
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGPoint pt = [mytouch locationInView:self];
    [myPath moveToPoint:pt];
    [_points addObject:[NSValue valueWithCGPoint:pt]];
    [self setNeedsDisplay];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    EZDEBUG(@"Touch moved");
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGPoint pt = [mytouch locationInView:self];
    [myPath addLineToPoint:pt];
    [_points addObject:[NSValue valueWithCGPoint:pt]];
    [self setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    EZDEBUG(@"Touch ended");
    if(_collectBlock){
        _collectBlock(_points);
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    EZDEBUG(@"Touch cancelled");
    if(_collectBlock){
        _collectBlock(_points);
    }
    
}

- (void)dealloc
{
    
    //[brushPattern release];
    //[super dealloc];
}

@end
