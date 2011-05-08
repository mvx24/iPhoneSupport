//
//  SocialController.h
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface SocialController : NSObject <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
	NSString *subject;
	NSString *message;
	NSArray *hashTagArray;
	UIViewController *viewController;
}

@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *hashTagArray;
@property (nonatomic, retain) UIViewController *viewController;

+ (BOOL)canShare;

- (id)initWithMessage:(NSString *)aMessage;
- (void)dealloc;

- (void)showActionSheetOverViewController:(UIViewController *)aViewController;

@end
