//
//  SwitchTableViewCell.h
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableViewCell : UITableViewCell

@property (nonatomic, readonly) UISwitch *onOffSwitch;

- (id)init;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
