//
//  UIWebViewController.m
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIWebViewController.h"

#define BACK		@"\u25C4"
#define FORWARD		@"\u25BA"
#define CLOSE		@"\u2715"
#define ABOUT_BLANK	@"about:blank"

@interface UIWebViewController ()
{
@private
	UIWebView *webView;
	UIToolbar *toolbar;
	UIBarButtonItem *backItem, *forwardItem;
	UISegmentedControl *segmentedControl;
	NSURL *url;
	BOOL file;
	BOOL scalesPage;
	BOOL inLoad;
}

- (void)back:(id)sender;
- (void)forward:(id)sender;
- (void)close:(id)sender;
- (void)segmentedAction:(id)sender;
- (void)enableControls;

@end

@implementation UIWebViewController

@synthesize extraLoadData;
@synthesize showToolbar;
@synthesize showNavigationBarControls;
@synthesize dismissOnError;

- (void)dealloc
{
	self.extraLoadData = nil;
	[url release];
	url = nil;
	[webView setDelegate:nil];
	self.view = nil;
	[super dealloc];
}

#pragma mark - View controller methods

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if(self.navigationController.tabBarController.tabBar.selectedItem == self.navigationController.tabBarItem)
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ABOUT_BLANK]]];
}

- (void)viewDidLoad
{
	if(!inLoad)
	{
		if(file)
			[self loadFile:[url path] scalesPageToFit:scalesPage];
		else
			[self loadURL:url];
	}
}

- (void)loadView
{
	UIBarButtonItem *flexItem, *doneItem;

	toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)] autorelease];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	backItem = [[[UIBarButtonItem alloc] initWithTitle:BACK style:UIBarButtonItemStylePlain target:self action:@selector(back:)] autorelease];
	forwardItem = [[[UIBarButtonItem alloc] initWithTitle:FORWARD style:UIBarButtonItemStylePlain target:self action:@selector(forward:)] autorelease];
	flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	doneItem = [[[UIBarButtonItem alloc] initWithTitle:CLOSE style:UIBarButtonItemStylePlain target:self action:@selector(close:)] autorelease];
	toolbar.items = [NSArray arrayWithObjects:backItem, forwardItem, flexItem, doneItem, nil];
	webView = [[[UIWebView alloc] initWithFrame:self.showToolbar?CGRectZero:toolbar.frame] autorelease];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = [[[UIView alloc] initWithFrame:toolbar.frame] autorelease];
	[self.view addSubview:webView];
	[self.view addSubview:toolbar];
	toolbar.hidden = !self.showToolbar;
	[self enableControls];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Internal methods

- (void)back:(id)sender
{
	if([webView isLoading])
		[webView stopLoading];
	else if([webView canGoBack])
		[webView goBack];
}

- (void)forward:(id)sender
{
	if([webView isLoading])
		[webView stopLoading];
	else if([webView canGoForward])
		[webView goForward];
}

- (void)close:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setShowToolbar:(BOOL)newShowToolbar
{
	if(showToolbar != newShowToolbar)
	{
		showToolbar = newShowToolbar;
		if([self isViewLoaded])
		{
			CGRect frame;
			frame = webView.frame;
			frame.size.height += showToolbar?44.0f:-44.0f;
			webView.frame = frame;
			toolbar.hidden = !showToolbar;
		}
	}
}

- (void)segmentedAction:(id)sender
{
	if(segmentedControl.selectedSegmentIndex == 0)
		[self back:self];
	else
		[self forward:self];
}

- (void)setShowNavigationBarControls:(BOOL)newShowNavigationBarControls
{
	if(showNavigationBarControls != newShowNavigationBarControls)
	{
		showNavigationBarControls = newShowNavigationBarControls;
		if(showNavigationBarControls)
		{
			CGRect frame;
			segmentedControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:BACK, FORWARD, nil]] autorelease];
			segmentedControl.momentary = YES;
			segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
			[segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
			frame = segmentedControl.frame;
			frame.size.width += 20;
			segmentedControl.frame = frame;
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
		}
		else
		{
			segmentedControl = nil;
			self.navigationItem.leftBarButtonItem = nil;
		}
		[self enableControls];
	}
}

- (void)enableControls
{
	if(segmentedControl)
	{
		[segmentedControl setEnabled:[webView canGoBack] forSegmentAtIndex:0];
		[segmentedControl setEnabled:[webView canGoForward] forSegmentAtIndex:1];
	}
	[backItem setEnabled:[webView canGoBack]];
	[forwardItem setEnabled:[webView canGoForward]];
}

#pragma mark - External methods

- (UIWebView *)webView
{
	if(webView == nil)
		[self view];
	return webView;
}

- (void)loadURL:(NSURL *)theURL
{
	if(theURL == nil)
		return;
	inLoad = YES;
	[self view];	// load the view if needed
	url = [theURL retain];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	inLoad = NO;
}

- (void)loadFile:(NSString *)thePath scalesPageToFit:(BOOL)scalesPageToFit
{
	NSString *html, *ext;
	
	if(thePath == nil)
		return;
	inLoad = YES;
	[self view];	// load the view if needed
	file = YES;
	scalesPage = scalesPageToFit;
	
	// Setup the webview
	url = [[NSURL fileURLWithPath:thePath] retain];
	webView.delegate = self;
	webView.scalesPageToFit = scalesPageToFit;
	
	ext = [thePath pathExtension];
	if(([ext caseInsensitiveCompare:@"html"] == NSOrderedSame) || ([ext caseInsensitiveCompare:@"htm"] == NSOrderedSame))
	{
		html = [NSString stringWithContentsOfFile:thePath encoding:NSUTF8StringEncoding error:NULL];
		if(html == nil)
		{
			[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ABOUT_BLANK]]];
			return;
		}
		[webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[thePath stringByDeletingLastPathComponent]]];
	}
	else
	{
		[webView loadRequest:[NSURLRequest requestWithURL:url]];
	}
	inLoad = NO;
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *host = [[request URL] host];
	if([host isEqualToString:@"symbioticbridge.com"])
	{
		SEL command = NSSelectorFromString([NSString stringWithFormat:@"%@:", [[[request URL] relativePath] substringFromIndex:1]]);
		if(command)
		{
			[self performSelector:command withObject:webView];
			return NO;
		}
	}
	else if([host isEqualToString:@"phobos.apple.com"] || [host isEqualToString:@"itunes.apple.com"] || [host isEqualToString:@"itunes.com"])
	{
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
	if(!file)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	NSString *result;
	if(!file)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	result = [webView stringByEvaluatingJavaScriptFromString:@"typeof window.webview_loaded == 'undefined'"];
	if([result isEqualToString:@"false"])
	{
		NSMutableString *loadString = [NSMutableString stringWithString:@"{"];
		NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
		
		[loadString appendFormat:@"\"app\":\"%@\",", [infoDictionary objectForKey:@"CFBundleIdentifier"]];
		[loadString appendFormat:@"\"version\":\"%@\",", [infoDictionary objectForKey:@"CFBundleVersion"]];

		[loadString appendFormat:@"\"model\":\"%@\",", [[UIDevice currentDevice] model]];
		[loadString appendFormat:@"\"os\":\"%@ %@\",", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
		if([[NSLocale preferredLanguages] count])
			[loadString appendFormat:@"\"locale\":\"%@\",", [[NSLocale preferredLanguages] objectAtIndex:0]];

		for(NSString *key in self.extraLoadData)
			[loadString appendFormat:@"\"%@\":\"%@\",", key, [self.extraLoadData objectForKey:key]];
		
		if([loadString length] > 1)
		{
			[loadString replaceCharactersInRange:NSMakeRange([loadString length] - 1, 1) withString:@"}"];
			[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.webview_loaded(%@)", loadString]];
		}
	}
	[self enableControls];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if(error.code != -999)
	{
		[[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	}
}

#pragma - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(dismissOnError)
		[self close:nil];
}

@end
