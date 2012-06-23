//
//  UIImage+Normal.h
//
//  Created by Marc Angelone on 5/3/12.
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Normal)

- (UIImage *)normalizedImage;
- (UIImage *)normalizedImageScaled:(CGFloat)scale;
- (UIImage *)scaledImage:(CGFloat)scale;
// Squares the image, skewing if needed
- (UIImage *)squareImage;
// Requires a square image to start with, returns nil if width != height
- (UIImage *)thumbnailImage:(CGFloat)size;

@end
