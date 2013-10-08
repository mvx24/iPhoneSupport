//
//  UIImage+Draw.h
//
//  Copyright (c) 2013 Symbiotic Software LLC. All rights reserved.
//
//  Draw UIBezierPaths on an image.
//

#import <UIKit/UIKit.h>

@interface UIImage (Draw)

- (UIImage *)strokePath:(UIBezierPath *)path withColor:(UIColor *)color;
- (UIImage *)strokePath:(UIBezierPath *)path withBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha color:(UIColor *)color;
- (UIImage *)fillPath:(UIBezierPath *)path withColor:(UIColor *)color;
- (UIImage *)fillPath:(UIBezierPath *)path withBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha color:(UIColor *)color;

@end
