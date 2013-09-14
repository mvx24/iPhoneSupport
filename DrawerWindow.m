//
//  DrawerWindow.m
//
//  Copyright (c) 2013 Symbiotic Software LLC. All rights reserved.
//

#import "DrawerWindow.h"

@interface HandleView : UIView
{
	DrawerWindow *_window;
	CGPoint _point;
	CGFloat _depth;
	BOOL _moved;
}
@end

@interface DrawerWindow ()
{
@public
	HandleView *_handleView;
}
- (void)memoryWarning:(NSNotification *)notification;
- (CGFloat)drawerDepthForOrientation:(UIInterfaceOrientation)orientation;
- (void)loadDrawer;
- (void)addDrawerHandle;
- (void)removeDrawerHandle;
@end

@implementation HandleView : UIView

- (id)initWithWindow:(DrawerWindow *)window
{
	if(self = [super initWithFrame:window.rootViewController.view.frame])
	{
		_window = window;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	_moved = NO;
	if([touch view] == self)
	{
		_point = [touch locationInView:self];
		_depth = [_window drawerDepthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint newpoint;
	CGFloat move;
	CGRect frame;
	
	_moved = YES;
	if([touch view] == self)
	{
		newpoint = [touch locationInView:self];
		move = newpoint.x - _point.x;
		frame = self.frame;
		if(frame.origin.x + move < 0.0f)
			frame.origin.x = 0.0f;
		else if(frame.origin.x + move > _depth)
			frame.origin.x = _depth;
		else
			frame.origin.x += move;
		self.frame = frame;
		_window.rootViewController.view.frame = frame;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if([touch view] == self)
	{
		if(!_moved)
		{
			// A tap, just close the drawer
			[_window closeDrawer:YES];
		}
		else
		{
			// Decide whether to finish opening or closing
			if(_window.rootViewController.view.frame.origin.x > _depth/2.0f)
			{
				[_window openDrawer:YES];
			}
			else
			{
				// This handle might have been used to close the drawer all the way, so make sure handle view has been removed
				if(![_window isOpen] && _window->_handleView)
					[_window removeDrawerHandle];
				else
					[_window closeDrawer:YES];
			}
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Canceled for some unknown reason, like low memory, just close it
	[_window closeDrawer:YES];
}

@end

@implementation DrawerWindow

- (void)setRootViewController:(UIViewController *)rootViewController
{
	if(self.rootViewController && [self isOpen])
	{
		rootViewController.view.frame = self.rootViewController.view.frame;
		[self insertSubview:rootViewController.view aboveSubview:self.rootViewController.view];
		[self.rootViewController.view removeFromSuperview];
		[super setRootViewController:rootViewController];
		[self closeDrawer:YES];
	}
	else
	{
		[super setRootViewController:rootViewController];
	}
}

#pragma mark - Internal methods

- (void)memoryWarning:(NSNotification *)notification
{
	if(![self isOpen] && _drawerViewController && _drawerViewController.isViewLoaded)
		[_drawerViewController.view removeFromSuperview];
}

- (CGFloat)drawerDepthForOrientation:(UIInterfaceOrientation)orientation
{
	if(_drawerDelegate && [_drawerDelegate respondsToSelector:@selector(drawerDepthForOrientation:)])
		return [_drawerDelegate drawerDepthForOrientation:orientation];
	else
		return DRAWER_DEFAULT_DEPTH;
}

#pragma mark - Memory management

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.drawerViewController = nil;
	[super dealloc];
}

#pragma mark - Drawer methods

- (BOOL)isOpen
{
	return (self.rootViewController.view.frame.origin.x != 0.0f);
}

- (void)openDrawer:(BOOL)animated
{
	if(_drawerViewController)
	{
		CGFloat depth;
		CGRect frame;

		// Test to make sure it isn't already wide open
		depth = [self drawerDepthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
		if((depth - self.rootViewController.view.frame.origin.x) <= FLT_EPSILON)
			return;
		// Setup the handle view and start the animation
		[self addDrawerHandle];
		if([_drawerViewController respondsToSelector:@selector(viewWillAppear:)])
			[_drawerViewController viewWillAppear:animated];
		frame = self.rootViewController.view.frame;
		frame.origin.x = depth;
		if(animated)
		{
			NSTimeInterval duration = [_drawerDelegate respondsToSelector:@selector(drawerAnimationDuration)]?[_drawerDelegate drawerAnimationDuration]:DRAWER_DEFAULT_ANIMATION_DURATION;
			// Scale back the duration if the drawer is currently open
			if(self.rootViewController.view.frame.origin.x != 0.0f)
				duration *= (depth - self.rootViewController.view.frame.origin.x) / depth;
			UIViewAnimationOptions options = [_drawerDelegate respondsToSelector:@selector(drawerAnimationOptions)]?[_drawerDelegate drawerAnimationOptions]:DRAWER_DEFAULT_ANIMATION_OPTIONS;
			[UIView animateWithDuration:duration delay:0.0 options:options
							 animations:^{ self.rootViewController.view.frame = frame; _handleView.frame = frame; } completion: ^(BOOL finished) {
				if([_drawerViewController respondsToSelector:@selector(viewDidAppear:)])
					[_drawerViewController viewDidAppear:animated];
				if(!finished)
				{
					// Opening was canceled
					if([_drawerViewController respondsToSelector:@selector(viewWillDisappear:)])
						[_drawerViewController viewWillDisappear:animated];
					if([_drawerViewController respondsToSelector:@selector(viewDidDisappear:)])
						[_drawerViewController viewDidDisappear:animated];
				}
			}];
		}
		else
		{
			self.rootViewController.view.frame = frame;
			_handleView.frame = frame;
			if([_drawerViewController respondsToSelector:@selector(viewDidAppear:)])
				[_drawerViewController viewDidAppear:animated];
		}
	}
}

- (void)closeDrawer:(BOOL)animated
{
	if(_drawerViewController)
	{
		CGRect frame;
		
		if(![self isOpen])
			return;
		if([_drawerViewController respondsToSelector:@selector(viewWillDisappear:)])
			[_drawerViewController viewWillDisappear:animated];
		frame = self.rootViewController.view.frame;
		frame.origin.x = 0.0f;
		if(animated)
		{
			NSTimeInterval duration = [_drawerDelegate respondsToSelector:@selector(drawerAnimationDuration)]?[_drawerDelegate drawerAnimationDuration]:DRAWER_DEFAULT_ANIMATION_DURATION;
			// Scale back the duration if the drawer is not all the way open
			CGFloat depth = [self drawerDepthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
			if((depth - self.rootViewController.view.frame.origin.x) > FLT_EPSILON)
				duration *= self.rootViewController.view.frame.origin.x / depth;
			UIViewAnimationOptions options = [_drawerDelegate respondsToSelector:@selector(drawerAnimationOptions)]?[_drawerDelegate drawerAnimationOptions]:DRAWER_DEFAULT_ANIMATION_OPTIONS;
			[UIView animateWithDuration:duration delay:0.0 options:options
							 animations:^{ self.rootViewController.view.frame = frame; _handleView.frame = frame; } completion: ^(BOOL finished) {
				if([_drawerViewController respondsToSelector:@selector(viewDidDisappear:)])
					[_drawerViewController viewDidDisappear:animated];
				if(!finished)
				{
					// Opening was canceled
					if([_drawerViewController respondsToSelector:@selector(viewWillAppear:)])
						[_drawerViewController viewWillAppear:animated];
					if([_drawerViewController respondsToSelector:@selector(viewDidAppear:)])
						[_drawerViewController viewDidAppear:animated];
				}
				else
				{
					[self removeDrawerHandle];
				}
			}];
		}
		else
		{
			self.rootViewController.view.frame = frame;
			_handleView.frame = frame;
			if([_drawerViewController respondsToSelector:@selector(viewDidDisappear:)])
				[_drawerViewController viewDidDisappear:animated];
			[self removeDrawerHandle];
		}
	}
}

- (void)loadDrawer
{
	if(_drawerViewController && !_drawerViewController.view.superview)
	{
		CGRect frame = self.rootViewController.view.frame;
		frame.origin.x = 0.0f;
		frame.size.width = [self drawerDepthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
		_drawerViewController.view.frame = frame;
		[self insertSubview:_drawerViewController.view atIndex:0];
	}
}

- (void)addDrawerHandle
{
	// Load the drawer
	[self loadDrawer];
	
	// Add a handle view
	if(!_handleView)
	{
		_handleView = [[HandleView alloc] initWithWindow:self];
		[self insertSubview:_handleView aboveSubview:self.rootViewController.view];
		[_handleView release];
	}
}

- (void)removeDrawerHandle
{
	if(![self isOpen])
	{
		// Unload the drawer
		if(_drawerViewController && _drawerViewController.view.superview)
			[_drawerViewController.view removeFromSuperview];
		
		// Remote the handle view
		if(_handleView)
		{
			[_handleView removeFromSuperview];
			_handleView = nil;
		}
	}
}

@end

@interface DrawerKnob()
{
	DrawerWindow *_window;
	CGPoint _point;
	CGFloat _depth;
	BOOL _moved;
}
@end

@implementation DrawerKnob

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];

	_moved = NO;
	if([touch view] == self)
	{
		self.highlighted = YES;
		_point = [touch locationInView:self];
		_window = (DrawerWindow *)self.window;
		_depth = [_window drawerDepthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint newpoint;
	CGFloat move;
	CGRect frame;

	_moved = YES;
	self.highlighted = NO;
	if([touch view] == self)
	{
		// Before any movement can be made, be sure the drawer is loaded
		[_window loadDrawer];
		newpoint = [touch locationInView:self];
		move = newpoint.x - _point.x;
		frame = _window.rootViewController.view.frame;
		if(frame.origin.x + move < 0.0f)
			frame.origin.x = 0.0f;
		else if(frame.origin.x + move > _depth)
			frame.origin.x = _depth;
		else
			frame.origin.x += move;
		_window.rootViewController.view.frame = frame;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	self.highlighted = NO;
	if([touch view] == self)
	{
		if(!_moved)
		{
			// A tap, just open the drawer
			[_window openDrawer:YES];
		}
		else
		{
			// Decide whether to finish opening or closing
			if(_window.rootViewController.view.frame.origin.x > _depth/2.0f)
			{
				[_window openDrawer:YES];
				// This knob might have been used to open the drawer all the way, so make sure handle view has been added
				if(!_window->_handleView)
					[_window addDrawerHandle];
			}
			else
			{
				[_window closeDrawer:YES];
			}
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Canceled for some unknown reason, like low memory, just close it
	self.highlighted = NO;
	[_window closeDrawer:YES];
}

+ (instancetype)drawerKnob
{
	DrawerKnob *knob = [DrawerKnob buttonWithType:UIButtonTypeCustom];
	return knob;
}

@end
