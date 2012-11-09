//
//  ThumbnailCache.m
//
//  Created by Marc Angelone on 5/1/12.
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "ThumbnailCache.h"
#import "UIImage+Normal.h"

#define SIZE_THUMBNAIL		50.0
#define THUMBNAIL_DIRECTORY	@"thumbnails"

static id sharedInstance;

@interface ThumbnailCache ()

@property (nonatomic, retain) NSMutableDictionary *cache;
@property (nonatomic, retain) NSMutableDictionary *connections;

- (UIImage *)loadFromDisk:(id)key;
- (void)saveToDisk:(UIImage *)image withKey:(id)key;

@end

@interface ThumbnailRequest : NSObject <NSURLConnectionDelegate>
{
@public
	UIImageView *imageView;
	UIButton *button;
	ThumbnailCache *cache;
	id key;
	NSMutableData *requestData;
	NSURLConnection *requestConnection;
}

+ (ThumbnailRequest *)requestWithImageView:(UIImageView *)theImageView cache:(ThumbnailCache *)theCache url:(NSString *)theUrl key:(id)theKey;
+ (ThumbnailRequest *)requestWithButton:(UIButton *)theButton cache:(ThumbnailCache *)theCache url:(NSString *)theUrl key:(id)theKey;

@end

@implementation ThumbnailRequest

+ (ThumbnailRequest *)requestWithImageView:(UIImageView *)theImageView cache:(ThumbnailCache *)theCache url:(NSString *)theUrl key:(id)theKey
{
	NSURL *requestURL;
	NSMutableURLRequest *requestWithURL;
	ThumbnailRequest *request;
	
	request = [[[ThumbnailRequest alloc] init] autorelease];
	requestURL = [NSURL URLWithString:theUrl];
	requestWithURL = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
	request->requestConnection = [NSURLConnection connectionWithRequest:requestWithURL delegate:request];
	if(request->requestConnection != nil)
	{
		request->requestData = [[NSMutableData data] retain];
		request->imageView = [theImageView retain];
		request->cache = theCache;
		request->key = [theKey retain];
		return request;
	}
	else
	{
		[request connection:nil didFailWithError:nil];
	}
	return nil;
}

+ (ThumbnailRequest *)requestWithButton:(UIButton *)theButton cache:(ThumbnailCache *)theCache url:(NSString *)theUrl key:(id)theKey
{
	NSURL *requestURL;
	NSMutableURLRequest *requestWithURL;
	ThumbnailRequest *request;
	
	request = [[[ThumbnailRequest alloc] init] autorelease];
	requestURL = [NSURL URLWithString:theUrl];
	requestWithURL = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
	request->requestConnection = [NSURLConnection connectionWithRequest:requestWithURL delegate:request];
	if(request->requestConnection != nil)
	{
		request->requestData = [[NSMutableData data] retain];
		request->button = [theButton retain];
		request->cache = theCache;
		request->key = [theKey retain];
		return request;
	}
	else
	{
		[request connection:nil didFailWithError:nil];
	}
	return nil;
}

- (void)dealloc
{
	[requestConnection cancel];
	[requestData release];
	[key release];
	[button release];
	[imageView release];
	[super dealloc];
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	[requestData setLength:0];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	[requestData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)theConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	return request;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	// Cleanup
	[requestData release];
	requestData = nil;
	requestConnection = nil;

	// Load the failed image if provided
	if(cache.failedImageName)
	{
		if(imageView)
			imageView.image = [UIImage imageNamed:cache.failedImageName];
		else if(button)
			[button setImage:[UIImage imageNamed:cache.failedImageName] forState:UIControlStateNormal];
	}
	
	// Remove self from the connections
	if(imageView)
		[cache.connections removeObjectForKey:[NSValue valueWithPointer:imageView]];
	else if(button)
		[cache.connections removeObjectForKey:[NSValue valueWithPointer:button]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	UIImage *image;
	
	image = [UIImage imageWithData:requestData];
	
	// Cleanup
	[requestData release];
	requestData = nil;
	requestConnection = nil;
	
	if(image)
	{
		[cache cacheThumbnailForImage:image withKey:key];
		if(imageView)
			imageView.image = [cache thumbnailForKey:key];
		else if(button)
			[button setImage:[cache thumbnailForKey:key] forState:UIControlStateNormal];
	}
	else
	{
		// Load the failed image if provided
		if(cache.failedImageName)
		{
			if(imageView)
				imageView.image = [UIImage imageNamed:cache.failedImageName];
			else if(button)
				[button setImage:[UIImage imageNamed:cache.failedImageName] forState:UIControlStateNormal];
		}
	}
	
	// Remove self from the connections
	if(imageView)
		[cache.connections removeObjectForKey:[NSValue valueWithPointer:imageView]];
	else if(button)
		[cache.connections removeObjectForKey:[NSValue valueWithPointer:button]];
}

@end

@implementation ThumbnailCache

@synthesize expirationInterval;
@synthesize failedImageName;
@synthesize cache;
@synthesize connections;

+ (void)initialize
{
	if(sharedInstance == nil)
	{
		sharedInstance = [[ThumbnailCache alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
}

- (void)memoryWarning:(NSNotification *)notification
{
	[self flushMemory];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

- (void)dealloc
{
	self.failedImageName = nil;
	self.cache = nil;
	[super dealloc];
}

+ (id)sharedCache
{
	return (ThumbnailCache *)sharedInstance;
}

- (void)setExpirationInterval:(NSTimeInterval)newExpirationInterval
{
	if(expirationInterval != newExpirationInterval)
	{
		expirationInterval = newExpirationInterval;
		// TODO: Check all cached thumbnail timestamps
	}
}

- (UIImage *)loadFromDisk:(id)key
{
	NSArray *dirPaths;
	NSString *path;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/%d.jpg", [dirPaths objectAtIndex:0], THUMBNAIL_DIRECTORY, [key hash]];
	return [UIImage imageWithContentsOfFile:path];
}

- (void)saveToDisk:(UIImage *)image withKey:(id)key
{
	NSArray *dirPaths;
	NSString *cachePath, *path;
	NSData *jpegData;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	cachePath = [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0], THUMBNAIL_DIRECTORY];
	[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
	path = [NSString stringWithFormat:@"%@/%d.jpg", cachePath, [key hash]];
	jpegData = UIImageJPEGRepresentation(image, 0.5);
	[jpegData writeToFile:path atomically:NO];
}

- (void)cacheThumbnailForImage:(UIImage *)image withKey:(id)key
{
	UIImage *squaredImage, *thumbnail;
	CGFloat size;
	UIScreen *screen;
	
	if(image == nil)
		return;
	
	if(self.cache == nil)
		self.cache = [NSMutableDictionary dictionaryWithCapacity:32];
	
	// Convert the image to a thumbnail
	squaredImage = [image squareImage];
	size = SIZE_THUMBNAIL;
	screen = [UIScreen mainScreen];
	if([screen respondsToSelector:@selector(scale)])
		size *= [screen scale];
	thumbnail = [squaredImage thumbnailImage:size];
	[self.cache setObject:thumbnail forKey:key];
	[self saveToDisk:thumbnail withKey:key];
}

- (UIImage *)thumbnailForKey:(id)key
{
	UIImage *image = nil;
	
	if(!(image = [self.cache objectForKey:key]))
	{
		// Check the disk for the thumbnail
		if((image = [self loadFromDisk:key]))
			[self.cache setObject:image forKey:key];
	}
	return image;
}

- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(id)key
{
	UIImage *image;
	ThumbnailRequest *request;
	NSValue *imageViewKey;
	
	if((image = [self thumbnailForKey:key]))
	{
		imageView.image = image;
	}
	else
	{
		if(!self.connections)
			self.connections = [NSMutableDictionary dictionaryWithCapacity:8];
		imageViewKey = [NSValue valueWithPointer:imageView];
		request = [self.connections objectForKey:imageViewKey];
		// Check to make sure it's a new request or overriding an existing request
		if(!request || ![request->key isEqual:key])
		{
			request = [ThumbnailRequest requestWithImageView:imageView cache:self url:url key:key];
			if(request)
				[self.connections setObject:request forKey:imageViewKey];
			else if((image = [UIImage imageNamed:self.failedImageName]))
				imageView.image = image;
		}
	}
}

- (void)loadButton:(UIButton *)button withUrl:(NSString *)url withKey:(id)key
{
	UIImage *image;
	ThumbnailRequest *request;
	NSValue *buttonKey;
	
	if((image = [self thumbnailForKey:key]))
	{
		[button setImage:image forState:UIControlStateNormal];
	}
	else
	{
		if(!self.connections)
			self.connections = [NSMutableDictionary dictionaryWithCapacity:8];
		buttonKey = [NSValue valueWithPointer:button];
		request = [self.connections objectForKey:buttonKey];
		// Check to make sure it's a new request or overriding an existing request
		if(!request || ![request->key isEqual:key])
		{
			request = [ThumbnailRequest requestWithButton:button cache:self url:url key:key];
			if(request)
				[self.connections setObject:request forKey:buttonKey];
			else if((image = [UIImage imageNamed:self.failedImageName]))
				[button setImage:image forState:UIControlStateNormal];
		}
	}
}

- (void)flushMemory
{
	self.cache = nil;
}

- (void)flushDisk
{
	NSArray *dirPaths;
	NSString *path;
	NSFileManager *fileManager;
	NSDirectoryEnumerator *enumerator;
	NSString *file;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/", [dirPaths objectAtIndex:0], THUMBNAIL_DIRECTORY];
	fileManager = [NSFileManager defaultManager];
	enumerator = [fileManager enumeratorAtPath:path];
	while(file = [enumerator nextObject])
		[fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:NULL];
}

@end
