//
//  OTAUpdater.h
//
//  Created by marc on 9/19/11.
//  Copyright 2011 Symbiotic Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAUpdater : NSObject <UIAlertViewDelegate>
{
@private
	NSURLConnection *plistConnection;
	NSMutableData *plistData;
	NSString *plistInstallUrl, *profileUrl;
}

+ (id)sharedUpdater;
- (void)checkForUpdates:(NSString *)plistUrl;

@end
