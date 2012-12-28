//
//  UIButtonAddition.m
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIButtonAddition.h"

@implementation UIButton (Addition)

+ (UIButton *)buttonWithImage:(UIImage *)image backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width + (theLeftCap * 2.0f), image.size.height + (theTopCap * 2.0f))] autorelease];
	[button setImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:[backgroundImage stretchableImageWithLeftCapWidth:theLeftCap topCapHeight:theTopCap] forState:UIControlStateNormal];
	
	button.imageView.contentMode = UIViewContentModeCenter;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	button.clipsToBounds = NO;
	button.opaque = NO;

	return button;
}

+ (UIButton *)buttonWithTitle:(NSString *)title font:(UIFont *)font backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	CGSize size = [title sizeWithFont:font];
	CGRect frame = CGRectMake(0.0f, 0.0f, size.width + 10.0f, size.height + 10.0f);
	UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
	[button setBackgroundImage:[backgroundImage stretchableImageWithLeftCapWidth:theLeftCap topCapHeight:theTopCap] forState:UIControlStateNormal];
	[button setTitle:title forState:UIControlStateNormal];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	button.clipsToBounds = NO;
	button.opaque = NO;
	
	return button;
}

@end
