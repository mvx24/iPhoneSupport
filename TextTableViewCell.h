//
//  TextTableViewCell.h
//
//  Created by marc on 12/24/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextTableViewCell : UITableViewCell
{
	UILabel *label;
	NSString *textString;
}

@property (nonatomic, assign) UILabel *label;
@property (nonatomic, retain) NSString *textString;

+ (CGFloat)rowHeightForText:(NSString *)str withWidth:(CGFloat)width intoCell:(TextTableViewCell *)cell;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)dealloc;
- (void)layoutSubviews;

@end
