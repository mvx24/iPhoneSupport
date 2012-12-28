//
//  GalleryViewController.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//
//  To get better back/forward buttons add: icon_triangle_left.png and icon_triangle_right.png (and the @2x version) to your project.
//

#import <UIKit/UIKit.h>

@class GalleryViewController;

@protocol GalleryViewControllerDelegate <NSObject>
@required
- (NSUInteger)numberOfImagesInGallery:(GalleryViewController *)gallery;
@optional
- (UIImage *)imageNumbered:(NSUInteger)number;
- (NSString *)urlForImageNumbered:(NSUInteger)number;
- (NSString *)captionForImageNumbered:(NSUInteger)number;
- (NSArray *)toolbarItemsForImageNumbered:(NSUInteger)number;
@end

@interface GalleryViewController : UIViewController

@property (nonatomic, copy) NSString *cacheToken;
@property (nonatomic, readonly) NSUInteger currentPicture;

+ (GalleryViewController *)galleryWithDelegate:(id<GalleryViewControllerDelegate>)delegate;

@end
