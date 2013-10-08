//
//  EndEditingView.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "EndEditingView.h"

@implementation EndEditingView

@synthesize endingSuperView;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(endingSuperView)
		[[self superview] endEditing:YES];
	else
		[self endEditing:YES];
}

@end
