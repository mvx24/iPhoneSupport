//
//  UIWebViewController.h
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//
//  Note: The only way to get a UIWebView to reset its browsing history is to recreate it. (i.e. this view controller)
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSDictionary *extraLoadData;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) BOOL showNavigationBarControls;
@property (nonatomic, assign) BOOL dismissOnError;

- (UIWebView *)webView;
- (void)loadURL:(NSURL *)theURL;
- (void)loadFile:(NSString *)thePath scalesPageToFit:(BOOL)scalesPage;

@end
