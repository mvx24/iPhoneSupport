//
//  GalleryViewController.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "GalleryViewController.h"
#import "ImageCache.h"
#import "PagedScrollView.h"

#define BACK		@"\u25C4"
#define FORWARD		@"\u25BA"

#define TAG_GALLERY_IMAGEVIEW		78
#define TAG_GALLERY_ACTIVITYVIEW	82
#define TAG_GALLERY_CAPTIONLABEL	87

@interface GalleryViewController () <PagedScrollViewDelegate>
{
	UINavigationItem *navigationItem;
	UINavigationBar *navigationBar;
	PagedScrollView *pagedScrollView;
	UIBarButtonItem *pageBackItem, *pageForwardItem;
	UIToolbar *toolbar;
	NSArray *rightToolbarItems;
}

@property (nonatomic, retain) NSArray *leftToolbarItems;
@property (nonatomic, assign) id<GalleryViewControllerDelegate> delegate;

- (void)done:(id)sender;
- (void)back:(id)sender;
- (void)forward:(id)sender;

@end

@implementation GalleryViewController

@synthesize leftToolbarItems;
@synthesize delegate;
@synthesize cacheToken;

+ (GalleryViewController *)galleryWithDelegate:(id<GalleryViewControllerDelegate>)delegate
{
	GalleryViewController *galleryViewController = [[[GalleryViewController alloc] init] autorelease];
	galleryViewController.delegate = delegate;
	return galleryViewController;
}

- (void)dealloc
{
	self.leftToolbarItems = nil;
	pageBackItem = pageForwardItem = nil;
	self.cacheToken = nil;
	[super dealloc];
}

- (void)done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)back:(id)sender
{
	[pagedScrollView back];
}

- (void)forward:(id)sender
{
	[pagedScrollView forward];
}

- (NSUInteger)currentPicture
{
	return pagedScrollView.currentPage;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad
{
	CGRect frame;
	UIImage *backImage, *forwardImage;
	UIBarButtonItem *fixedItem, *flexItem;
	NSUInteger numImages;
	
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	
	// Add the navigation bar
	frame = self.view.bounds;
	frame.size.height = 44.0f;
	navigationBar = [[[UINavigationBar alloc] initWithFrame:frame] autorelease];
	navigationBar.barStyle = UIBarStyleBlack;
	navigationItem = [[[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"1 of %d", numImages = [delegate numberOfImagesInGallery:self]]] autorelease];
	navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
	navigationBar.items = @[navigationItem];
	[[[UIBarItem alloc] init] autorelease];
	[self.view addSubview:navigationBar];
	
	// Add the paged scroll view
	pagedScrollView = [PagedScrollView pagedScrollViewWithDelegate:self];
	frame = self.view.bounds;
	frame.size.height -= 88.0f;
	frame.origin.y = 44.0f;
	pagedScrollView.frame = frame;
	pagedScrollView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:pagedScrollView];
	
	// Add the bottom bar
	frame = self.view.bounds;
	frame.origin.y = frame.size.height - 44.0f;
	frame.size.height = 44.0f;
	toolbar = [[[UIToolbar alloc] initWithFrame:frame] autorelease];
	toolbar.barStyle = UIBarStyleBlack;
	[self.view addSubview:toolbar];
	
	// Set the left toolbar items
	backImage = [UIImage imageNamed:@"icon_triangle_left.png"];
	forwardImage = [UIImage imageNamed:@"icon_triangle_right.png"];
	if(backImage && forwardImage)
	{
		pageBackItem = [[[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(back:)] autorelease];
		pageForwardItem = [[[UIBarButtonItem alloc] initWithImage:forwardImage style:UIBarButtonItemStylePlain target:self action:@selector(forward:)] autorelease];
	}
	else
	{
		pageBackItem = [[[UIBarButtonItem alloc] initWithTitle:BACK style:UIBarButtonItemStylePlain target:self action:@selector(back:)] autorelease];
		pageForwardItem = [[[UIBarButtonItem alloc] initWithTitle:FORWARD style:UIBarButtonItemStylePlain target:self action:@selector(forward:)] autorelease];
	}
	pageBackItem.enabled = NO;
	pageForwardItem.enabled = (numImages > 1);
	fixedItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	fixedItem.width = 10.0f;
	flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	self.leftToolbarItems = @[pageBackItem, fixedItem, pageForwardItem, flexItem];
	rightToolbarItems = [delegate toolbarItemsForImageNumbered:0];
	toolbar.items = [leftToolbarItems arrayByAddingObjectsFromArray:rightToolbarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[pagedScrollView reloadPages];
}

#pragma mark - PagedScrollViewDelegate methods

- (NSUInteger)numberOfPagesInPagedScrollView:(PagedScrollView *)pagedScrollView
{
	return [delegate numberOfImagesInGallery:self];
}

- (void)loadView:(UIView *)view forPage:(NSUInteger)page
{
	UIImageView *imageView;
	UIActivityIndicatorView *activityView;
	UILabel *captionLabel;
	
	if(![view viewWithTag:TAG_GALLERY_IMAGEVIEW])
	{
		UIFont *font;
		CGRect frame;
		
		// Setup the subviews
		imageView = [[[UIImageView alloc] initWithFrame:view.bounds] autorelease];
		imageView.backgroundColor = [UIColor clearColor];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = TAG_GALLERY_IMAGEVIEW;
		[view addSubview:imageView];
		
		activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		activityView.tag = TAG_GALLERY_ACTIVITYVIEW;
		activityView.center = imageView.center;
		[view addSubview:activityView];
		
		font = [UIFont boldSystemFontOfSize:12.0f];
		frame = view.bounds;
		frame.origin.y = frame.size.height - font.lineHeight;
		frame.size.height = font.lineHeight;
		captionLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
		captionLabel.font = font;
		captionLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		captionLabel.textColor = [UIColor whiteColor];
		captionLabel.textAlignment = UITextAlignmentCenter;
		captionLabel.tag = TAG_GALLERY_CAPTIONLABEL;
		[view addSubview:captionLabel];
	}
	else
	{
		imageView = (UIImageView *)[view viewWithTag:TAG_GALLERY_IMAGEVIEW];
		captionLabel = (UILabel *)[view viewWithTag:TAG_GALLERY_CAPTIONLABEL];
		activityView = (UIActivityIndicatorView *)[view viewWithTag:TAG_GALLERY_ACTIVITYVIEW];
	}
	
	if([delegate respondsToSelector:@selector(imageNumbered:)])
		imageView.image = [delegate imageNumbered:page];
	else
		imageView.image = nil;
	if([delegate respondsToSelector:@selector(captionForImageNumbered:)])
		captionLabel.text = [delegate captionForImageNumbered:page];
	else
		captionLabel.text = nil;
	captionLabel.hidden = (captionLabel.text == nil);
	if(imageView.image == nil && [delegate respondsToSelector:@selector(urlForImageNumbered:)])
	{
		activityView.hidden = NO;
		[activityView startAnimating];
		[[ImageCache sharedCache] loadImageView:imageView
										withUrl:[delegate urlForImageNumbered:page]
										withKey:[NSString stringWithFormat:@"%@_%d", cacheToken, page]
									 completion:^(NSString *errorMessage) {
										 if(errorMessage)
											 captionLabel.text = errorMessage;
										 [activityView stopAnimating];
										 activityView.hidden = YES;
									 }];
	}
	else
	{
		[[ImageCache sharedCache] cancelLoadForImageView:imageView];
	}
}

- (void)pagedScrollView:(PagedScrollView *)pagedScrollView enteredPage:(NSUInteger)page
{
	NSUInteger numImages;
	if([delegate respondsToSelector:@selector(toolbarItemsForImageNumbered:)])
	{
		NSArray *newRightToolbarItems = [delegate toolbarItemsForImageNumbered:page];
		if(rightToolbarItems != newRightToolbarItems)
		{
			rightToolbarItems = newRightToolbarItems;
			toolbar.items = [leftToolbarItems arrayByAddingObjectsFromArray:rightToolbarItems];
		}
	}
	numImages = [delegate numberOfImagesInGallery:self];
	pageBackItem.enabled = (page > 0);
	pageForwardItem.enabled = ((page + 1) <  numImages);
	navigationItem.title = [NSString stringWithFormat:@"%d of %d", page + 1, numImages];
}

@end
