//
//  UIWebViewController.h
//
//  Created by marc on 10/12/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController <UIWebViewDelegate>
{
@private
	UIWebView *webView;
	NSURL *url;
	BOOL file;
	BOOL scalesPage;
	BOOL inLoad;
}

- (id)init;
- (void)dealloc;
- (UIWebView *)webView;
- (void)loadURL:(NSURL *)theURL;
- (void)loadFile:(NSString *)thePath scalesPageToFit:(BOOL)scalesPage;

/* UIWebView delegate methods */
- (void)webViewDidStartLoad:(UIWebView *)theWebView;
- (void)webViewDidFinishLoad:(UIWebView *)theWebView;
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error;

@end
