//
//  SwitchTableViewCell.h
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableViewCell : UITableViewCell
{
	UILabel *label;
	UISwitch *onOffSwitch;
}

@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UISwitch *onOffSwitch;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)dealloc;
- (void)layoutSubviews;

@end
