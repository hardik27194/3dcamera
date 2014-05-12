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
#import "EZHomeBlendFilter.h"


@implementation EZFileUtil


+ (NSArray*) generateMergeRect:(CGSize)size pieces:(int)pieces
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:pieces];
    CGFloat edgeUnit = sqrt(pieces);
    CGFloat heightGap = floorf(size.height/edgeUnit);
    CGFloat widthGap = floorf(size.width/edgeUnit);
    CGFloat widthBand = floorf(0.12 * widthGap);
    CGFloat heightBand = floorf(0.12 * heightGap);
    EZDEBUG(@"The gap width, height:%f, %f", widthGap, heightGap);
    for(int i = 0; i < edgeUnit; i++){
        for(int j = 0; j < edgeUnit; j++){
            if(i == 0){
                if(j == 0){ //upper left
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, widthGap, heightGap)]];
                }else if(j == (edgeUnit - 1)){ //right
                    CGFloat remain = size.width - widthGap * j;
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, 0, remain, heightGap)]];
                }else{
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, 0, widthGap, heightGap)]];
                }
                
            }else if(i == (edgeUnit - 1)){
                CGFloat remain = size.height - heightGap * i;
                if(j == 0){
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(0, heightBand, widthGap, remain)]];
                }else if(j == (edgeUnit - 1)){
                    CGFloat widthRemain = size.width - widthGap * j;
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, heightBand, widthRemain, remain)]];
                }else{
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, heightBand, widthGap, remain)]];
                }
            }else{//middle cell
                if(j == 0){
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(0, heightBand, widthGap, heightGap)]];
                }else if(j == (edgeUnit - 1)){
                    CGFloat widthRemain = size.width - widthGap * j;
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, heightBand, widthRemain, heightGap)]];
                }else{
                    [res addObject:[NSValue valueWithCGRect:CGRectMake(widthBand, heightBand, widthGap, heightGap)]];
                }
                
            }
            
        }
    }
    return res;
}

+ (NSArray*) generateMergeRectOld:(CGSize)size pieces:(int)pieces
{
    NSMutableArray* res = [[NSMutableArray alloc] initWithCapacity:pieces];
    CGFloat height = size.height;
    CGFloat gap = floorf(height/pieces);
    //CGFloat left = height;
    CGFloat start = 0;
    CGFloat addBond = floorf(0.12 * gap);
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
    CGFloat edgeUnit = sqrt(pieces);
    CGFloat heightGap = floorf(size.height/edgeUnit);
    CGFloat widthGap = floorf(size.width/edgeUnit);
    CGFloat widthBand = floorf(0.12 * widthGap);
    CGFloat heightBand = floorf(0.12 * heightGap);
    EZDEBUG(@"The gap width, height:%f, %f", widthGap, heightGap);
    for(int i = 0; i < edgeUnit; i++){
        for(int j = 0; j < edgeUnit; j++){
        if(i == 0){
            if(j == 0){ //upper left
                [res addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, widthGap + widthBand, heightGap + heightBand)]];
            }else if(j == (edgeUnit - 1)){ //right
                CGFloat remain = size.width - widthGap * j;
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand, 0, remain + widthBand, heightGap + heightBand)]];
            }else{
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand, 0, widthGap + 2 * widthBand, heightGap + heightBand)]];
            }
            
        }else if(i == (edgeUnit - 1)){
            CGFloat remain = size.height - heightGap * i;
            if(j == 0){
                [res addObject:[NSValue valueWithCGRect:CGRectMake(0, heightGap*i - heightBand, widthGap + widthBand, remain + heightBand)]];
            }else if(j == (edgeUnit - 1)){
                CGFloat widthRemain = size.width - widthGap * j;
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand, heightGap * i - heightBand, widthRemain + widthBand, remain + heightBand)]];
            }else{
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand,  heightGap * i - heightBand, widthGap + 2 * widthBand, remain + heightBand)]];
            }
        }else{//middle cell
            if(j == 0){
                [res addObject:[NSValue valueWithCGRect:CGRectMake(0, i * heightGap - heightBand, widthGap +  widthBand, heightGap + 2 * heightBand)]];
            }else if(j == (edgeUnit - 1)){
                CGFloat widthRemain = size.width - widthGap * j;
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand, i * heightGap - heightBand, widthRemain + widthBand, heightGap + 2 * heightBand)]];
            }else{
                [res addObject:[NSValue valueWithCGRect:CGRectMake(widthGap * j - widthBand, heightGap * i - heightBand, widthGap + 2 * widthBand, heightGap + 2 * heightBand)]];
            }

        }
        
        }
    }
    return res;
}

+ (UIImage*) saveEffectsImage:(UIImage*)img effects:(NSArray*)effects piece:(NSInteger)piece orientation:(UIImageOrientation)orientation
{
    int preConfigPieces = piece;
    UIImage* blockImge = img;
    EZDEBUG(@"split process, the current orientation:%i", orientation);
    //img = nil;
    ///[[EZThreadUtility getInstance] executeBlockInQueue:^(){
        NSArray* splitRects = [self generateSplitRect:blockImge.size pieces:preConfigPieces];
        CGSize imgSize = blockImge.size;
        NSMutableArray* splittedImages = [[NSMutableArray alloc] init];
        for(int i = 0; i < splitRects.count; i++){
            CGRect cropRect = [[splitRects objectAtIndex:i]CGRectValue];
            UIImage* cropImg = [blockImge imageCroppedWithRect:cropRect];
            if(i == 0){
                [self processImages:cropImg effects:effects];
            }
            cropImg = [self processImages:cropImg effects:effects];
            [splittedImages addObject:cropImg];
        }
        blockImge = nil;
        UIImage* combineImage = [self combineImages:splittedImages size:imgSize orientation:orientation];
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

+ (UIImage*) combineImages:(NSArray*)images size:(CGSize)newSize orientation:(UIImageOrientation)orientation

{
    EZDEBUG(@"new combine image get called");
    //CGAffineTransform transform = CGAffineTransformIdentity;
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (newSize.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * newSize.height);
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL)
    {
        return nil;
    }
    UIImage* first = [images objectAtIndex:0];
    CGColorSpaceRef colorspace = CGImageGetColorSpace(first.CGImage);
    context = CGBitmapContextCreate (bitmapData,newSize.width,newSize.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);
    if (context == NULL){
        // error creating context
        return nil;
    }
    CGAffineTransform ctm = CGContextGetCTM(context);
    // Toggle the origin's position between the bottom-left and top-left.
    CGAffineTransformTranslate(ctm, 0.0, newSize.height);
    // Flip the handedness of the coordinate system.
    CGAffineTransformScale(ctm, 1.0, -1.0);
    // Apply the new coordinate system to the CGContext.
    CGContextConcatCTM(context, ctm);
    NSArray* imgRects = [self generateMergeRect:newSize pieces:images.count];
    //CGFloat gap = floorf(newSize.height/imgs.count);
    int edgeCount = sqrt(images.count);
    CGFloat widthGap = newSize.width/edgeCount;
    CGFloat heighGap = newSize.height/edgeCount;
    for(int row = 0; row < edgeCount; row++){
        for(int col = 0; col < edgeCount; col++){
            int pos = row*edgeCount + col;
            CGRect cropRect = [[imgRects objectAtIndex:pos]CGRectValue];
            UIImage* img = [images objectAtIndex:pos];
            //EZDEBUG(@"before crop:%@, after crop:%@", NSStringFromCGSize(img.size), NSStringFromCGRect(cropRect));
            img =  [img imageCroppedWithRect:cropRect];
            //[img drawAtPoint:CGPointMake(col * widthGap, row * heighGap)];
            CGContextDrawImage(context, CGRectMake(col * widthGap,(edgeCount - 1 - row) * heighGap, img.size.width, img.size.height), img.CGImage);
        }
    }
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:1.0 orientation:orientation];
    CGImageRelease(imgRef2);
    
    EZDEBUG(@"new combine succeed");
    return [image rotateByOrientation:orientation];
}


+ (UIImage*) combineImagesOld:(NSArray *)imgs size:(CGSize)newSize orientation:(UIImageOrientation)orientation
{
    
    //CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    NSArray* imgRects = [self generateMergeRect:newSize pieces:imgs.count];
    //CGFloat gap = floorf(newSize.height/imgs.count);
    int edgeCount = sqrt(imgs.count);
    CGFloat widthGap = newSize.width/edgeCount;
    CGFloat heighGap = newSize.height/edgeCount;
    for(int row = 0; row < edgeCount; row++){
        for(int col = 0; col < edgeCount; col++){
            int pos = row*edgeCount + col;
            CGRect cropRect = [[imgRects objectAtIndex:pos]CGRectValue];
            UIImage* img = [imgs objectAtIndex:pos];
            EZDEBUG(@"before crop:%@, after crop:%@", NSStringFromCGSize(img.size), NSStringFromCGRect(cropRect));
            img =  [img imageCroppedWithRect:cropRect];
            [img drawAtPoint:CGPointMake(col * widthGap, row * heighGap)];
        }
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
        EZHomeBlendFilter* homeBlender = nil;
        for(GPUImageFilter* gf in effects){
            [gf removeAllTargets];
            if(!filter){
                [gp addTarget:gf];
            }else{
                [filter addTarget:gf];
            }
            if([gf isKindOfClass:[EZHomeBlendFilter class]]){
                //EZDEBUG(@"Found home blend filter, set up the texel width");
                //[((EZHomeBlendFilter*)gf).edgeFilter setupFilterForSize:img.size];
                homeBlender = (EZHomeBlendFilter*)gf;
            }
            filter = gf;
        }
        //[filter prepareForImageCapture];
        //[gp processImage];
        //[homeBlender.edgeFilter setupFilterForSize:img.size];
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

+ (NSString*) saveImageToDocument:(UIImage*)image
{
    static int count = 0;
    NSString* fileName = [EZFileUtil getTempFileName:int2str(count++) postFix:@"jpg"];
    return [self saveToDocument:image.toJpegData filename:fileName];
}

+ (NSString*) saveToDocument:(NSData*)data filename:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename]; //Add the file name
    EZDEBUG(@"Full path will be stored:%@", filePath);
    [data writeToFile:filePath atomically:YES]; //Write the file
    return filePath;
}


+ (uint64_t) getFreeSpace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //EZDEBUG(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        //EZDEBUG(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);
    }
    
    return totalFreeSpace;
}

+ (void) deleteFile:(NSString*)fileName
{
    NSError* err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&err];
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

+ (BOOL) isValidImage:(NSString*)imageFile
{
    NSData * theData = [NSData dataWithContentsOfMappedFile:imageFile];
    //EZDEBUG(@"verify image total length:%i", theData.length);
    uint8_t buffer[2];
    [theData getBytes:buffer range:NSMakeRange(theData.length-2 ,2)];
    EZDEBUG(@"byte is:%i, %i", buffer[0], buffer[1]);
    if(buffer[0] == 0xFF && buffer[1] == 0xD9){
        return true;
    }
    return false;
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
+ (NSString*) fileURLToFullPath:(NSString*)url
{
    return [url substringFromIndex:7];
}

+ (NSString*) saveImageToCache:(UIImage*)img
{
    static  NSInteger count = 0;
    NSString* fileName = [EZFileUtil getTempFileName:int2str(count++) postFix:@"jpg"];
    NSString* fullPath = [EZFileUtil saveToCache:img.toJpegData filename:fileName];
    return fullPath;
}

//nil mean not exist, string mean yes.
+ (NSString*) isExistInCache:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        return [@"file://" stringByAppendingString:fullPath];
    }
    return nil;
}

+ (NSString*) isExistInDocument:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        if([self isValidImage:fullPath]){
            return [@"file://" stringByAppendingString:fullPath];
        }else{
            EZDEBUG(@"Found broken file:%@", fileName);
        }
    }
    return nil;
}

//This should be full File URL
+ (BOOL) isFileExist:(NSString*)fileName isURL:(BOOL)isURL
{
    NSString* fullPath = isURL?[fileName substringFromIndex:7]:fileName;
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
}

+ (NSString*) saveImageToCache:(UIImage*)img filename:(NSString *)filename
{
    NSString* fullPath = [EZFileUtil saveToCache:img.toJpegData filename:filename];
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
    return (NSInteger)[fileAttributes fileSize];
}


+ (NSString*) getCacheFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName]; //Add the file name
    //EZDEBUG(@"Full path will be stored:%@", filePath);
    return filePath;
}

+ (NSString*) getDocumentFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];    return filePath;
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
