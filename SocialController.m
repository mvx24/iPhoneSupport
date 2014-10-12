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

#ifndef NO_FACEBOOK
// App delegate methods expected
@interface SocialController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate>
@property (nonatomic, retain) Facebook *facebook;
- (BOOL)authorizeFacebook:(void (^)(BOOL authorized))completionHandler;
- (BOOL)authorizeFacebookPublishing:(void (^)(BOOL authorized))completionHandler;
@end
#endif

@implementation SocialController

- (BOOL)authorizeFacebook:(void (^)(BOOL authorized))completionHandler { return NO; }
- (BOOL)authorizeFacebookPublishing:(void (^)(BOOL authorized))completionHandler { return NO; }

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

+ (void)openOnTwitter:(NSString *)handle
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", handle]];
	if([[UIApplication sharedApplication] canOpenURL:url])
	{
		[[UIApplication sharedApplication] openURL:url];
	}
	else
	{
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like you don't have Twitter installed." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
	}
}

#ifdef __BLOCKS__
+ (void)followOnTwitter:(NSString *)handle
{
	ACAccountStore *accountStore;
	ACAccountType *accountType;
	
	if(NSClassFromString(@"ACAccountStore") == nil)
	{
		[SocialController openOnTwitter:handle];
		return;
		return;
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
	[SocialController openOnTwitter:handle];
}
#endif

- (id)initWithMessage:(NSString *)message
{
	if(self = [super init])
	{
		self.message = message;
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
#ifndef NO_FACEBOOK
	self.facebook = nil;
#endif
	[super dealloc];
}

- (NSString *)facebookUrl
{
	if(_facebookUrl == nil)
		return _message;
	return _facebookUrl;
}

- (void)showActionSheetOverViewController:(UIViewController *)viewController
{
	UIActionSheet *actionSheet;
	
	[self retain];
	self.viewController = viewController;
#ifdef NO_FACEBOOK
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil] autorelease];
#else
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil] autorelease];
#endif
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:[_viewController view]];
}

- (void)showActionSheetOverViewController:(UIViewController *)viewController inRect:(CGRect)frame
{
	UIActionSheet *actionSheet;
	
	[self retain];
	self.viewController = viewController;
#ifdef NO_FACEBOOK
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil] autorelease];
#else
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil] autorelease];
#endif
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromRect:frame inView:viewController.view animated:YES];
}

- (void)showActionSheetOverViewController:(UIViewController *)viewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
	UIActionSheet *actionSheet;
	
	[self retain];
	self.viewController = viewController;
	self.barButtonItem = barButtonItem;
#ifdef NO_FACEBOOK
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil] autorelease];
#else
	actionSheet = [[[UIActionSheet alloc] initWithTitle:(_title == nil)?@"Share":_title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil] autorelease];
#endif
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromBarButtonItem:_barButtonItem animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self autorelease];
	[_viewController dismissModalViewControllerAnimated:YES];
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
			[mailComposerViewController setSubject:_subject];
			if(_url)
				[mailComposerViewController setMessageBody:[NSString stringWithFormat:@"%@ %@", _message, _url] isHTML:NO];
			else
				[mailComposerViewController setMessageBody:_message isHTML:NO];
			[self retain];
			[_viewController presentModalViewController:mailComposerViewController animated:YES];
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
		NSString *completeMessage;
		
		if([_hashTagArray count])
			completeMessage = [_message stringByAppendingFormat:@" %@", [_hashTagArray componentsJoinedByString:@" "]];
		else
			completeMessage = _message;
			
		if(((NSClassFromString(@"TWTweetComposeViewController")) != nil) && [TWTweetComposeViewController canSendTweet])
		{
			TWTweetComposeViewController *tweetViewController;
			tweetViewController = [[[TWTweetComposeViewController alloc] init] autorelease];
			[tweetViewController setInitialText:completeMessage];
			if(_url)
				[tweetViewController addURL:[NSURL URLWithString:_url]];
			[_viewController presentModalViewController:tweetViewController animated:YES];
		}
		else
		{
			
			if(_url)
				str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, [[NSString stringWithFormat:@"%@ %@", completeMessage, _url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			else
				str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, [completeMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
#ifdef OLD_FACEBOOK
	else if([buttonTitle isEqualToString:@"Facebook"])
	{
		id appDelegate = [[UIApplication sharedApplication] delegate];
		if([appDelegate respondsToSelector:@selector(authorizeFacebook:)])
		{
			(void)[appDelegate authorizeFacebook:^(BOOL authorized){
				if(authorized)
				{
					// Retain until delegate methods are called
					[self retain];
					NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, @"description", facebookUrl, @"link", nil];
					[[appDelegate facebook] dialog:@"feed" andParams:params andDelegate:nil];
				}
			}];
		}
	}
#else
	else if([buttonTitle isEqualToString:@"Facebook"])
	{
		// Note: Facebook publishing permissions are not required to show the share dialog
		id appDelegate = [[UIApplication sharedApplication] delegate];
		if([appDelegate respondsToSelector:@selector(authorizeFacebook:)])
		{
			(void)[appDelegate authorizeFacebook:^(BOOL authorized){
				if(authorized)
				{
					if([FBDialogs canPresentOSIntegratedShareDialogWithSession:FBSession.activeSession])
					{
						[FBDialogs presentOSIntegratedShareDialogModallyFrom:_viewController initialText:_message image:[UIImage imageNamed:@"Icon@2x.png"] url:[_url length]?[NSURL URLWithString:_url]:nil handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
							if(result == FBOSIntegratedShareDialogResultError)
							{
								NSString *errorMessage = [NSString stringWithFormat:@"There was a problem connecting to Facebook: %@", [error localizedDescription]];
								[[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease] show];
							}
						}];
					}
					else
					{
						NSMutableDictionary *params;
						// Retain until delegate methods are called
						[self retain];
						self.facebook = [[[Facebook alloc] initWithAppId:FBSession.activeSession.appID andDelegate:nil] autorelease];
						_facebook.accessToken = FBSession.activeSession.accessTokenData.accessToken;
						_facebook.expirationDate = FBSession.activeSession.accessTokenData.expirationDate;
						params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_message, @"description", _facebookUrl, @"link", nil];
						[_facebook dialog:@"feed" andParams:params andDelegate:self];
					}
				}
			}];
		}
	}
#endif
#endif
}

#ifndef NO_FACEBOOK
- (void)dialogDidComplete:(FBDialog *)dialog
{
	[self autorelease];
}

- (void)dialogDidNotComplete:(FBDialog *)dialog
{
	[self autorelease];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
	NSString *errorMessage = [NSString stringWithFormat:@"There was a problem connecting to Facebook: %@", [error localizedDescription]];
	[[[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease] show];
	[self autorelease];
}
#endif

@end
