//
//  UIImage+ResizeMagick.h
//
//
//  Created by Vlad Andersen on 1/5/13.
//
//



@interface UIImage (ResizeMagick)

- (UIImage *) resizedImageByMagick: (NSString *) spec;
- (UIImage *) resizedImageByWidth:  (NSUInteger) width;
- (UIImage *) resizedImageByHeight: (NSUInteger) height;
- (UIImage *) resizedImageWithMaximumSize: (CGSize) size;
- (UIImage *) resizedImageWithMinimumSize: (CGSize) size;

//This is exactly what do I need.
- (UIImage *) imageCroppedWithRect:(CGRect)rect;
//- (UIImage *) rotateToRightDirection;
- (UIImage *) rotateByOrientation:(UIImageOrientation)orientation;

- (UIImage *) flipImage;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
