//
//  UIViewControllerAddition.h
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIViewControllerAddition.h"

@implementation UIViewController (Addition)

- (BOOL)isVisible
{
	if(self.navigationController)
		return self.navigationController.visibleViewController == self;
	else
		return self.isViewLoaded && self.view.window;
}

@end
