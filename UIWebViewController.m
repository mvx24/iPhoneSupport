//
//  UIWebViewController.m
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import "UIWebViewController.h"

#define BACK	@"\u21E0"
#define FORWARD	@"\u21E2"
#define CLOSE	@"\u2715"

@interface UIWebViewController ()
{
@private
	UIWebView *webView;
	UIToolbar *toolbar;
	NSURL *url;
	BOOL file;
	BOOL scalesPage;
	BOOL inLoad;
}

- (void)back:(id)sender;
- (void)forward:(id)sender;
- (void)close:(id)sender;

@end

@implementation UIWebViewController

@synthesize extraLoadData;
@synthesize showToolbar;

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)dealloc
{
	self.extraLoadData = nil;
	[url release];
	url = nil;
	self.view = nil;
	[super dealloc];
}

#pragma mark - View controller methods

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if(self.navigationController.tabBarController.tabBar.selectedItem == self.navigationController.tabBarItem)
	{
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
	}
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
	UIBarButtonItem *backItem, *forwardItem, *flexItem, *doneItem;

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Internal methods

- (void)back:(id)sender
{
	[webView goBack];
}

- (void)forward:(id)sender
{
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

#pragma mark - External methods

- (UIWebView *)webView
{
	UIView *temp;
	if(webView == nil)
		temp = self.view;
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
			[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
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
	if([[[request URL] host] isEqualToString:@"symbioticbridge.com"])
	{
		SEL command = NSSelectorFromString([NSString stringWithFormat:@"%@:", [[[request URL] relativePath] substringFromIndex:1]]);
		if(command)
		{
			[self performSelector:command withObject:webView];
			return NO;
		}
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
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if(error.code != -999)
	{
		UIAlertView *alert;
		alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

@end
