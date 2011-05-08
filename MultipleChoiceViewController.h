//
//  MultipleChoiceViewController.h
//
//  Created by marc on 5/20/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MULTIPLECHOICE_MANY	-2
#define MULTIPLECHOICE_NONE	-1

@interface MultipleChoiceViewController : UITableViewController
{
	NSArray *choicesArray;
	NSInteger choice;
	
	// Customization
	UIView *selectedBackgroundView;
	UITableViewCellSelectionStyle selectionStyle;
	BOOL allowEmptySelection;
	BOOL multipleSelection;
}

@property (nonatomic, retain) NSArray *choicesArray;
@property (nonatomic, assign) NSInteger choice;
@property (nonatomic, retain) UIView *selectedBackgroundView;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic, assign) BOOL allowEmptySelection;
@property (nonatomic, assign) BOOL multipleSelection;

- (id)initWithChoices:(NSArray *)choices withCurrentChoice:(NSUInteger)currentChoice;
- (NSArray *)multipleChoices;

@end
