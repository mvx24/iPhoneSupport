//
//  UIImage+Gradient.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Gradient)

+ (UIImage *)gradientWithColors:(NSArray *)colors sized:(CGSize)size horizontal:(BOOL)horizontal;
- (UIImage *)reflectedImageWithHeight:(NSUInteger)height withGradient:(BOOL)gradient;

@end
