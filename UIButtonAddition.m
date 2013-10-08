//
//  UIButtonAddition.m
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIButtonAddition.h"

@implementation UIButton (Addition)

- (void)setImage:(UIImage *)image backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	self.frame = CGRectMake(0.0f, 0.0f, image.size.width + (theLeftCap * 2.0f), image.size.height + (theTopCap * 2.0f));
	[self setImage:image forState:UIControlStateNormal];
	[self setBackgroundImage:[backgroundImage stretchableImageWithLeftCapWidth:theLeftCap topCapHeight:theTopCap] forState:UIControlStateNormal];
	
	self.imageView.contentMode = UIViewContentModeCenter;
	self.clipsToBounds = NO;
	self.opaque = NO;
}

- (void)setTitle:(NSString *)title font:(UIFont *)font backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	CGSize size = [title sizeWithFont:font];
	self.frame = CGRectMake(0.0f, 0.0f, size.width + 10.0f, size.height + 10.0f);
	[self setBackgroundImage:[backgroundImage stretchableImageWithLeftCapWidth:theLeftCap topCapHeight:theTopCap] forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateNormal];
	self.titleLabel.font = font;
	
	self.clipsToBounds = NO;
	self.opaque = NO;
}

+ (UIButton *)buttonWithImage:(UIImage *)image backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image backgroundImage:backgroundImage leftCap:theLeftCap topCap:theTopCap];
	return button;
}

+ (UIButton *)buttonWithTitle:(NSString *)title font:(UIFont *)font backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title font:font backgroundImage:backgroundImage leftCap:theLeftCap topCap:theTopCap];
	return button;
}

@end
