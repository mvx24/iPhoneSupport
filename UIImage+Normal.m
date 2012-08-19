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
	return [self normalizedImageScaled:1.0 squaredWithBackgroundColor:nil];
}

// Code adapted from: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
- (UIImage *)normalizedImageScaled:(CGFloat)scale
{
	return [self normalizedImageScaled:scale squaredWithBackgroundColor:nil];
}

- (UIImage *)normalizedImageScaled:(CGFloat)scale squaredWithBackgroundColor:(UIColor *)squareColor
{
	CGImageRef imageRef;
	UIImage *normalImage;
	CGSize imageSize, newImageSize;
	CGRect drawRect;
	CGContextRef ctx;
	CGAffineTransform transform = CGAffineTransformIdentity;

	imageSize = self.size;
	imageRef = self.CGImage;
	
	if(imageSize.width == imageSize.height)
		squareColor = nil;
	
	if((self.imageOrientation == UIImageOrientationUp) && !squareColor)
	{
		if(scale == 1.0)
			return self;
		return [self scaledImage:scale];
	}
	
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

	if(squareColor)
	{
		CGFloat squareSize;
		if(imageSize.height > imageSize.width)
			squareSize = imageSize.height * scale;
		else
			squareSize = imageSize.width * scale;
		newImageSize = CGSizeMake(squareSize, squareSize);
		switch(self.imageOrientation)
		{
			case UIImageOrientationLeft:
			case UIImageOrientationLeftMirrored:
			case UIImageOrientationRight:
			case UIImageOrientationRightMirrored:
				drawRect = (CGRect){.size=CGSizeMake(imageSize.height * scale, imageSize.width * scale), .origin=CGPointMake((squareSize - (imageSize.height * scale))/2.0f, (squareSize - (imageSize.width * scale))/2.0f)};
				break;
			default:
				drawRect = (CGRect){.size=CGSizeMake(imageSize.width * scale, imageSize.height * scale), .origin=CGPointMake((squareSize - (imageSize.width * scale))/2.0f, (squareSize - (imageSize.height * scale))/2.0f)};
				break;
		}
	}
	else
	{
		newImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
		drawRect = (CGRect){.size=newImageSize, .origin=CGPointZero};
		switch(self.imageOrientation)
		{
			case UIImageOrientationLeft:
			case UIImageOrientationLeftMirrored:
			case UIImageOrientationRight:
			case UIImageOrientationRightMirrored:
				drawRect.size = CGSizeMake(drawRect.size.height, drawRect.size.width);
				break;
			default:
				break;
		}
	}
	
	CGAffineTransformScale(transform, scale, scale);
	ctx = CGBitmapContextCreate(NULL, newImageSize.width, newImageSize.height, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	if(squareColor)
	{
		CGContextSetFillColorWithColor(ctx, [squareColor CGColor]);
		CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, newImageSize.width, newImageSize.height));
	}
	CGContextConcatCTM(ctx, transform);
	CGContextDrawImage(ctx, drawRect, imageRef);
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
