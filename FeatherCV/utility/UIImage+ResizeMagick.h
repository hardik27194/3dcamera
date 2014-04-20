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

- (UIImage *) resizedImageWithMaximumSize: (CGSize) size antialias:(BOOL)antialias;
- (UIImage *) resizedImageWithMinimumSize: (CGSize) size antialias:(BOOL)antialias;

- (UIImage *) createBlurImage:(CGFloat)blurSize;

- (UIImage*) orientationAdjust:(UIImageOrientation)orientation;

- (UIImage*) croppedImageWithRect: (CGRect) rect;
//This is exactly what do I need.
- (UIImage *) imageCroppedWithRect:(CGRect)rect;
//- (UIImage *) rotateToRightDirection;
- (UIImage *) rotateByOrientation:(UIImageOrientation)orientation;

- (UIImage*) orientationAdjust:(UIImageOrientation)orientation;

//Change the orientation without rotate it.
- (UIImage *) changeOriention:(UIImageOrientation)orientation;

- (UIImage *) flipImage;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
