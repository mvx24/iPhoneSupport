//
//  EndEditingView.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "EndEditingView.h"

@implementation EndEditingView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endEditing:YES];
}

@end
