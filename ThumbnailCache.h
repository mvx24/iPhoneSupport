//
//  ThumbnailCache.h
//
//  Created by Marc Angelone on 5/1/12.
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailCache : NSObject

@property (nonatomic, assign) NSTimeInterval expirationInterval;
@property (nonatomic, retain) NSString *failedImageName; // The image to load into UIImageViews only when the image cannot be retreived from a given url

+ (id)sharedCache;
- (void)cacheThumbnailForImage:(UIImage *)image withKey:(id)key;
- (UIImage *)thumbnailForKey:(id)key;
- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(id)key;
- (void)loadButton:(UIButton *)button withUrl:(NSString *)url withKey:(id)key;
- (void)flushMemory;
- (void)flushDisk;

@end
