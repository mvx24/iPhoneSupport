//
//  TextFieldTableViewCell.h
//
//  Created by marc on 5/18/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>
{
	UILabel *label;
	UITextField *textField;
}

@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UITextField *textField;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)dealloc;
- (void)layoutSubviews;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField;
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField;

@end
