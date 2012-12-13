//
//  PagedScrollView.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "PagedScrollView.h"

@interface PagedScrollView () <UIScrollViewDelegate>
{
	NSUInteger currentPage;
	NSUInteger totalPages;
	BOOL prevLoaded, currentLoaded, nextLoaded;
}

@property (nonatomic, assign) UIView *contentView;
@property (nonatomic, retain) UIView *prevPageView;
@property (nonatomic, retain) UIView *currentPageView;
@property (nonatomic, retain) UIView *nextPageView;

- (void)setup;
- (void)swapBack;
- (void)swapForward;

@end

@implementation PagedScrollView

@synthesize scrollVertical;
@synthesize pageDelegate;

@synthesize contentView;
@synthesize prevPageView;
@synthesize currentPageView;
@synthesize nextPageView;

+ (PagedScrollView *)pagedScrollViewWithDelegate:(id<PagedScrollViewDelegate>)pageDelegate
{
	PagedScrollView *pagedScrollView = [[[PagedScrollView alloc] initWithFrame:CGRectZero] autorelease];
	pagedScrollView.pageDelegate = pageDelegate;
	return pagedScrollView;
}

- (void)reloadPages
{
	self.contentOffset = CGPointMake(0.0f, 0.0f);
	prevLoaded = currentLoaded = nextLoaded = NO;
	currentPage = 0;
	totalPages = [self.pageDelegate numberOfPagesInPagedScrollView:self];
	if(totalPages)
	{
		[self.pageDelegate loadView:prevPageView forPage:0];
		prevLoaded = YES;
	}
	if(scrollVertical)
		self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * ((totalPages > 3)?3.0f:(CGFloat)totalPages));
	else
		self.contentSize = CGSizeMake(self.frame.size.width * ((totalPages > 3)?3.0f:(CGFloat)totalPages), self.frame.size.height);
}

- (void)setup
{
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.pagingEnabled = YES;
	self.maximumZoomScale = self.minimumZoomScale = 1.0f;
	self.delegate = self;
	self.contentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	self.prevPageView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	self.currentPageView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	self.nextPageView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	[self addSubview:contentView];
	[contentView addSubview:prevPageView];
	[contentView addSubview:currentPageView];
	[contentView addSubview:nextPageView];
	[self setFrame:self.frame];
}

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		[self setup];
	}
	return self;
}

- (void)dealloc
{
	self.prevPageView = nil;
	self.currentPageView = nil;
	self.nextPageView = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}

- (void)didMoveToWindow
{
	[self reloadPages];
}

- (void)setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];
	
	if(scrollVertical)
		contentView.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height * 3.0f);
	else
		contentView.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width * 3.0f, newFrame.size.height);
	prevPageView.frame = CGRectMake(0.0f, 0.0f, newFrame.size.width, newFrame.size.height);
	if(scrollVertical)
		currentPageView.frame = CGRectMake(0.0f, newFrame.size.height, newFrame.size.width, newFrame.size.height);
	else
		currentPageView.frame = CGRectMake(newFrame.size.width, 0.0f, newFrame.size.width, newFrame.size.height);
	if(scrollVertical)
		nextPageView.frame = CGRectMake(0.0f, newFrame.size.height * 2.0f, newFrame.size.width, newFrame.size.height);
	else
		nextPageView.frame = CGRectMake(newFrame.size.width * 2.0f, 0.0f, newFrame.size.width, newFrame.size.height);
	[self reloadPages];
}

- (void)swapBack
{
	CGRect tempFrame;
	UIView *tempView;
	
	tempFrame = prevPageView.frame;
	prevPageView.frame = currentPageView.frame;
	currentPageView.frame = nextPageView.frame;
	nextPageView.frame = tempFrame;
	
	tempView = nextPageView;
	nextPageView = currentPageView;
	currentPageView = prevPageView;
	prevPageView = tempView;
	
	nextLoaded = currentLoaded;
	currentLoaded = prevLoaded;
	prevLoaded = NO;
}

- (void)swapForward
{
	CGRect tempFrame;
	UIView *tempView;
	
	tempFrame = nextPageView.frame;
	nextPageView.frame = currentPageView.frame;
	currentPageView.frame = prevPageView.frame;
	prevPageView.frame = tempFrame;
	
	tempView = prevPageView;
	prevPageView = currentPageView;
	currentPageView = nextPageView;
	nextPageView = tempView;
	
	prevLoaded = currentLoaded;
	currentLoaded = nextLoaded;
	nextLoaded = NO;
}

#pragma mark - UIScrollViewDelegate methods


#define SCROLL_PADDING 1.0f

// Upon scrolling 1px+ into the next page, load it.
// Upon scrolling halfway+ into the next page, swap it as the current.
// prevPageView will always be the first page, page 0
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// The views will always be ordered prevPageView, currentPageView, nextPageView
	// The first view is always prevPageView, and the last is typically nextPageView
	if(currentPage == 0)
	{
		// The first page
		if(scrollView.contentOffset.x > SCROLL_PADDING || scrollView.contentOffset.y > SCROLL_PADDING)
		{
			if(!currentLoaded)
			{
				[self.pageDelegate loadView:currentPageView forPage:1];
				currentLoaded = YES;
			}
			if(scrollVertical && scrollView.contentOffset.y > (prevPageView.frame.size.height / 2.0f) + SCROLL_PADDING)
			{
				if(totalPages > 1)
				{
					currentPage += 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
				}
			}
			else if(scrollView.contentOffset.x > (prevPageView.frame.size.width / 2.0f) + SCROLL_PADDING)
			{
				currentPage += 1;
				if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
					[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
			}
		}
	}
	else if(currentPage + 1 == totalPages)
	{
		// The last page, typically nextPageView
		// If only 2 total pages, then prevPageView, currentPageView or the only views used
		if(totalPages == 2)
		{
			if(scrollVertical)
			{
				if((currentPageView.frame.origin.y - scrollView.contentOffset.y) > SCROLL_PADDING)
				{
					if(!prevLoaded)
					{
						[self.pageDelegate loadView:prevPageView forPage:0];
						prevLoaded = YES;
					}
					if(scrollView.contentOffset.y < (prevPageView.frame.size.height / 2.0f) - SCROLL_PADDING)
					{
						currentPage -= 1;
						if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
							[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					}
				}
			}
			else if((currentPageView.frame.origin.x - scrollView.contentOffset.x) > SCROLL_PADDING)
			{
				if(!prevLoaded)
				{
					[self.pageDelegate loadView:prevPageView forPage:0];
					prevLoaded = YES;
				}
				if(scrollView.contentOffset.x < (prevPageView.frame.size.width / 2.0f) - SCROLL_PADDING)
				{
					currentPage -= 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
				}
			}
		}
		else
		{
			// totalPages >= 3
			if(scrollVertical)
			{
				if((nextPageView.frame.origin.y - scrollView.contentOffset.y) > SCROLL_PADDING)
				{
					if(!currentLoaded)
					{
						[self.pageDelegate loadView:currentPageView forPage:currentPage - 1];
						currentLoaded = YES;
					}
					if(scrollView.contentOffset.y < (currentPageView.frame.origin.y + (currentPageView.frame.size.height / 2.0f) - SCROLL_PADDING))
					{
						currentPage -= 1;
						if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
							[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					}
				}
			}
			else if((nextPageView.frame.origin.x - scrollView.contentOffset.x) > SCROLL_PADDING)
			{
				if(!currentLoaded)
				{
					[self.pageDelegate loadView:currentPageView forPage:currentPage - 1];
					currentLoaded = YES;
				}
				if(scrollView.contentOffset.x < (currentPageView.frame.origin.x + (currentPageView.frame.size.width / 2.0f) - SCROLL_PADDING))
				{
					currentPage -= 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
				}
			}
		}
	}
	else
	{
		CGPoint offset;

		// A middle page, only when totalPages >= 3
		if(scrollVertical)
		{
			if((scrollView.contentOffset.y - currentPageView.frame.origin.y) > SCROLL_PADDING)
			{
				if(!nextLoaded)
				{
					[self.pageDelegate loadView:nextPageView forPage:currentPage + 1];
					nextLoaded = YES;
				}
				if(scrollView.contentOffset.y > (currentPageView.frame.origin.y + (currentPageView.frame.size.height / 2.0f) + SCROLL_PADDING))
				{
					currentPage += 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					if((currentPage + 1) < totalPages)
					{
						[self swapForward];
						offset = scrollView.contentOffset;
						offset.y -= self.frame.size.height;
						scrollView.contentOffset = offset;
					}
				}
			}
			else if((currentPageView.frame.origin.y - scrollView.contentOffset.y) > SCROLL_PADDING)
			{
				if(!prevLoaded)
				{
					[self.pageDelegate loadView:prevPageView forPage:currentPage - 1];
					prevLoaded = YES;
				}
				if(scrollView.contentOffset.y < (prevPageView.frame.origin.y + (prevPageView.frame.size.height / 2.0f) - SCROLL_PADDING))
				{
					currentPage -= 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					if(currentPage)
					{
						[self swapBack];
						offset = scrollView.contentOffset;
						offset.y += self.frame.size.height;
						scrollView.contentOffset = offset;
					}
				}
			}
		}
		else
		{
			if((scrollView.contentOffset.x - currentPageView.frame.origin.x) > SCROLL_PADDING)
			{
				if(!nextLoaded)
				{
					[self.pageDelegate loadView:nextPageView forPage:currentPage + 1];
					nextLoaded = YES;
				}
				if(scrollView.contentOffset.x > (currentPageView.frame.origin.x + (currentPageView.frame.size.width / 2.0f) + SCROLL_PADDING))
				{
					currentPage += 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					if((currentPage + 1) < totalPages)
					{
						[self swapForward];
						offset = scrollView.contentOffset;
						offset.x -= self.frame.size.width;
						scrollView.contentOffset = offset;
					}
				}
			}
			else if((currentPageView.frame.origin.x - scrollView.contentOffset.x) > SCROLL_PADDING)
			{
				if(!prevLoaded)
				{
					[self.pageDelegate loadView:prevPageView forPage:currentPage - 1];
					prevLoaded = YES;
				}
				if(scrollView.contentOffset.x < (prevPageView.frame.origin.x + (prevPageView.frame.size.width / 2.0f) - SCROLL_PADDING))
				{
					currentPage -= 1;
					if([self.pageDelegate respondsToSelector:@selector(pagedScrollView:enteredPage:)])
						[self.pageDelegate pagedScrollView:self enteredPage:currentPage];
					if(currentPage)
					{
						[self swapBack];
						offset = scrollView.contentOffset;
						offset.x += self.frame.size.width;
						scrollView.contentOffset = offset;
					}
				}
			}
		}
	}
}

@end
