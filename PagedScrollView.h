//
//  PagedScrollView.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PagedScrollView;

@protocol PagedScrollViewDelegate <NSObject>
@required
- (NSUInteger)numberOfPagesInPagedScrollView:(PagedScrollView *)pagedScrollView;
- (void)loadView:(UIView *)view forPage:(NSUInteger)page;
@optional
- (void)pagedScrollView:(PagedScrollView *)pagedScrollView enteredPage:(NSUInteger)page;
@end

@interface PagedScrollView : UIScrollView

@property (nonatomic, assign) BOOL scrollVertical;
@property (nonatomic, assign) IBOutlet id<PagedScrollViewDelegate> pageDelegate;
@property (nonatomic, readonly) NSUInteger currentPage;

+ (PagedScrollView *)pagedScrollViewWithDelegate:(id<PagedScrollViewDelegate>)pageDelegate;
- (void)reloadPages;
- (void)back;
- (void)forward;

@end
