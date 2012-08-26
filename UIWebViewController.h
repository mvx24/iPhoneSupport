//
//  UIWebViewController.h
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSDictionary *extraLoadData;
@property (nonatomic, assign) BOOL showToolbar;

- (UIWebView *)webView;
- (void)loadURL:(NSURL *)theURL;
- (void)loadFile:(NSString *)thePath scalesPageToFit:(BOOL)scalesPage;

@end
