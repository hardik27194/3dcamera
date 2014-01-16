//
//  FileUtil.m
//  FirstCocos2d
//
//  Created by xietian on 12-9-13.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <GPUImage.h>
#import "EZFileUtil.h"
#import "EZConstants.h"
#import "EZExtender.h"
#import "EZThreadUtility.h"


@implementation EZFileUtil


+ (NSArray*) generateMergeRect:(CGSize)size pieces:(int)pieces
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:pieces];
    CGFloat height = size.height;
    CGFloat gap = floorf(height/pieces);
    //CGFloat left = height;
    CGFloat start = 0;
    CGFloat addBond = floorf(0.05 * height);
    EZDEBUG(@"The gap for each floor is:%f", gap);
    for(int i = 0; i < pieces; i++){
        if(i == 0){
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, size.width, gap)]];
            
        }else if(i == (pieces - 1)){
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, addBond, size.width, height - start)]];
        }else{
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, addBond, size.width, gap)]];
        }
        start += gap;
    }
    return res;
}

//What's the purpose of this method
//I will generate the image for the split service.
+ (NSArray*) generateSplitRect:(CGSize)size pieces:(int)pieces
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:pieces];
    CGFloat height = size.height;
    CGFloat gap = floorf(height/pieces);
    //CGFloat left = height;
    CGFloat start = 0;
    CGFloat addBond = floorf(0.05 * height);
    EZDEBUG(@"The gap for each floor is:%f", gap);
    for(int i = 0; i < pieces; i++){
        if(i == 0){
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, size.width, gap + addBond)]];
            
        }else if(i == (pieces - 1)){
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, start-addBond, size.width,addBond + height - start)]];
        }else{
            [res addObject:[NSValue valueWithCGRect:CGRectMake(0, start - addBond, size.width, 2*addBond + gap)]];
        }
        start += gap;
    }
    return res;
}

+ (UIImage*) saveEffectsImage:(UIImage*)img effects:(NSArray*)effects
{
    int preConfigPieces = 4;
    UIImage* blockImge = img;
    //img = nil;
    ///[[EZThreadUtility getInstance] executeBlockInQueue:^(){
        NSArray* splitRects = [self generateSplitRect:blockImge.size pieces:preConfigPieces];
        CGSize imgSize = blockImge.size;
        NSMutableArray* splittedImages = [[NSMutableArray alloc] init];
        for(int i = 0; i < splitRects.count; i++){
            CGRect cropRect = [[splitRects objectAtIndex:i]CGRectValue];
            UIImage* cropImg = [blockImge imageCroppedWithRect:cropRect];
            cropImg = [self processImages:cropImg effects:effects];
            [splittedImages addObject:cropImg];
        }
        blockImge = nil;
        UIImage* combineImage = [self combineImages:splittedImages size:imgSize];
        //EZDEBUG(@"Combined size:%@,", NSStringFromCGSize(imgSize))
        //completed(combineImage);
    return combineImage;
    //} isConcurrent:YES];
}

+ (NSString*) saveToAlbum:(UIImage *)image meta:(NSDictionary *)info
{
    EZDEBUG(@"Store image get called");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage* img = [info objectForKey:@"image"];
    NSDictionary* orgdata = [info objectForKey:@"metadata"];
    NSMutableDictionary* metadata =[[NSMutableDictionary alloc] init];
    if(metadata){
        [metadata setDictionary:orgdata];
    }
    EZDEBUG(@"Recived metadata:%@, actual orientation:%i", metadata, img.imageOrientation);
    [metadata setValue:@(img.imageOrientation) forKey:@"Orientation"];
    [library writeImageToSavedPhotosAlbum:img.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error2)
     {
         //             report_memory(@"After writing to library");
         if (error2) {
             EZDEBUG(@"ERROR: the image failed to be written");
         }
         else {
             EZDEBUG(@"Stored image to album assetURL: %@", assetURL);
             //return assetURL.absoluteString;
        }
     }];

    return nil;
}

+ (UIImage*) combineImages:(NSArray *)imgs size:(CGSize)newSize
{
    
    //CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    NSArray* imgRects = [self generateMergeRect:newSize pieces:imgs.count];
    CGFloat startPos = 0.0;
    CGFloat gap = floorf(newSize.height/imgs.count);
    for(int i = 0; i < imgs.count; i++){
        CGRect cropRect = [[imgRects objectAtIndex:i]CGRectValue];
        UIImage* img = [imgs objectAtIndex:i];
        EZDEBUG(@"before crop:%@, after crop:%@", NSStringFromCGSize(img.size), NSStringFromCGRect(cropRect));
        img =  [img imageCroppedWithRect:cropRect];
        [img drawAtPoint:CGPointMake(0, startPos)];
        startPos += gap;
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
//I could use this to generate gaussian effects now.
//Cool.
+ (UIImage*) processImages:(UIImage*)img effects:(NSArray*)effects
{
    if(effects.count){
        GPUImagePicture* gp = [[GPUImagePicture alloc] initWithImage:img smoothlyScaleOutput:YES];
        GPUImageFilter* filter = nil;
        for(GPUImageFilter* gf in effects){
            [gf removeAllTargets];
            if(!filter){
                [gp addTarget:gf];
                filter = gf;
            }else{
                [filter addTarget:gf];
            }
        }
        //[filter prepareForImageCapture];
        [gp processImage];
        return [filter imageFromCurrentlyProcessedOutputWithOrientation:img.imageOrientation];
    }
    return img;
}

+ (void) removeFile:(NSString*)file dirType:(NSSearchPathDirectory)type
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *fullName = [cachePath stringByAppendingPathComponent:file];
    
    //EZDEBUG(@"FullName exist:%@",[fileManager fileExistsAtPath:fullName]?@"Yes":@"NO");
    //Add the file name
    //EZDEBUG(@"dirPath count:%i, first one:%@, fullPath:%@",paths.count, cachePath, fullName);
    NSError* err = nil;
    [fileManager removeItemAtPath:fullName error:&err];
    if(err){
        EZDEBUG(@"failed to delete files, the error:%@", err);
    }
}

//Will list all file under the specified directory
+ (NSArray*) listAllFiles:(NSSearchPathDirectory)type
{
    NSMutableArray* fileURLS = [[NSMutableArray alloc] init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    /**
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   type, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    **/
    
    NSArray* urls = [manager URLsForDirectory:type inDomains:NSUserDomainMask];
    EZDEBUG(@"The Type:%i URLS count is:%i, content:%@",type, urls.count,urls);
    
    for(NSURL* url in urls){
        NSError* error;
        NSArray* contents = [manager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        [fileURLS addObjectsFromArray:contents];
        //EZDEBUG(@"Content size:%i, content:%@",contents.count, contents);
    }
    
    EZDEBUG(@"Final urls:%i", fileURLS.count);
    return fileURLS;
}

+ (void) removeAllFileWithSuffix:(NSString*)suffix
{
    NSArray* urls = [EZFileUtil listAllFiles:NSCachesDirectory];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSError* error = nil;
    for(NSURL* url in urls){
        NSString* file = url.description;
        error = nil;
        if([file hasSuffix:suffix]){
            EZDEBUG(@"Encounter %@, should remove:%@",suffix, file);
            
            [fileMgr removeItemAtURL:url error:&error];
            if(error){
                EZDEBUG(@"Error at deleting %@, error detail:%@", url, error);
            }else{
                EZDEBUG(@"Successfully deleted:%@", url);
            }
        }
        
    }
}

+ (void) removeAllAudioFiles
{
    [EZFileUtil removeAllFileWithSuffix:@"caf"];
}



+ (void) deleteFile:(NSString*)files
{
    
}

+ (NSString*) getTempFileName:(NSString*)padding  postFix:(NSString*)postFix
{
    return [NSString stringWithFormat:@"%@%@.%@",padding, [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"],postFix];
}

//Turn bundle to abosolute URL
+ (NSString*) fileToAbosolute:(NSString *)file
{
    NSString* fullPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:file];
    return fullPath;
}

//I just pick the first one. 
+ (NSString*) fileToAbosolute:(NSString*)file dirType:(NSSearchPathDirectory)type
{
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    EZDEBUG(@"dirPath count:%i, first one:%@",dirPaths.count, docsDir);
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:file];

    return soundFilePath;
    
}

+ (NSURL*) fileToURL:(NSString*)fileName dirType:(NSSearchPathDirectory)type
{
    NSURL *res = [NSURL fileURLWithPath:[self fileToAbosolute:fileName dirType:type]];
    return res;
}

//This method will use the default type, that is the
//NSApplicationDirectory.
//Finally, after 1.5 hours I got the right path name.
//Enjoy
+ (NSURL*) fileToURL:(NSString*)fileName
{
    //return [EZFileUtil fileToURL:fileName dirType:NSApplicationDirectory];
    //NSString* pathStr = [NSString stringWithFormat:@"file:/%@/%@",[[NSBundle mainBundle] bundlePath],fileName];
    NSString* fullPath = [self fileToAbosolute:fileName];
    NSURL* res = [NSURL fileURLWithPath:fullPath];
    //EZDEBUG(@"Home made directory name:%@, URL is:%@", fullPath, res);
    return res;
}


+ (NSArray*) saveImagesToCache:(NSArray*)uiImages
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(UIImage* img in uiImages){
        NSString* fullPath = [self saveImageToCache:img];
        [res addObject:fullPath];
    }
    return res;
}

+ (NSString*) saveImageToCacheWithName:(UIImage*)img filename:(NSString*)filename
{
    NSString* fullPath = [EZFileUtil saveToCache:img.toJpegData filename:filename];
    return fullPath;
}

+ (NSString*) saveImageToCache:(UIImage*)img
{
    static  NSInteger count = 0;
    NSString* fileName = [EZFileUtil getTempFileName:int2str(count++) postFix:@"jpeg"];
    NSString* fullPath = [EZFileUtil saveToCache:img.toJpegData filename:fileName];
    return fullPath;
}


+ (void) storeImageFile:(UIImage*)image file:(NSString*)file
{
    NSData *pngData = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:file]; //Add the file name
    EZDEBUG(@"Full path will be stored:%@", filePath);
    [pngData writeToFile:filePath atomically:YES]; //Write the file
}


//
+ (NSString*) changePostFix:(NSString*)org replace:(NSString*)replace
{
    NSRange header = [org rangeOfString:@"." options:NSBackwardsSearch];
    if(header.location < org.length){
        NSString* prev = [org substringToIndex:header.location];
        NSString* combined = [prev stringByAppendingPathExtension:replace];
        return combined;
    }else {
        return [org stringByAppendingPathExtension:replace];
    }
}

+ (NSString*) generateFileName:(NSString*) prefix
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger countID = [userDefaults integerForKey:@"StoredFileCount"];
    ++ countID;
    [userDefaults setInteger:countID forKey:@"StoredFileCount"];
    NSString* timestamp = [[NSDate date] stringWithFormat:@"yyyyMMdd"];
    NSString* fileName = [NSString stringWithFormat:@"%@%@%i.png",prefix, timestamp, countID];
    return fileName;
}


//Will pick the proper file with my own name conventions.
//Great, I love this.


//IF all data have copied into the database
//If it is I will read from the database rather than from the disk.
//Save the efforts of copy things.
+ (BOOL) isDataCopyDone
{
   NSNumber* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"DataCopyDone"];
    if(data){
        return data.boolValue;
    }
    return false;
}

+ (void) setDataCopyDone:(BOOL)done
{
    [[NSUserDefaults standardUserDefaults] setBool:done forKey:@"DataCopyDone"];
}

//get the size of the file.
+ (NSInteger) getFileSize:(NSURL*)fileURL
{
    NSError* error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:&error];
    int fileSize = [fileAttributes fileSize];
    return fileSize;
}

//Save data to cache;
//more general.
//Return the full path, so that we could use later.

+ (NSString*) saveToCache:(NSData*)data filename:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename]; //Add the file name
    EZDEBUG(@"Full path will be stored:%@", filePath);
    [data writeToFile:filePath atomically:YES]; //Write the file
    return filePath;
}

@end
