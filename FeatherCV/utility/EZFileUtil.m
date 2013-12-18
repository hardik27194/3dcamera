//
//  FileUtil.m
//  FirstCocos2d
//
//  Created by xietian on 12-9-13.
//
//

#import "EZFileUtil.h"
#import "EZConstants.h"
#import "EZExtender.h"

@implementation EZFileUtil

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
