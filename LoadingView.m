//
//  LoadingView.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "LoadingView.h"

#define SIZE_LOADING_IMAGE		CGSizeMake(75.0f, 75.0f)
#define STRING_LOADING @"		Loading ..."

@interface LoadingView ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *label;

@end

@implementation LoadingView

@synthesize activityIndicatorView;
@synthesize label;

+ (LoadingView *)loadingView
{
	LoadingView *loadingView;
	loadingView = [[[LoadingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	return loadingView;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		UIFont *font;
		CGSize size;

		self.tag = TAG_LOADING_VIEW;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];

		self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];

		font = [UIFont boldSystemFontOfSize:24.0f];
		size = [STRING_LOADING sizeWithFont:font];
		self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, size.height)] autorelease];
		label.textColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
		label.shadowColor = [UIColor blackColor];
		label.shadowOffset = CGSizeMake(0.0f, -1.0f);
		label.text = STRING_LOADING;
		label.font = font;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:activityIndicatorView];
		[self addSubview:label];
	}
	return self;
}

- (void)dealloc
{
	self.activityIndicatorView = nil;
	self.label = nil;
	[super dealloc];
}

- (void)layoutSubviews
{
	CGRect frame;
	CGFloat y;
	
	[super layoutSubviews];
	
	// Center the label and resize it
	frame = self.label.frame;
	frame.origin.y = CGRectGetMidY(self.bounds) + frame.size.height/2.0f;
	frame.size.width = self.bounds.size.width;
	label.frame = frame;
	
	y = frame.origin.y;
	frame = self.activityIndicatorView.frame;
	frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width/2.0f;
	frame.origin.y = y - (frame.size.height + 10.0f);
	activityIndicatorView.frame = frame;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if(self.superview)
		[activityIndicatorView startAnimating];
	else
		[activityIndicatorView stopAnimating];
}

@end
