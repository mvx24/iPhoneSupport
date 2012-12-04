//
//  UITableView+EmptyText.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UITableView+EmptyText.h"

#define TAG_EMPTY_LABEL		0x33977

@implementation UITableView (EmptyText)

- (NSString *)emptyText
{
	UILabel *emptyTableLabel = (UILabel *)[self viewWithTag:TAG_EMPTY_LABEL];
	return emptyTableLabel?emptyTableLabel.text:nil;
}

- (void)setEmptyText:(NSString *)emptyText
{
	UIDeviceOrientation orientation;
	UILabel *emptyTableLabel;
	CGFloat headerOffset = 0.0;
	
	emptyTableLabel = (UILabel *)[self viewWithTag:TAG_EMPTY_LABEL];
	if(emptyTableLabel == nil && emptyText == nil)
	{
		// Text is set nil and the label is missing, do nothing
		return;
	}
	else if(emptyTableLabel == nil)
	{
		emptyTableLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		emptyTableLabel.tag = TAG_EMPTY_LABEL;
		emptyTableLabel.textAlignment = UITextAlignmentCenter;
		emptyTableLabel.font = [UIFont boldSystemFontOfSize:20.0];
		emptyTableLabel.textColor = [UIColor grayColor];
		emptyTableLabel.backgroundColor = [UIColor clearColor];
	}
	if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
		headerOffset = [self.delegate tableView:self heightForHeaderInSection:0];
	if(headerOffset < 0.0)
		headerOffset = 0.0;
	orientation = [[UIDevice currentDevice] orientation];
	if((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight))
		emptyTableLabel.frame = CGRectMake(0.0, 44.0 + headerOffset, ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?1024.0:(((int)[[UIScreen mainScreen] bounds].size.height) == 568)?568.0:480.0), 43.0);
	else
		emptyTableLabel.frame = CGRectMake(0.0, 88.0 + headerOffset, ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?768.0:320.0), 43.0);
	
	if(emptyText == nil)
	{
		emptyTableLabel.text = nil;
		if(emptyTableLabel.superview)
			[emptyTableLabel removeFromSuperview];
	}
	else
	{
		emptyTableLabel.text = emptyText;
		if(emptyTableLabel.superview == nil)
			[self addSubview:emptyTableLabel];
	}
}

@end
