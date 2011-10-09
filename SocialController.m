//
//  SocialController.m
//

#import "SocialController.h"

#define SOCIALCONTROLLER_FACEBOOK_URL	@"fb://post?message=%@"
#define SOCIALCONTROLLER_TWITTER_URL	@"twitter://post?message=%@"

@implementation SocialController

@synthesize subject;
@synthesize message;
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
	self.subject = nil;
	self.message = nil;
	self.hashTagArray = nil;
	self.viewController = nil;
	self.barButtonItem = nil;
	[super dealloc];
}

- (void)showActionSheetOverViewController:(UIViewController *)aViewController
{
	UIActionSheet *actionSheet;	
	self.viewController = aViewController;
	actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:[self.viewController view]];
}

- (void)showActionSheetOverViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)aBarButtonItem
{
	UIActionSheet *actionSheet;	
	self.viewController = aViewController;
	self.barButtonItem = aBarButtonItem;
	actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromBarButtonItem:self.barButtonItem animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.viewController dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonTitle;
	NSString *str;
	
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
			[mailComposerViewController setMessageBody:message isHTML:NO];
			[self.viewController presentModalViewController:mailComposerViewController animated:YES];
		}
	}
	else
	{
		if([buttonTitle isEqualToString:@"Twitter"])
			str = [NSString stringWithFormat:SOCIALCONTROLLER_TWITTER_URL, [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		else
			str = [NSString stringWithFormat:SOCIALCONTROLLER_FACEBOOK_URL, [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]])
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
		}
		else
		{
			UIAlertView *alert;
			alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:[NSString stringWithFormat:@"Looks like you don't have %@ installed.", buttonTitle] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
			[alert show];
		}	
	}
}

@end
