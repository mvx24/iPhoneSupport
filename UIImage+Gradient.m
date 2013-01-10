//
//  UIImage+Gradient.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Gradient.h"

static CGImageRef _CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGImageAlphaNone);
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
    return theCGImage;
}

static CGContextRef _CreateBitmapContext(int pixelsWide, int pixelsHigh)
{
	CGColorSpaceRef colorSpace;
	CGContextRef bitmapContext;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	bitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh, 8, 0, colorSpace, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
    return bitmapContext;
}

@implementation UIImage (Gradient)

+ (UIImage *)gradientWithColors:(NSArray *)colors sized:(CGSize)size horizontal:(BOOL)horizontal
{
	UIImage *newImage;
	CGContextRef bitmapContext;
	CGImageRef bitmapImageRef;
	CGColorSpaceRef colorSpace;
	CGGradientRef gradientRef;
	size_t colorCount = [colors count];
	CGColorRef colorsArray[colorCount];
	CFArrayRef colorArrayRef;
	
	if(!colorCount || (size.width == 0.0f && size.height == 0.0f))
		return nil;
	
	size.width *= [[UIScreen mainScreen] scale];
	size.height *= [[UIScreen mainScreen] scale];
	
	// Create the context
	bitmapContext = _CreateBitmapContext(size.width, size.height);
	
	// Draw the gradient
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	for(int i = 0; i < colorCount; ++i)
		colorsArray[i] = [[colors objectAtIndex:i] CGColor];
	colorArrayRef = CFArrayCreate(NULL, (const void **)colorsArray, colorCount, NULL);
	gradientRef = CGGradientCreateWithColors(colorSpace, colorArrayRef, NULL);
	CGContextDrawLinearGradient(bitmapContext, gradientRef, CGPointZero, horizontal?CGPointMake(size.width, 0.0f):CGPointMake(0.0f, size.height), kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradientRef);
	CFRelease(colorArrayRef);
	
	// Cleanup
	CGColorSpaceRelease(colorSpace);
	bitmapImageRef = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
	newImage = [UIImage imageWithCGImage:bitmapImageRef];
	CGImageRelease(bitmapImageRef);
	return newImage;
}

- (UIImage *)reflectedImageWithHeight:(NSUInteger)height withGradient:(BOOL)gradient
{
	UIImage *newImage;
	CGContextRef bitmapContext;
	CGImageRef bitmapImageRef;
	
	height *= self.scale;
	
	// Create the context
	bitmapContext = _CreateBitmapContext(self.size.width * self.scale, height);
	// Draw the reflected image
	CGContextTranslateCTM(bitmapContext, 0, -((self.size.height * self.scale) - height));
	UIGraphicsPushContext(bitmapContext);
	[self drawAtPoint:CGPointMake(0.0f, height)];
	UIGraphicsPopContext();
	bitmapImageRef = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
	
	if(gradient)
	{
		CGImageRef gradientMaskImage = _CreateGradientImage(1, height);
		CGImageRef reflectionImage = CGImageCreateWithMask(bitmapImageRef, gradientMaskImage);
		CGImageRelease(bitmapImageRef);
		CGImageRelease(gradientMaskImage);
		newImage = [UIImage imageWithCGImage:reflectionImage scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(reflectionImage);
		return newImage;
	}
	else
	{
		newImage = [UIImage imageWithCGImage:bitmapImageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(bitmapImageRef);
		return newImage;
	}
}

@end