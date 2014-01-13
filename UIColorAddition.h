//
//  UIColorAddition.h
//
//  Based on the articles and source files from:
//  http://arstechnica.com/apple/guides/2009/02/iphone-development-accessing-uicolor-components.ars
//  http://bravobug.com/news/?p=448
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIColor (Addition)

@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red;			// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green;			// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue;			// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white;			// Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGFloat hue;			// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat saturation;		// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat brightness;		// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) UInt32 rgbHex;

- (BOOL)red:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a;
- (void)hue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)b;
- (NSString *)hexStringFromColor;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

- (UIColor *)colorLightenedBy:(CGFloat)amount;			// Return a new color lightened to white by % amount (0.0 to 1.0), 0.0 being the same color, 1.0 being white
- (UIColor *)colorDarkenedBy:(CGFloat)amount;			// Return a new color darkened to black by % amount, 0.0 being the same color, 1.0 being black

- (UIImage *)imageSized:(CGSize)size;

@end
