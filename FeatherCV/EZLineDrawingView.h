//
//  MyLineDrawingView.h
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EZLineDrawingView : UIView {
 
    UIBezierPath *myPath;
    //UIColor *brushPattern;
}

@property (nonatomic, strong) UIColor* brushPattern;
//@property (nonatomic, assign) BOOL isNotFirstTime;
@property (nonatomic, strong) EZEventBlock collectBlock;

@property (nonatomic, strong) NSMutableArray* points;

- (void) paintLine:(NSArray*)line;

@end
