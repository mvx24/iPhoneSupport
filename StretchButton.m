//
//  StretchButton.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "StretchButton.h"

@interface StretchButton ()
{
	NSInteger leftCap;
	NSInteger topCap;
}

- (void)setup;
- (void)resize;

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIImageView *iconImageView;

@end

@implementation StretchButton

@synthesize text;
@synthesize textColor;
@synthesize font;
@synthesize textLabel;
@synthesize iconImageView;
@synthesize icon;
@synthesize fitToIcon;
@synthesize disableLeftMargin;

- (void)setup
{
	self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	self.clipsToBounds = NO;
	self.opaque = NO;
	
	self.textLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	self.textLabel.textColor = [UIColor whiteColor];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.textLabel.textAlignment = UITextAlignmentCenter;
	[self addSubview:self.textLabel];
}

- (void)resize
{
	CGRect frame;
	CGSize size, imageSize;
	
	if(self.iconImageView)
	{
		frame = self.frame;
		size = [self.textLabel.text sizeWithFont:self.textLabel.font];
		imageSize = self.iconImageView.frame.size;
		frame.size.width = (leftCap * 2.0) + size.width + imageSize.width;
		if(self.fitToIcon)
			frame.size.height = (topCap * 2.0) + imageSize.height;
		else
			frame.size.height = (topCap * 2.0) + ((imageSize.height > size.height)?imageSize.height:size.height);
	}
	else
	{
		// Resize the button to fit the text
		frame = self.frame;
		size = [self.textLabel.text sizeWithFont:self.textLabel.font];
		frame.size.width = (leftCap * 2.0) + size.width;
		frame.size.height = (topCap * 2.0) + size.height;
	}
	self.frame = frame;
	[self setNeedsLayout];
}

+ (StretchButton *)stretchedButtonWithText:(NSString *)theText textColor:(UIColor *)theTextColor font:(UIFont *)theFont image:(UIImage *)stretchableImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap
{
	UIImage *image;
	StretchButton *button;
	
	button = [[[StretchButton alloc] initWithFrame:CGRectZero] autorelease];
	button->leftCap = theLeftCap;
	button->topCap = theTopCap;
	image = [stretchableImage stretchableImageWithLeftCapWidth:theLeftCap topCapHeight:theTopCap];
	[button setImage:image forState:UIControlStateNormal];
	button.text = theText;
	button.textColor = theTextColor;
	button.font = theFont;
	return button;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[self setup];
		[self resize];
	}
	return self;
}

- (void)dealloc
{
	self.textLabel = nil;
	self.iconImageView = nil;
	[super dealloc];
}

- (NSString *)text
{
	return self.textLabel.text;
}

- (void)setText:(NSString *)newText
{
	self.textLabel.text = newText;
	[self resize];
}

- (UIColor *)textColor
{
	return textLabel.textColor;
}

- (void)setTextColor:(UIColor *)newTextColor
{
	self.textLabel.textColor = newTextColor;
}

- (UIFont *)font
{
	return self.textLabel.font;
}

- (void)setFont:(UIFont *)newFont
{
	self.textLabel.font = newFont;
	[self resize];
}

- (UIImage *)icon
{
	if(self.iconImageView)
		return self.iconImageView.image;
	return nil;
}

- (void)setIcon:(UIImage *)newIcon
{
	if(newIcon)
	{
		if(!self.iconImageView)
		{
			self.iconImageView = [[[UIImageView alloc] initWithImage:newIcon] autorelease];
			[self addSubview:self.iconImageView];
		}
		self.iconImageView.image = newIcon;
		self.textLabel.textAlignment = UITextAlignmentRight;
	}
	else
	{
		[self.iconImageView removeFromSuperview];
		self.iconImageView = nil;
		self.textLabel.textAlignment = UITextAlignmentCenter;
	}
	[self resize];
}

- (void)setFitToIcon:(BOOL)newFitToIcon
{
	fitToIcon = newFitToIcon;
	[self resize];
}

- (void)layoutSubviews
{
	CGRect frame;
	
	[super layoutSubviews];
	
	frame = self.bounds;
	frame.origin.x = leftCap;
	frame.origin.y = topCap;
	frame.size.width -= (leftCap * 2.0f);
	frame.size.height -= (topCap * 2.0f);
	self.textLabel.frame = frame;
	if(self.iconImageView)
	{
		frame.size = self.iconImageView.frame.size;
		frame.origin.y = topCap + ((self.bounds.size.height - topCap * 2.0f) - frame.size.height)/2.0f;
		if(self.disableLeftMargin)
			frame.origin.x = 0.0f;
		self.iconImageView.frame = frame;
	}
}

@end
