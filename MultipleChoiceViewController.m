//
//  MultipleChoiceViewController.m
//
//  Created by marc on 5/20/09.
//  Copyright 2009 Symbiotic Software LLC. All rights reserved.
//

#import "MultipleChoiceViewController.h"

@implementation MultipleChoiceViewController

@synthesize choicesArray;
@synthesize choice;
@synthesize selectedBackgroundView;
@synthesize selectionStyle;
@synthesize allowEmptySelection;
@synthesize multipleSelection;

- (id)initWithChoices:(NSArray *)choices withCurrentChoice:(NSUInteger)currentChoice
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.choicesArray = choices;
		self.choice = currentChoice;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	return self;
}

- (void)dealloc
{
	[choicesArray release];
	self.selectedBackgroundView = nil;
	[super dealloc];
}

- (NSArray *)multipleChoices
{
	NSMutableArray *array;
	UITableViewCell *cell;
	int i;
	
	if(!multipleSelection)
		return nil;
	
	array = [NSMutableArray array];
	for(i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i)
	{
		cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
			[array addObject:[NSNumber numberWithInt:i]];
	}
	return [NSArray arrayWithArray:array];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.choicesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	if(self.selectedBackgroundView)
		cell.selectedBackgroundView = self.selectedBackgroundView;
	else
		cell.selectionStyle = self.selectionStyle;
	cell.textLabel.text = [self.choicesArray objectAtIndex:[indexPath row]];
	if([indexPath row] == self.choice)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSEnumerator *enumerator;
	UITableViewCell *cell;
	NSUInteger i;
	
	enumerator = [[tableView visibleCells] objectEnumerator];
	i = 0;
	while(cell = [enumerator nextObject])
	{
		if(i == [indexPath row])
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType = UITableViewCellAccessoryNone;
		++i;
	}
	self.choice = [indexPath row];
	cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:NO animated:YES];
}

@end

