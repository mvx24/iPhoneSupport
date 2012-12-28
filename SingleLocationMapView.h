//
//  SingleLocationMapView.h
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SingleLocationMapView : MKMapView <MKAnnotation, MKMapViewDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
// Optionally: provide a title, override/customize annotationview
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) MKAnnotationView *annotationView;

- (void)reset;

@end
