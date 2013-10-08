//
//  DrawerWindow.h
//
//  Copyright (c) 2013 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DRAWER_DEFAULT_DEPTH 220.0f
#define DRAWER_DEFAULT_ANIMATION_DURATION 0.25
#define DRAWER_DEFAULT_ANIMATION_OPTIONS UIViewAnimationOptionCurveEaseOut

@protocol DrawerDelegate <NSObject>
@optional
- (CGFloat)drawerDepthForOrientation:(UIInterfaceOrientation)orientation;
- (NSTimeInterval)drawerAnimationDuration;
- (UIViewAnimationOptions)drawerAnimationOptions;
@end

@interface DrawerWindow : UIWindow

@property (nonatomic, assign) id<DrawerDelegate> drawerDelegate;
@property (nonatomic, retain) UIViewController *drawerViewController;

- (BOOL)isOpen;
- (void)openDrawer:(BOOL)animated;
- (void)closeDrawer:(BOOL)animated;

@end

// Customizeable Knob button that will start opening the drawer if dragged or open it if clicked.
@interface DrawerKnob : UIButton
+ (instancetype)drawerKnob;
@end
