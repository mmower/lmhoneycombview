//
//  LMHexCell.m
//  Elysium
//
//  Created by Matt Mower on 29/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <HoneycombView/LMHexCell.h>

#import <HoneycombView/LMHoneycombView.h>

#import "LMRegularPolygon.h"

@implementation LMHexCell

#pragma mark Initializers

- (id)initWithColumn:(int)col row:(int)row {
  return [self initWithColumn:col row:row data:nil];
}

- (id)initWithColumn:(int)col row:(int)row data:(id)data {
  if( self = [super init] ) {
    mPath     = nil;
    mCol      = col;
    mRow      = row;
    mData     = data;
    mSelected = NO;
    mDirty    = YES;
  }
  
  return self;
}

#pragma mark Properties

@synthesize mCentre;
@synthesize mRadius;
@synthesize mPath;
@synthesize mCol;
@synthesize mRow;
@synthesize mData;
@synthesize mSelected;

- (void)setSelected:(BOOL)selected {
  mSelected = selected;
  [self setDirty:YES];
}

@synthesize mDirty;

- (void)setHexCentre:(NSPoint)centre radius:(CGFloat)radius {
  mCentre = centre;
  mRadius = radius;
  
  mPath = [NSBezierPath bezierPath];
  [mPath appendHexagonWithCentre:centre radius:radius];
  [self setDirty:YES];
}


- (void)drawOnHoneycombView:(LMHoneycombView *)view withAttributes:(NSMutableDictionary *)attributes {
  if( [self selected] ) {
    [[attributes objectForKey:LMHoneycombViewSelectedColor] set];
  } else {
    [[attributes objectForKey:LMHoneycombViewDefaultColor] set];
  }
  [[self path] fill];
  
  if( [self selected] ) {
    [[attributes objectForKey:LMHoneycombViewSelectedBorderColor] set];
  } else {
    [[attributes objectForKey:LMHoneycombViewBorderColor] set];
  }
  
  [[self path] setLineWidth:[[attributes objectForKey:LMHoneycombViewBorderWidth] floatValue]];
  [[self path] stroke];
  
  [self setDirty:NO];
}


- (NSMenu *)contextMenu {
  return nil;
}


@end
