//
//  SingleLocationMapView.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "SingleLocationMapView.h"

#define SINGLELOCATIONMAP_SPAN 0.005f

// Another annotation class to not cause a circular retain
@interface SingleLocationMapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;

@end

@implementation SingleLocationMapViewAnnotation

@synthesize coordinate;
@synthesize title;

- (void)dealloc
{
	self.title = nil;
	[super dealloc];
}

@end

@interface SingleLocationMapView ()

@property (nonatomic, retain) SingleLocationMapViewAnnotation *annotation;

@end

@implementation SingleLocationMapView

@synthesize annotation;
@synthesize coordinate;
@synthesize title;
@synthesize annotationView;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		self.delegate = self;
		self.annotation = [[[SingleLocationMapViewAnnotation alloc] init] autorelease];
		self.annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
		annotationView.canShowCallout = YES;
		[(MKPinAnnotationView *)annotationView setPinColor:MKPinAnnotationColorGreen];
		[(MKPinAnnotationView *)annotationView setAnimatesDrop:YES];
	}
	return self;
}

- (void)dealloc
{
	self.annotation = nil;
	self.title = nil;
	self.annotationView = nil;
	[super dealloc];
}

- (CLLocationCoordinate2D)coordinate
{
	if(annotation)
		return annotation.coordinate;
	return kCLLocationCoordinate2DInvalid;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	if(annotation)
	{
		annotation.coordinate = newCoordinate;
		[self removeAnnotation:annotation];
		[self addAnnotation:annotation];
		self.region = MKCoordinateRegionMake(newCoordinate, MKCoordinateSpanMake(SINGLELOCATIONMAP_SPAN, SINGLELOCATIONMAP_SPAN));
	}
}

- (NSString *)title
{
	if(annotation)
		return annotation.title;
	return nil;
}

- (void)setTitle:(NSString *)newTitle
{
	if(annotation)
	{
		annotation.title = newTitle;
		[self removeAnnotation:annotation];
		[self addAnnotation:annotation];
	}
}

- (void)reset
{
	if(annotation)
		self.region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(SINGLELOCATIONMAP_SPAN, SINGLELOCATIONMAP_SPAN));
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)mapAnnotation
{
	if(mapAnnotation == self.userLocation)
		return nil;
	return annotationView;
}

@end
