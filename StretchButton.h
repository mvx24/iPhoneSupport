//
//  StretchButton.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StretchButton : UIButton

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) BOOL fitToIcon;
@property (nonatomic, assign) BOOL disableLeftMargin;

+ (StretchButton *)stretchedButtonWithText:(NSString *)theText textColor:(UIColor *)theTextColor font:(UIFont *)theFont image:(UIImage *)stretchableImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap;

@end
