//
//  EZUIUtility.m
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZUIUtility.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "EZMessageCenter.h"

@implementation EZUIUtility

SINGLETON_FOR_CLASS(EZUIUtility)

- (id) init
{
    self = [super init];
    _cameraRaised = false;
    _colors = @[RGBA(255, 0, 0, 127), RGBA(127, 127, 0, 127), RGBA(127, 0, 127, 127), RGBA(0, 255, 0, 127), RGBA(0, 0, 255, 127)];
    return self;
}

- (UIColor*) getBackgroundColor:(UIColor*)color
{
    if(color){
        return color;
    }
    
    int idx = rand() % _colors.count;
    return [_colors objectAtIndex:idx];
}


- (UIImagePickerController*) getCamera:(BOOL)isAlbum completed:(EZEventBlock)block
{
    if ([UIImagePickerController isSourceTypeAvailable:
                            UIImagePickerControllerSourceTypeCamera] == NO
                          && !isAlbum)
        return nil;
    
    //[UIApplication sharedApplication].statusBarHidden = true;
    _completed = block;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(isAlbum){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //[UIImagePickerController availableMediaTypesForSourceType:
    // UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    return cameraUI;
}

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController *)controller completed:(EZEventBlock)block
{
    if (_cameraRaised || (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        && !isAlbum))
        return;
    _cameraRaised = true;
    //[UIApplication sharedApplication].statusBarHidden = true;
    _completed = block;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(isAlbum){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //[UIImagePickerController availableMediaTypesForSourceType:
    // UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _cameraRaised = false;
    [UIApplication sharedApplication].statusBarHidden = false;
    //[picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    EZDEBUG(@"Media type:%@", mediaType);
    UIImage *originalImage;//, *editedImage, *imageToUse;
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    [[EZMessageCenter getInstance] postEvent:EZCameraCompleted attached:originalImage];
    if(_completed){
       
        //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
        //[picker release];
        _completed(originalImage);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[picker dismissViewControllerAnimated:YES completion:nil];
    [[EZMessageCenter getInstance] postEvent:EZCameraCompleted attached:nil];
    _cameraRaised = false;
    [UIApplication sharedApplication].statusBarHidden = false;
}

@end
