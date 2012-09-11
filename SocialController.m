//
//  SocialController.m
//

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "SocialController.h"
#ifndef NO_FACEBOOK
#import "Facebook.h"
#endif

#define SOCIALCONTROLLER_FACEBOOK_URL	@"fb://post?message=%@"
#define SOCIALCONTROLLER_TWITTER_URL	@"twitter://post?message=%@"

@implementation SocialController

@synthesize title;
@synthesize subject;
@synthesize message;
@synthesize url;
@synthesize facebookUrl;
@synthesize hashTagArray;
@synthesize viewController;
@synthesize barButtonItem;

+ (BOOL)canShare
{
	NSString *str;
	if([MFMailComposeViewController canSendMail])
		return YES;
	str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, @""];
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
		return YES;
	str = [NSString stringWithFormat:SOCIALCONTROLLER_FACEBOOK_URL, @""];
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
		return YES;
	return NO;
}

#ifdef __BLOCKS__
+ (void)followOnTwitter:(NSString *)handle
{
	ACAccountStore *accountStore;
	ACAccountType *accountType;
	
	if(NSClassFromString(@"ACAccountStore") == nil)
	{
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:@"This feature is only available in iOS 5.0+." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
	}
	
    accountStore = [[[ACAccountStore alloc] init] autorelease];
	accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted)
		{
			NSArray *accounts = [accountStore accountsWithAccountType:accountType];
			if([accounts count] > 0)
			{
				ACAccount *twitterAccount = [accounts objectAtIndex:0];				
				TWRequest *twitterRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"]
															 parameters:[NSDictionary dictionaryWithObjectsAndKeys:handle, @"screen_name", @"true", @"follow", nil]
														  requestMethod:TWRequestMethodPOST] autorelease];
				[twitterRequest setAccount:twitterAccount];
				[twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					if([urlResponse statusCode] >= 400)
					{
						UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
						[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
					}
					else
					{
						UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Thanks! You are now following %@.", handle] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
						[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
					}
                }];
            }
			else
			{
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No twitter account setup on this device." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
				[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
			}
        }
    }];
}
#else
+ (void)followOnTwitter:(NSString *)handle
{
	NSLog(@"Could not follow %@, blocks not enabled.", handle);
}
#endif

- (id)initWithMessage:(NSString *)aMessage
{
	if(self = [super init])
	{
		self.message = aMessage;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.subject = nil;
	self.message = nil;
	self.url = nil;
	self.hashTagArray = nil;
	self.viewController = nil;
	self.barButtonItem = nil;
	[super dealloc];
}

- (NSString *)facebookUrl
{
	if(facebookUrl == nil)
		return message;
	return facebookUrl;
}

- (void)showActionSheetOverViewController:(UIViewController *)aViewController
{
	UIActionSheet *actionSheet;
	
	[self retain];
	self.viewController = aViewController;
#ifdef NO_FACEBOOK
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(self.title == nil)?@"Share":self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil] autorelease];
#else
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(self.title == nil)?@"Share":self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil] autorelease];
#endif
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:[self.viewController view]];
}

- (void)showActionSheetOverViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)aBarButtonItem
{
	UIActionSheet *actionSheet;
	
	[self retain];
	self.viewController = aViewController;
	self.barButtonItem = aBarButtonItem;
#ifdef NO_FACEBOOK
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(self.title == nil)?@"Share":self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil] autorelease];
#else
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(self.title == nil)?@"Share":self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil] autorelease];
#endif
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromBarButtonItem:self.barButtonItem animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self autorelease];
	[self.viewController dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonTitle;
	NSString *str;
	
	[self autorelease];
	
	if(buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if([buttonTitle isEqualToString:@"Email"])
	{
		MFMailComposeViewController *mailComposerViewController;
		if([MFMailComposeViewController canSendMail])
		{
			mailComposerViewController = [[[MFMailComposeViewController alloc] init] autorelease];
			mailComposerViewController.mailComposeDelegate = self;
			[mailComposerViewController setSubject:subject];
			if(self.url)
				[mailComposerViewController setMessageBody:[NSString stringWithFormat:@"%@ %@", self.message, self.url] isHTML:NO];
			else
				[mailComposerViewController setMessageBody:message isHTML:NO];
			[self retain];
			[self.viewController presentModalViewController:mailComposerViewController animated:YES];
		}
		else
		{
			UIAlertView *alert;
			alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Looks like you don't have email setup." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
			[alert show];
		}
	}
	else if([buttonTitle isEqualToString:@"Twitter"])
	{
		if(((NSClassFromString(@"TWTweetComposeViewController")) != nil) && [TWTweetComposeViewController canSendTweet])
		{
			TWTweetComposeViewController *tweetViewController;
			tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease];
			[tweetViewController setInitialText:message];
			if(self.url)
				[tweetViewController addURL:[NSURL URLWithString:self.url]];
			[self.viewController presentModalViewController:tweetViewController animated:YES];
		}
		else
		{
			if(self.url)
				str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, [[NSString stringWithFormat:@"%@ %@", self.message, self.url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			else
				str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
			}
			else
			{
				UIAlertView *alert;
				alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Looks like you don't have twitter setup or installed." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
				[alert show];
			}
		}
	}
#ifndef NO_FACEBOOK
	else if([buttonTitle isEqualToString:@"Facebook"])
	{
		id appDelegate = [[UIApplication sharedApplication] delegate];
		if([appDelegate respondsToSelector:@selector(postToFacebook:)])
		   [appDelegate performSelector:@selector(postToFacebook:) withObject:self];
	}
#endif
}

@end
