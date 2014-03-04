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

#define ColorTransparent 80
@implementation EZUIUtility

SINGLETON_FOR_CLASS(EZUIUtility)

- (id) init
{
    self = [super init];
    _cameraRaised = false;
    _colors = @[RGBA(255, 0, 0, ColorTransparent), RGBA(127, 127, 0, ColorTransparent), RGBA(127, 0, 127, ColorTransparent), RGBA(0, 255, 0, ColorTransparent), RGBA(0, 0, 255, ColorTransparent)];
    return self;
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (UIColor*) getBackgroundColor:(UIColor*)color
{
    if(color){
        return color;
    }
    
    int idx = rand() % _colors.count;
    return [_colors objectAtIndex:idx];
}


- (UIImagePickerController*) getCamera:(BOOL)isAlbum slide:(BOOL)slide completed:(EZEventBlock)block
{
    if ([UIImagePickerController isSourceTypeAvailable:
                            UIImagePickerControllerSourceTypeCamera] == NO
                          && !isAlbum)
        return nil;
    _triggerBySlide = slide;
    //[UIApplication sharedApplication].statusBarHidden = true;
    _completed = block;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    EZDEBUG(@"Slide:%i", slide);
    
    cameraUI.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(isAlbum){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        if(slide){
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
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

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController *)controller completed:(EZEventBlock)block allowEditing:(BOOL)allowEditing
{
    if ((([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        && !isAlbum))
        return;
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
    cameraUI.allowsEditing = allowEditing;
    cameraUI.delegate = self;
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
}

- (void)proximityStateChanged:(NSNotification *)note
{
    if ( !note ) {
        //[self setFaceDownOnSurface:NO];
        EZDEBUG(@"Don't have notes");
        //return;
    }else{
        EZDEBUG(@"notes name:%@, user information:%@", note.name, note.userInfo);
    }
    
    UIDevice *device = [UIDevice currentDevice];
    //BOOL newProximityState = device.proximityState;
    EZDEBUG(@"state is:%i", device.proximityState);
    if(device.proximityState == 0){
        [[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:nil];
    }
     [[EZMessageCenter getInstance] postEvent:EZFaceCovered attached:@(device.proximityState)];
}

- (void) enableProximate:(BOOL)enable
{
    UIDevice *device = [UIDevice currentDevice];
    if ( enable ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        device.proximityMonitoringEnabled = YES;
    } else {
        device.proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].statusBarHidden = false;
    [info objectForKey:
     UIImagePickerControllerEditedImage];
    if(_completed){
        _completed([info objectForKey:UIImagePickerControllerEditedImage]);
    }
    /**
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
     **/
}

- (void) raiseInfoWindow:(NSString*)title info:(NSString *)info
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:info delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alertView show];
    
    dispatch_later(1.5, ^(){
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /**
    //[picker dismissViewControllerAnimated:YES completion:nil];
    [[EZMessageCenter getInstance] postEvent:EZCameraCompleted attached:nil];
    _cameraRaised = false;
    **/
    //[UIApplication sharedApplication].statusBarHidden = false;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
