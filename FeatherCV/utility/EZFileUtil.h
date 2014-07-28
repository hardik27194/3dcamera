//
//  FileUtil.h
//  FirstCocos2d
//
//  Created by xietian on 12-9-13.
//
//

#import <Foundation/Foundation.h>

//Why do we need this class?
//To provide the @2x kind of facility to the image file.
@class EZLRUMap;
@class EZEpisodeVO;
//Why do we need maps?
//So that we could pervent to read the file again and again.
static EZLRUMap* imageCaches;

@interface EZFileUtil : NSObject

+ (NSURL*) fileToURL:(NSString*)fileName dirType:(NSSearchPathDirectory)type;

+ (NSString*) fileToAbosolute:(NSString *)file;

+ (NSString*) fileToAbosolute:(NSString*)file dirType:(NSSearchPathDirectory)type;

//This method will use the default type, that is the
//NSApplicationDirectory.
+ (NSURL*) fileToURL:(NSString*)fileName;

+ (NSString*) removeFileEnd:(NSString *)fileName ender:(NSString*)ender;

+ (NSString*) appendFileEnd:(NSString *)fileName ender:(NSString*)ender;

+ (NSString*) bundleToURL:(NSString *)fileName retinaAware:(BOOL)retinaAware;

//Return the File URL
//This method will complete following things.
//1. Split the image into four part.
//2. Process image
//3. Combine it into a single image and store it.
//
+ (UIImage*) saveEffectsImage:(UIImage*)img effects:(NSArray*)effects piece:(NSInteger)piece orientation:(UIImageOrientation)orientation;

+ (NSArray*) generateSplitRect:(CGSize)size pieces:(int)pieces;

+ (UIImage*) processImages:(UIImage*)img effects:(NSArray*)effects;

+ (UIImage*) combineImages:(NSArray*)imgs size:(CGSize)size orientation:(UIImageOrientation)orientation;

+ (uint64_t) getFreeSpace;

+ (NSString*) saveImageToCacheWithName:(UIImage*)img filename:(NSString*)filename;
+ (NSString*) saveImageToCache:(UIImage*)img;

+ (BOOL) isValidImage:(NSString*)imageFile;

+ (NSString*) isExistInDocument:(NSString*)fileName;


//nil mean not exist, string mean yes.
//+ (NSString*) isExistInCache:(NSString*)fileName;

//This should be full File URL
+ (BOOL) isFileExist:(NSString*)fileName isURL:(BOOL)isURL;

+ (NSArray*) saveImagesToCache:(NSArray*)uiImages;

+ (NSString*) saveImageToCache:(UIImage*)img filename:(NSString *)filename;

+ (NSString*) saveToAlbum:(UIImage*)image meta:(NSDictionary*)meta;

+ (NSString*) getCacheFileName:(NSString*)fileName;

+ (NSString*) getDocumentFileName:(NSString *)fileName;

+ (NSString*) fileURLToFullPath:(NSString*)url;
//It is to remove all the audio file on the iPad
//So I could use the directory space for other purpose.
+ (void) removeAllAudioFiles;


+ (void) removeFile:(NSString*)file dirType:(NSSearchPathDirectory)type;

+ (void) removeAllFileWithSuffix:(NSString*)suffix;

+ (NSArray*) listAllFiles:(NSSearchPathDirectory)type;

//IF all data have copied into the database
//If it is I will read from the database rather than from the disk.
//Save the efforts of copy things.
+ (BOOL) isDataCopyDone;

+ (void) setDataCopyDone:(BOOL)done;

//get the size of the file.
+ (NSInteger) getFileSize:(NSURL*)fileURL;

+ (NSString*) getTempFileName:(NSString*)padding postFix:(NSString*)postFix;

//I will save the data to cache, so that I can upload it later
//On trouble I could think of is that the cache file will get removed. 
//+ (NSString*) saveToCache:(NSData*)data filename:(NSString*)filename;

+ (NSString*) saveToDocument:(NSData*)data filename:(NSString*)filename;

+ (NSString*) saveImageToDocument:(UIImage*)image;

+ (void) deleteFile:(NSString*)filename;

@end
