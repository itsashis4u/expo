//
//  ABI28_0_0AIRGoogleMapManager.m
//  AirMaps
//
//  Created by Gil Birman on 9/1/16.
//


#import "ABI28_0_0AIRGoogleMapManager.h"
#import <ReactABI28_0_0/ABI28_0_0RCTViewManager.h>
#import <ReactABI28_0_0/ABI28_0_0RCTBridge.h>
#import <ReactABI28_0_0/ABI28_0_0RCTUIManager.h>
#import <ReactABI28_0_0/ABI28_0_0RCTConvert+CoreLocation.h>
#import <ReactABI28_0_0/ABI28_0_0RCTEventDispatcher.h>
#import <ReactABI28_0_0/ABI28_0_0RCTViewManager.h>
#import <ReactABI28_0_0/ABI28_0_0RCTConvert.h>
#import <ReactABI28_0_0/UIView+ReactABI28_0_0.h>
#import "ABI28_0_0RCTConvert+GMSMapViewType.h"
#import "ABI28_0_0AIRGoogleMap.h"
#import "ABI28_0_0AIRMapMarker.h"
#import "ABI28_0_0AIRMapPolyline.h"
#import "ABI28_0_0AIRMapPolygon.h"
#import "ABI28_0_0AIRMapCircle.h"
#import "ABI28_0_0SMCalloutView.h"
#import "ABI28_0_0AIRGoogleMapMarker.h"
#import "ABI28_0_0RCTConvert+AirMap.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

static NSString *const ABI28_0_0RCTMapViewKey = @"MapView";


@interface ABI28_0_0AIRGoogleMapManager() <GMSMapViewDelegate>

@end

@implementation ABI28_0_0AIRGoogleMapManager

ABI28_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  ABI28_0_0AIRGoogleMap *map = [ABI28_0_0AIRGoogleMap new];
  map.bridge = self.bridge;
  map.delegate = self;
  return map;
}

ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(initialRegion, MKCoordinateRegion)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(region, MKCoordinateRegion)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsBuildings, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsCompass, BOOL)
//ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsScale, BOOL)  // Not supported by GoogleMaps
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsTraffic, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(rotateEnabled, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(pitchEnabled, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsUserLocation, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsMyLocationButton, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(showsIndoorLevelPicker, BOOL)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(customMapStyleString, NSString)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(mapPadding, UIEdgeInsets)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onMapReady, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onKmlReady, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onPress, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onLongPress, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onUserLocationChange, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onChange, ABI28_0_0RCTBubblingEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onMarkerPress, ABI28_0_0RCTDirectEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onRegionChange, ABI28_0_0RCTDirectEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onRegionChangeComplete, ABI28_0_0RCTDirectEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(onPoiClick, ABI28_0_0RCTDirectEventBlock)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(mapType, GMSMapViewType)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(minZoomLevel, CGFloat)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(maxZoomLevel, CGFloat)
ABI28_0_0RCT_EXPORT_VIEW_PROPERTY(kmlSrc, NSString)

ABI28_0_0RCT_EXPORT_METHOD(animateToRegion:(nonnull NSNumber *)ReactABI28_0_0Tag
                  withRegion:(MKCoordinateRegion)region
                  withDuration:(CGFloat)duration)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      // Core Animation must be used to control the animation's duration
      // See http://stackoverflow.com/a/15663039/171744
      [CATransaction begin];
      [CATransaction setAnimationDuration:duration/1000];
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;
      GMSCameraPosition *camera = [ABI28_0_0AIRGoogleMap makeGMSCameraPositionFromMap:mapView andMKCoordinateRegion:region];
      [mapView animateToCameraPosition:camera];
      [CATransaction commit];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(animateToCoordinate:(nonnull NSNumber *)ReactABI28_0_0Tag
                  withRegion:(CLLocationCoordinate2D)latlng
                  withDuration:(CGFloat)duration)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      [CATransaction begin];
      [CATransaction setAnimationDuration:duration/1000];
      [(ABI28_0_0AIRGoogleMap *)view animateToLocation:latlng];
      [CATransaction commit];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(animateToViewingAngle:(nonnull NSNumber *)ReactABI28_0_0Tag
                  withAngle:(double)angle
                  withDuration:(CGFloat)duration)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      [CATransaction begin];
      [CATransaction setAnimationDuration:duration/1000];
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;
      [mapView animateToViewingAngle:angle];
      [CATransaction commit];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(animateToBearing:(nonnull NSNumber *)ReactABI28_0_0Tag
                  withBearing:(CGFloat)bearing
                  withDuration:(CGFloat)duration)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      [CATransaction begin];
      [CATransaction setAnimationDuration:duration/1000];
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;
      [mapView animateToBearing:bearing];
      [CATransaction commit];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(fitToElements:(nonnull NSNumber *)ReactABI28_0_0Tag
                  animated:(BOOL)animated)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      CLLocationCoordinate2D myLocation = ((ABI28_0_0AIRGoogleMapMarker *)(mapView.markers.firstObject)).realMarker.position;
      GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];

      for (ABI28_0_0AIRGoogleMapMarker *marker in mapView.markers)
        bounds = [bounds includingCoordinate:marker.realMarker.position];

      [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:55.0f]];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(fitToSuppliedMarkers:(nonnull NSNumber *)ReactABI28_0_0Tag
                  markers:(nonnull NSArray *)markers
                  animated:(BOOL)animated)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      NSPredicate *filterMarkers = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        ABI28_0_0AIRGoogleMapMarker *marker = (ABI28_0_0AIRGoogleMapMarker *)evaluatedObject;
        return [marker isKindOfClass:[ABI28_0_0AIRGoogleMapMarker class]] && [markers containsObject:marker.identifier];
      }];

      NSArray *filteredMarkers = [mapView.markers filteredArrayUsingPredicate:filterMarkers];

      CLLocationCoordinate2D myLocation = ((ABI28_0_0AIRGoogleMapMarker *)(filteredMarkers.firstObject)).realMarker.position;
      GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];

      for (ABI28_0_0AIRGoogleMapMarker *marker in filteredMarkers)
        bounds = [bounds includingCoordinate:marker.realMarker.position];

      [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:55.0f]];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(fitToCoordinates:(nonnull NSNumber *)ReactABI28_0_0Tag
                  coordinates:(nonnull NSArray<ABI28_0_0AIRMapCoordinate *> *)coordinates
                  edgePadding:(nonnull NSDictionary *)edgePadding
                  animated:(BOOL)animated)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      CLLocationCoordinate2D myLocation = coordinates.firstObject.coordinate;
      GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];

      for (ABI28_0_0AIRMapCoordinate *coordinate in coordinates)
        bounds = [bounds includingCoordinate:coordinate.coordinate];

      // Set Map viewport
      CGFloat top = [ABI28_0_0RCTConvert CGFloat:edgePadding[@"top"]];
      CGFloat right = [ABI28_0_0RCTConvert CGFloat:edgePadding[@"right"]];
      CGFloat bottom = [ABI28_0_0RCTConvert CGFloat:edgePadding[@"bottom"]];
      CGFloat left = [ABI28_0_0RCTConvert CGFloat:edgePadding[@"left"]];

      [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)]];
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(takeSnapshot:(nonnull NSNumber *)ReactABI28_0_0Tag
                  withWidth:(nonnull NSNumber *)width
                  withHeight:(nonnull NSNumber *)height
                  withRegion:(MKCoordinateRegion)region
                  format:(nonnull NSString *)format
                  quality:(nonnull NSNumber *)quality
                  result:(nonnull NSString *)result
                  withCallback:(ABI28_0_0RCTResponseSenderBlock)callback)
{
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  NSString *pathComponent = [NSString stringWithFormat:@"Documents/snapshot-%.20lf.%@", timeStamp, format];
  NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent: pathComponent];

  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
        ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      // TODO: currently we are ignoring width, height, region

      UIGraphicsBeginImageContextWithOptions(mapView.frame.size, YES, 0.0f);
      [mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

      NSData *data;
      if ([format isEqualToString:@"png"]) {
          data = UIImagePNGRepresentation(image);

      }
      else if([format isEqualToString:@"jpg"]) {
            data = UIImageJPEGRepresentation(image, quality.floatValue);
      }

      if ([result isEqualToString:@"file"]) {
          [data writeToFile:filePath atomically:YES];
            callback(@[[NSNull null], filePath]);
        }
        else if ([result isEqualToString:@"base64"]) {
            callback(@[[NSNull null], [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]]);
        }
        else if ([result isEqualToString:@"legacy"]) {

            // In the initial (iOS only) implementation of takeSnapshot,
            // both the uri and the base64 encoded string were returned.
            // Returning both is rarely useful and in fact causes a
            // performance penalty when only the file URI is desired.
            // In that case the base64 encoded string was always marshalled
            // over the JS-bridge (which is quite slow).
            // A new more flexible API was created to cover this.
            // This code should be removed in a future release when the
            // old API is fully deprecated.
            [data writeToFile:filePath atomically:YES];
            NSDictionary *snapshotData = @{
                                           @"uri": filePath,
                                           @"data": [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]
                                           };
            callback(@[[NSNull null], snapshotData]);
        }

    }
    UIGraphicsEndImageContext();
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(pointForCoordinate:(nonnull NSNumber *)ReactABI28_0_0Tag
                  coordinate:(NSDictionary *)coordinate
                  withCallback:(ABI28_0_0RCTResponseSenderBlock)callback)
{
  CLLocationCoordinate2D coord =
  CLLocationCoordinate2DMake(
                             [coordinate[@"latitude"] doubleValue],
                             [coordinate[@"longitude"] doubleValue]
                             );

  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      CGPoint touchPoint = [mapView.projection pointForCoordinate:coord];

      callback(@[[NSNull null], @{
                   @"x": @(touchPoint.x),
                   @"y": @(touchPoint.y),
                   }]);
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(coordinateForPoint:(nonnull NSNumber *)ReactABI28_0_0Tag
                  point:(NSDictionary *)point
                  withCallback:(ABI28_0_0RCTResponseSenderBlock)callback)
{
  CGPoint pt = CGPointMake(
                           [point[@"x"] doubleValue],
                           [point[@"y"] doubleValue]
                           );

  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      CLLocationCoordinate2D coordinate = [mapView.projection coordinateForPoint:pt];

      callback(@[[NSNull null], @{
                @"latitude": @(coordinate.latitude),
                @"longitude": @(coordinate.longitude),
                }]);
    }
  }];
}

ABI28_0_0RCT_EXPORT_METHOD(setMapBoundaries:(nonnull NSNumber *)ReactABI28_0_0Tag
                  northEast:(CLLocationCoordinate2D)northEast
                  southWest:(CLLocationCoordinate2D)southWest)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI28_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI28_0_0Tag];
    if (![view isKindOfClass:[ABI28_0_0AIRGoogleMap class]]) {
      ABI28_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI28_0_0AIRGoogleMap, got: %@", view);
    } else {
      ABI28_0_0AIRGoogleMap *mapView = (ABI28_0_0AIRGoogleMap *)view;

      GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];

      mapView.cameraTargetBounds = bounds;
    }
  }];
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (NSDictionary *)constantsToExport {
  return @{ @"legalNotice": [GMSServices openSourceLicenseInfo] };
}

- (void)mapViewDidStartTileRendering:(GMSMapView *)mapView {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView didPrepareMap];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  return [googleMapView didTapMarker:marker];
}

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSPolygon *)polygon {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView didTapPolygon:polygon];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView didTapAtCoordinate:coordinate];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView didLongPressAtCoordinate:coordinate];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView didChangeCameraPosition:position];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
  ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
  [googleMapView idleAtCameraPosition:position];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  return [aMarker.fakeMarker markerInfoWindow];}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  return [aMarker.fakeMarker markerInfoContents];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  [aMarker.fakeMarker didTapInfoWindowOfMarker:aMarker];
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  [aMarker.fakeMarker didBeginDraggingMarker:aMarker];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  [aMarker.fakeMarker didEndDraggingMarker:aMarker];
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
  ABI28_0_0AIRGMSMarker *aMarker = (ABI28_0_0AIRGMSMarker *)marker;
  [aMarker.fakeMarker didDragMarker:aMarker];
}

- (void)mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
    ABI28_0_0AIRGoogleMap *googleMapView = (ABI28_0_0AIRGoogleMap *)mapView;
    [googleMapView didTapPOIWithPlaceID:placeID name:name location:location];
}
@end
