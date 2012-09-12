//
//  UIImage+Instagram.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIImage+Instagram.h"

#define SIZE_MIN_INSTAGRAM 612.0f

@implementation UIImage (Instagram)

- (UIImage *)instagramImagePaddedWithColor:(UIColor *)color
{
	CGContextRef ctx;
	CGImageRef imageRef;
	CGSize imageSize = self.size;
	CGFloat newHeight, newWidth, newSize;
	UIImage *instaImage;

	if((imageSize.width >= SIZE_MIN_INSTAGRAM) && (imageSize.height >= SIZE_MIN_INSTAGRAM))
		return self;
	
	// Pad the height/width to the minimum
	newWidth = (imageSize.width < SIZE_MIN_INSTAGRAM)?SIZE_MIN_INSTAGRAM:imageSize.width;
	newHeight = (imageSize.height < SIZE_MIN_INSTAGRAM)?SIZE_MIN_INSTAGRAM:imageSize.height;
	
	if(newHeight < newWidth)
		newSize = newWidth;
	else
		newSize = newHeight;
	
	imageRef = self.CGImage;
	ctx = CGBitmapContextCreate(NULL, newSize, newSize, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	CGContextSetFillColorWithColor(ctx, [color CGColor]);
	CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, newSize, newSize));
	CGContextDrawImage(ctx, (CGRect){.size=imageSize, .origin=CGPointMake((newSize - imageSize.width)/2.0f, (newSize - imageSize.height)/2.0f)}, imageRef);
	imageRef = CGBitmapContextCreateImage(ctx);
	instaImage = [UIImage imageWithCGImage:imageRef];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return instaImage;
}

- (UIImage *)instagramImageScaled
{
	CGContextRef ctx;
	CGImageRef imageRef;
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGSize imageSize = self.size;
	CGFloat newSize;
	UIImage *instaImage;
	
	if((imageSize.width >= SIZE_MIN_INSTAGRAM) && (imageSize.height >= SIZE_MIN_INSTAGRAM))
		return self;

	newSize = SIZE_MIN_INSTAGRAM;
	imageRef = self.CGImage;
	ctx = CGBitmapContextCreate(NULL, newSize, newSize, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
	CGAffineTransformScale(transform, newSize/imageSize.width, newSize/imageSize.height);
	CGContextConcatCTM(ctx, transform);
	CGContextDrawImage(ctx, (CGRect){.size=CGSizeMake(newSize, newSize), .origin=CGPointZero}, imageRef);
	imageRef = CGBitmapContextCreateImage(ctx);
	instaImage = [UIImage imageWithCGImage:imageRef];
	CGContextRelease(ctx);
	CGImageRelease(imageRef);
	return instaImage;
}

@end
