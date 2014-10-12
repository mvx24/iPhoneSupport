//
//  SocialController.h
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface SocialController : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *facebookUrl;
@property (nonatomic, retain) NSArray *hashTagArray;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIBarButtonItem *barButtonItem;

+ (BOOL)canShare;
+ (void)openOnTwitter:(NSString *)handle;
+ (void)followOnTwitter:(NSString *)handle;

- (id)initWithMessage:(NSString *)message;
- (void)showActionSheetOverViewController:(UIViewController *)viewController;
- (void)showActionSheetOverViewController:(UIViewController *)viewController inRect:(CGRect)frame;
- (void)showActionSheetOverViewController:(UIViewController *)viewController barButtonItem:(UIBarButtonItem *)barButtonItem;

@end
