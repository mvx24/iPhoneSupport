//
//  FiveStarTableViewCell.h
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiveStarTableViewCell : UITableViewCell
{
	NSInteger value;
	UIButton *one, *two, *three, *four, *five;
	UIButton *stars[5];
}

@property (nonatomic, assign) NSInteger value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end
