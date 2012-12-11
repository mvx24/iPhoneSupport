//
//  ImageCache.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "ImageCache.h"

#define IMAGES_DIRECTORY	@"images"

static id sharedInstance;

@interface ImageCache ()

@property (nonatomic, retain) NSMutableDictionary *connections;

- (void)applicationWillTerminate:(NSNotification *)notification;
- (UIImage *)loadFromDisk:(NSString *)key;
- (void)saveToDisk:(UIImage *)image withKey:(NSString *)key;
- (void)removeFromDisk:(NSString *)key;
- (void)flushExpiredTask;

@end

@interface ImageRequest : NSObject <NSURLConnectionDelegate>
{
@public
	UIImageView *imageView;
	ImageCache *cache;
	NSString *key;
	NSMutableData *requestData;
	NSURLConnection *requestConnection;
}

@property (nonatomic, copy) void (^completion)(NSString *);

+ (ImageRequest *)requestWithImageView:(UIImageView *)theImageView cache:(ImageCache *)theCache url:(NSString *)theUrl key:(NSString *)theKey completion:(void (^)(NSString *errorMessage))completion;

@end

@implementation ImageRequest

@synthesize completion;

+ (ImageRequest *)requestWithImageView:(UIImageView *)theImageView cache:(ImageCache *)theCache url:(NSString *)theUrl key:(NSString *)theKey completion:(void (^)(NSString *errorMessage))completion
{
	NSURL *requestURL;
	NSMutableURLRequest *requestWithURL;
	ImageRequest *request;
	
	request = [[[ImageRequest alloc] init] autorelease];
	request.completion = completion;
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

- (void)dealloc
{
	self.completion = nil;
	[requestConnection cancel];
	[requestData release];
	[key release];
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
	
	if(self.completion)
		self.completion([error localizedDescription]);
	
	// Remove self from the connections
	[cache.connections removeObjectForKey:[NSValue valueWithPointer:imageView]];
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
		[cache cacheImage:image withKey:key];
		imageView.image = [cache imageForKey:key];
		if(self.completion)
			self.completion(nil);
	}
	else
	{
		// Load the failed image if provided
		if(self.completion)
			self.completion(@"Bad image");
	}
	
	// Remove self from the connections
	[cache.connections removeObjectForKey:[NSValue valueWithPointer:imageView]];
}

@end

@implementation ImageCache

@synthesize expirationInterval;
@synthesize connections;

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

- (UIImage *)loadFromDisk:(NSString *)key
{
	NSArray *dirPaths;
	NSString *path;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/%@.jpg", [dirPaths objectAtIndex:0], IMAGES_DIRECTORY, key];
	if(expirationInterval != 0.0)
	{
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
		if(-[[attributes fileCreationDate] timeIntervalSinceNow] > expirationInterval)
		{
			[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
			return nil;
		}
	}
	return [UIImage imageWithContentsOfFile:path];
}

- (void)saveToDisk:(UIImage *)image withKey:(NSString *)key
{
	NSArray *dirPaths;
	NSString *cachePath, *path;
	NSData *jpegData;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	cachePath = [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0], IMAGES_DIRECTORY];
	[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
	path = [NSString stringWithFormat:@"%@/%@.jpg", cachePath, key];
	jpegData = UIImageJPEGRepresentation(image, 0.5);
	[jpegData writeToFile:path atomically:NO];
}

- (void)removeFromDisk:(NSString *)key
{
	NSArray *dirPaths;
	NSString *path;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/%@.jpg", [dirPaths objectAtIndex:0], IMAGES_DIRECTORY, key];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)flushExpiredTask
{
	@autoreleasepool {
		[self flushExpired];
	}
}

- (void)setExpirationInterval:(NSTimeInterval)newExpirationInterval
{
	if(expirationInterval != newExpirationInterval)
	{
		expirationInterval = newExpirationInterval;
		if(expirationInterval != 0.0)
			[NSThread detachNewThreadSelector:@selector(flushExpiredTask) toTarget:self withObject:nil];
	}
}

#pragma mark - External methods

+ (id)sharedCache
{
	if(sharedInstance == nil)
	{
		sharedInstance = [[ImageCache alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
	}
	return (ImageCache *)sharedInstance;
}

- (void)cacheImage:(UIImage *)image withKey:(NSString *)key
{
	if(!image)
		return;
	[self saveToDisk:image withKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
	if(!key)
		return nil;
	return [self loadFromDisk:key];
}

- (void)removeImageForKey:(NSString *)key
{
	if(!key)
		return;
	[self removeFromDisk:key];
}

- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(NSString *)key
{
	[self loadImageView:imageView withUrl:url withKey:key completion:nil];
}

- (void)loadImageView:(UIImageView *)imageView withUrl:(NSString *)url withKey:(NSString *)key completion:(void (^)(NSString *errorMessage))completion
{
	UIImage *image;
	ImageRequest *request;
	NSValue *imageViewKey;
	
	if(!imageView || !url || !key)
		return;
	
	if((image = [self imageForKey:key]))
	{
		imageView.image = image;
		if(completion)
			completion(nil);
	}
	else
	{
		if(!self.connections)
			self.connections = [NSMutableDictionary dictionaryWithCapacity:8];
		imageViewKey = [NSValue valueWithPointer:imageView];
		request = [self.connections objectForKey:imageViewKey];
		// Check to make sure it's a new request or overriding an existing request
		if(!request || ![request->key isEqualToString:key])
		{
			// Cancel the current request and overwrite it with a new one
			if(request)
				[request->requestConnection cancel];
			request = [ImageRequest requestWithImageView:imageView cache:self url:url key:key completion:completion];
			[self.connections setObject:request forKey:imageViewKey];
		}
	}
}

- (void)flushDisk
{
	NSArray *dirPaths;
	NSString *path;
	NSFileManager *fileManager;
	NSDirectoryEnumerator *enumerator;
	NSString *file;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/", [dirPaths objectAtIndex:0], IMAGES_DIRECTORY];
	fileManager = [NSFileManager defaultManager];
	enumerator = [fileManager enumeratorAtPath:path];
	while(file = [enumerator nextObject])
		[fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:NULL];
}

- (void)flushExpired
{
	NSArray *dirPaths;
	NSString *path;
	NSFileManager *fileManager;
	NSDirectoryEnumerator *enumerator;
	NSString *file;
	NSDictionary *attributes;
	
	if(expirationInterval == 0.0)
		return;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	path = [NSString stringWithFormat:@"%@/%@/", [dirPaths objectAtIndex:0], IMAGES_DIRECTORY];
	fileManager = [NSFileManager defaultManager];
	enumerator = [fileManager enumeratorAtPath:path];
	while(file = [enumerator nextObject])
	{
		attributes = [fileManager attributesOfItemAtPath:path error:NULL];
		if(-[[attributes fileCreationDate] timeIntervalSinceNow] > expirationInterval)
			[fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:NULL];
	}
}

@end
