//
//  UIWebViewController.m
//
//  Created by marc on 10/12/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "UIWebViewController.h"


@implementation UIWebViewController

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)dealloc
{
	[url release];
	url = nil;
	self.view = nil;
	[super dealloc];
}

/*-------------------------------------------------------------------*/
#pragma mark -
#pragma mark View controller methods

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
	// for convience, also set a webview variable to use
	self.view = webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

/*-------------------------------------------------------------------*/
#pragma mark -
#pragma mark External methods

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
	self.view;	// load the view if needed
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
	self.view;	// load the view if needed
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

/*-------------------------------------------------------------------*/
#pragma mark -
#pragma mark Webview delegate methods

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
	if(!file)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	if(!file)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
