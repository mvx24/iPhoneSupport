//
//  ThumbnailCache.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailCache : NSObject

@property (nonatomic, assign) NSTimeInterval expirationInterval;
@property (nonatomic, assign) BOOL alwaysFinishCaching;		// When a load is canceled, it only cancels loading into the control but the download should finish
@property (nonatomic, retain) NSString *failedImageName;	// The image to load into UIImageViews only when the image cannot be retreived from a given url

+ (id)sharedCache;
- (void)cacheThumbnail:(UIImage *)thumbnail withKey:(NSString *)key;
- (void)cacheThumbnailForImage:(UIImage *)image sized:(CGFloat)sized withKey:(NSString *)key;
- (UIImage *)thumbnailForKey:(NSString *)key;
- (void)removeThumbnailForKey:(NSString *)key;
- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(NSString *)key;
- (void)loadButton:(UIButton *)button withUrl:(NSString *)url withKey:(NSString *)key;
- (void)cancelLoadForImageView:(UIImageView *)imageView;
- (void)cancelLoadForButton:(UIButton *)button;
- (void)flushMemory;
- (void)flushDisk;
- (void)flushExpired;

@end
