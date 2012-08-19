//
//  UIScrollView+VisibleRect.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VisibleRect)

- (CGRect)visibleRect;
- (CGRect)contentsToScrollRect:(CGRect)visibleRect;

@end
