//
//  UIScrollView+VisibleRect.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIScrollView+VisibleRect.h"

@implementation UIScrollView (VisibleRect)

- (CGRect)visibleRect
{
	CGFloat theScale;
	CGRect visibleRect;
	
	visibleRect.origin = self.contentOffset;
	visibleRect.size = self.bounds.size;
	
	theScale = 1.0f / self.zoomScale;
	visibleRect.origin.x *= theScale;
	visibleRect.origin.y *= theScale;
	visibleRect.size.width *= theScale;
	visibleRect.size.height *= theScale;
	
	return visibleRect;
}

- (CGRect)contentsToScrollRect:(CGRect)visibleRect
{
	CGFloat theScale;
	
	theScale = 1.0f / self.zoomScale;
	visibleRect.origin.x /= theScale;
	visibleRect.origin.y /= theScale;
	visibleRect.size.width /= theScale;
	visibleRect.size.height /= theScale;

	return visibleRect;
}

@end
