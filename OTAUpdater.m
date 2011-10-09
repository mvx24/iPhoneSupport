//
//  OTAUpdater.m
//
//  Created by marc on 9/19/11.
//  Copyright 2011 Symbiotic Software LLC. All rights reserved.
//

#import "OTAUpdater.h"

static id sharedInstance = nil;

@implementation OTAUpdater

+ (void)initialize
{
	if(sharedInstance == nil)
	{
		sharedInstance = [[OTAUpdater alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[plistData release];
	plistData = nil;
	[plistInstallUrl release];
	plistInstallUrl = nil;
	[profileUrl release];
	profileUrl = nil;
	[super dealloc];
}

+ (id)sharedUpdater
{
	return sharedInstance;
}

- (void)checkForUpdates:(NSString *)plistUrl
{
	NSURLRequest *request;
	
	if(plistUrl == nil)
		return;
	
	[plistInstallUrl release];
	plistInstallUrl = [plistUrl retain];
	
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:plistUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
	plistConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	if(plistConnection != nil)
	{
		plistData = [[NSMutableData data] retain];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}	
}

- (void)installProfile
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileUrl]];
}

- (void)installUpdate
{
	NSURL *url;
	url = [NSURL URLWithString:[@"itms-services://?action=download-manifest&url=" stringByAppendingString:plistInstallUrl]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(profileUrl == nil)
	{
		if(buttonIndex == 1)
			[self installUpdate];
	}
	else
	{
		if(buttonIndex == 1)
			[self installProfile];
		else if(buttonIndex == 2)
			[self installUpdate];
	}
	[plistInstallUrl release];
	plistInstallUrl = nil;
	[profileUrl release];
	profileUrl = nil;
}

/*-------------------------------------------------------------------*/
#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[plistData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[plistData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	plistConnection = nil;
	[plistData release];
	plistData = nil;
	[plistInstallUrl release];
	plistInstallUrl = nil;
	NSLog(@"Failed to get OTA plist.");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *path, *version = nil;
	NSDictionary *otaDictionary, *infoDictionary, *itemDictionary, *dictionary;
	NSArray *array;
	
	// Save to a temp file
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	path = [NSTemporaryDirectory() stringByAppendingString:@"OTA.plist"];
	[plistData writeToFile:path atomically:NO];
	
	// Load the dictionaries
	otaDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	infoDictionary = [[NSBundle mainBundle] infoDictionary];
	
	// Locate the values
	profileUrl = [otaDictionary objectForKey:@"profile"];
	array = [otaDictionary objectForKey:@"items"];
	if([array count])
	{
		// Version
		itemDictionary = [array objectAtIndex:0];
		dictionary = [itemDictionary objectForKey:@"metadata"];
		version = [dictionary objectForKey:@"bundle-version"];
	}
	
	// Test for an update
	if((version != nil) && ![[infoDictionary objectForKey:@"CFBundleVersion"] isEqualToString:version])
	{
		UIAlertView *alert;
		NSString *message;

		[profileUrl retain];
		if(profileUrl != nil)
		{
			message = @"There is an update available for this app. Please install the newer provisioning profile first and then the app.";
			alert = [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Install Profile", @"Install App", nil] autorelease];
		}
		else
		{
			message = @"There is an update available for this app.";
			alert = [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Install", nil] autorelease];
		}
		[alert show];
	}
	else
	{
		[plistInstallUrl release];
		plistInstallUrl = nil;
	}
	
	// Cleanup
	plistConnection = nil;
	[plistData release];
	plistData = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
