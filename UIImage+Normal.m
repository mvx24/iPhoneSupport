//
//  UIImage+Normal.m
//
//  Created by Marc Angelone on 5/3/12.
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIImage+Normal.h"

@implementation UIImage (Normal)

- (UIImage *)normalizedImage
{
	return [self normalizedImageScaled:1.0];
}

// Code adapted from: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
- (UIImage *)normalizedImageScaled:(CGFloat)scale
{
	CGImageRef imageRef;
	UIImage *normalImage;
	CGSize imageSize;
	CGContextRef ctx;
	CGAffineTransform transform = CGAffineTransformIdentity;

	if(self.imageOrientation == UIImageOrientationUp)
	{
		if(scale == 1.0)
			return self;
		return [self scaledImage:scale];
	}
	
	imageSize = self.size;
	imageRef = self.CGImage;
	
	switch(self.imageOrientation)
	{
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, imageSize.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
	
	switch (self.imageOrientation)
	{
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, imageSize.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}

	CGAffineTransformScale(transform, scale, scale);
	ctx = CGBitmapContextCreate(NULL, imageSize.width * scale, imageSize.height * scale, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	CGContextConcatCTM(ctx, transform);
	switch(self.imageOrientation)
	{
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			CGContextDrawImage(ctx, CGRectMake(0, 0, imageSize.height * scale, imageSize.width * scale), imageRef);
			break;
		default:
			CGContextDrawImage(ctx, CGRectMake(0, 0, imageSize.width * scale, imageSize.height * scale), imageRef);
			break;
	}

	imageRef = CGBitmapContextCreateImage(ctx);
	normalImage = [UIImage imageWithCGImage:imageRef];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return normalImage;
}

- (UIImage *)scaledImage:(CGFloat)scale
{
	CGContextRef ctx;
	CGImageRef imageRef;
	CGSize imageSize;
	CGAffineTransform transform = CGAffineTransformIdentity;
	UIImage *scaledImage;
	
	imageSize = self.size;
	imageRef = self.CGImage;
	
	CGAffineTransformScale(transform, scale, scale);
	ctx = CGBitmapContextCreate(NULL, imageSize.width * scale, imageSize.height * scale, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	CGContextConcatCTM(ctx, transform);
	CGContextDrawImage(ctx, CGRectMake(0, 0, imageSize.width * scale, imageSize.height * scale), imageRef);
	
	imageRef = CGBitmapContextCreateImage(ctx);
	scaledImage = [UIImage imageWithCGImage:imageRef];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return scaledImage;
}

- (UIImage *)squareImage
{
	CGContextRef ctx;
	CGImageRef imageRef;
	CGSize imageSize = self.size;
	CGFloat newSize;
	UIImage *squaredImage;
	
	if(imageSize.width == imageSize.height)
		return self;
	
	if(imageSize.width < imageSize.height)
		newSize = imageSize.width;
	else
		newSize = imageSize.height;
	
	imageRef = self.CGImage;
	ctx = CGBitmapContextCreate(NULL, newSize, newSize, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	CGContextDrawImage(ctx, CGRectMake(0, 0, newSize, newSize), imageRef);
	
	imageRef = CGBitmapContextCreateImage(ctx);
	squaredImage = [UIImage imageWithCGImage:imageRef];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return squaredImage;
	
}

- (UIImage *)thumbnailImage:(CGFloat)size
{
	CGSize imageSize = self.size;
	CGFloat scale;
	
	// Square images only
	if(imageSize.width != imageSize.height)
		return nil;
	// Do no scale up, it would only waste space without improving quality
	if(imageSize.width <= size)
		return self;
	scale = size/imageSize.width;
	return [self scaledImage:scale];
}

@end
