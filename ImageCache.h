//
//  ImageCache.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, assign) NSTimeInterval expirationInterval;

+ (id)sharedCache;
- (void)cacheImage:(UIImage *)image withKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key;
- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(NSString *)key;
- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(NSString *)key completion:(void (^)(NSString *errorMessage))completion;
- (void)cancelLoadForImageView:(UIImageView *)imageView;
- (void)flushDisk;
- (void)flushExpired;

@end
