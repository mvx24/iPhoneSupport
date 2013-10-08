//
//  UIImage+Draw.m
//
//  Copyright (c) 2013 Symbiotic Software LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Draw.h"

@implementation UIImage (Draw)

- (UIImage *)_UIImageDrawPath:(UIBezierPath *)path fill:(BOOL)fill blended:(BOOL)blended withBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha color:(UIColor *)color
{
	CGContextRef ctx;
	CGImageRef imageRef;
	CGSize imageSize;
	UIImage *drawnImage;
	
	imageSize = self.size;
	imageSize.width *= self.scale;
	imageSize.height *= self.scale;
	imageRef = self.CGImage;
	
	// Create the bitmap context
	ctx = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	
	// Draw the image
	CGContextDrawImage(ctx, CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height), imageRef);
	
	// Draw the path
	UIGraphicsPushContext(ctx);
	
	if(fill)
	{
		[color setFill];
		if(blended)
			[path fillWithBlendMode:blendMode alpha:alpha];
		else
			[path fill];
	}
	else
	{
		[color setStroke];
		if(blended)
			[path strokeWithBlendMode:blendMode alpha:alpha];
		else
			[path stroke];
	}
	UIGraphicsPopContext();
	
	// Cleanup
	imageRef = CGBitmapContextCreateImage(ctx);
	drawnImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return drawnImage;
}

- (UIImage *)strokePath:(UIBezierPath *)path withColor:(UIColor *)color
{
	return [self _UIImageDrawPath:path fill:NO blended:NO withBlendMode:kCGBlendModeNormal alpha:0.0f color:color];
}

- (UIImage *)strokePath:(UIBezierPath *)path withBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha color:(UIColor *)color
{
	return [self _UIImageDrawPath:path fill:NO blended:YES withBlendMode:blendMode alpha:alpha color:color];
}

- (UIImage *)fillPath:(UIBezierPath *)path withColor:(UIColor *)color
{
	return [self _UIImageDrawPath:path fill:YES blended:NO withBlendMode:kCGBlendModeNormal alpha:0.0f color:color];
}

- (UIImage *)fillPath:(UIBezierPath *)path withBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha color:(UIColor *)color
{
	return [self _UIImageDrawPath:path fill:YES blended:YES withBlendMode:blendMode alpha:alpha color:color];
}

@end
