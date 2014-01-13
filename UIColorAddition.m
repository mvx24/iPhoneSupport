//
//  UIColorAddition.m
//

#import "UIColorAddition.h"

#define MIN3(x,y,z)  ((y) <= (z) ? \
((x) <= (y) ? (x) : (y)) \
: \
((x) <= (z) ? (x) : (z)))

#define MAX3(x,y,z)  ((y) >= (z) ? \
((x) >= (y) ? (x) : (y)) \
: \
((x) >= (z) ? (x) : (z)))

struct rgb_color
{
    CGFloat r, g, b;
};

struct hsv_color
{
    CGFloat hue;        
    CGFloat sat;        
    CGFloat val;        
};

@implementation UIColor (Addition)

- (CGColorSpaceModel)colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL)canProvideRGBComponents
{
	switch(self.colorSpaceModel)
	{
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

- (CGFloat)red
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)green
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat)blue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat)white
{
	NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)alpha
{
	return CGColorGetAlpha(self.CGColor);
}

- (UInt32)rgbHex
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
	
	r = MIN(MAX(self.red, 0.0f), 1.0f);
	g = MIN(MAX(self.green, 0.0f), 1.0f);
	b = MIN(MAX(self.blue, 0.0f), 1.0f);
	
	return (((int)roundf(r * 255)) << 16)
	     | (((int)roundf(g * 255)) << 8)
	     | (((int)roundf(b * 255)));
}

- (BOOL)red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
	const CGFloat *components = CGColorGetComponents(self.CGColor);	
	CGFloat r,g,b,a;
	
	switch (self.colorSpaceModel)
	{
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			a = components[1];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			a = components[3];
			break;
		default:	// We don't know how to handle this model
			return NO;
	}
	
	if (red) *red = r;
	if (green) *green = g;
	if (blue) *blue = b;
	if (alpha) *alpha = a;
	
	return YES;
}

- (NSString *)hexStringFromColor
{
	return [NSString stringWithFormat:@"%0.6lX", self.rgbHex];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}

- (UIColor *)colorLightenedBy:(CGFloat)amount
{
	CGFloat h,s,b;
	[self hue:&h saturation:&s brightness:&b];
	
	s = s - (s * amount);
	b = b + ((1.0 - b) * amount);
	
	return [UIColor colorWithHue:h saturation:s brightness:b alpha:self.alpha];
}

- (UIColor *)colorDarkenedBy:(CGFloat)amount
{
	CGFloat h,s,b;
	[self hue:&h saturation:&s brightness:&b];
	
	s = s + ((1.0 - s) * amount);
	b = b - (b * amount);
	
	return [UIColor colorWithHue:h saturation:s brightness:b alpha:self.alpha];
}

+ (struct hsv_color)HSVfromRGB:(struct rgb_color)rgb
{
	struct hsv_color hsv;
	
	CGFloat rgb_min, rgb_max;
	rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
	rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
	
	hsv.val = rgb_max;
	if(hsv.val == 0)
	{
		hsv.hue = hsv.sat = 0;
		return hsv;
	}
	
	rgb.r /= hsv.val;
	rgb.g /= hsv.val;
	rgb.b /= hsv.val;
	rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
	rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
	
	hsv.sat = rgb_max - rgb_min;
	if(hsv.sat == 0)
	{
		hsv.hue = 0;
		return hsv;
	}
	
	if(rgb_max == rgb.r)
	{
		hsv.hue = 0.0 + 60.0 * (rgb.g - rgb.b);
		if (hsv.hue < 0.0)
			hsv.hue += 360.0;
	}
	else if(rgb_max == rgb.g)
	{
		hsv.hue = 120.0 + 60.0 * (rgb.b - rgb.r);
	}
	else /* rgb_max == rgb.b */
	{
		hsv.hue = 240.0 + 60.0 * (rgb.r - rgb.g);
	}
	
	return hsv;
}

- (void)hue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)b
{
	struct hsv_color hsv;
	struct rgb_color rgb;
	
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hue:saturation:brightness");
	rgb.r = [self red];
	rgb.g = [self green];
	rgb.b = [self blue];
	hsv = [UIColor HSVfromRGB:rgb];
	*h = hsv.hue / 360.0;
	*s = hsv.sat;
	*b = hsv.val;
}

- (CGFloat)hue
{
	struct hsv_color hsv;
	struct rgb_color rgb;
	
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hue");
	rgb.r = [self red];
	rgb.g = [self green];
	rgb.b = [self blue];
	hsv = [UIColor HSVfromRGB:rgb];
	return (hsv.hue / 360.0);
}

- (CGFloat)saturation
{
	struct hsv_color hsv;
	struct rgb_color rgb;
	
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -saturation");
	rgb.r = [self red];
	rgb.g = [self green];
	rgb.b = [self blue];
	hsv = [UIColor HSVfromRGB:rgb];
	return hsv.sat;
}
- (CGFloat)brightness
{
	struct hsv_color hsv;
	struct rgb_color rgb;
	
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -brightness");
	rgb.r = [self red];
	rgb.g = [self green];
	rgb.b = [self blue];
	hsv = [UIColor HSVfromRGB:rgb];
	return hsv.val;
}

- (UIImage *)imageSized:(CGSize)size
{
	UIImage *newImage;
	CGColorSpaceRef colorSpace;
	CGContextRef bitmapContext;
	CGImageRef bitmapImageRef;
	
	// Create the bitmap context, do not scale with the device because color is color, no need for 2x
	colorSpace = CGColorSpaceCreateDeviceRGB();
	bitmapContext = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
	// Draw
	CGContextSetFillColorWithColor(bitmapContext, [self CGColor]);
	CGContextFillRect(bitmapContext, CGRectMake(0.0f, 0.0f, size.width, size.height));
	
	// Cleanup
	bitmapImageRef = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease(bitmapContext);
	newImage = [UIImage imageWithCGImage:bitmapImageRef];
	CGImageRelease(bitmapImageRef);
	return newImage;
}

@end
