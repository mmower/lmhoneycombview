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

- (id)initWithColumn:(int)_col row:(int)_row {
  return [self initWithColumn:_col row:_row data:nil];
}

- (id)initWithColumn:(int)_col row:(int)_row data:(id)_data {
  if( self = [super init] ) {
    path          = nil;
    col           = _col;
    row           = _row;
    data          = _data;
    selected      = NO;
  }
  
  return self;
}

- (NSBezierPath *)path {
  return path;
}

- (void)setHexCentre:(NSPoint)_centre radius:(CGFloat)_radius {
  centre = _centre;
  radius = _radius;
  
  path = [NSBezierPath bezierPath];
  [path appendHexagonWithCentre:_centre radius:_radius];
}

- (NSPoint)centre {
  return centre;
}

- (CGFloat)radius {
  return radius;
}

- (int)column {
  return col;
}

- (int)row {
  return row;
}

- (BOOL)selected {
  return selected;
}

- (void)setSelected:(BOOL)_selected {
  selected = _selected;
}

- (id)data {
  return data;
}

- (void)setData:(id)_data {
  data = _data;
}

- (void)drawOnHoneycombView:(LMHoneycombView *)_view withAttributes:(NSMutableDictionary *)_attributes {
  if( selected ) {
    [[_attributes objectForKey:LMHoneycombViewSelectedColor] set];
  } else {
    [[_attributes objectForKey:LMHoneycombViewDefaultColor] set];
  }
  [path fill];
  
  [[_attributes objectForKey:LMHoneycombViewBorderColor] set];
  [path setLineWidth:[[_attributes objectForKey:LMHoneycombViewBorderWidth] floatValue]];
  [path stroke];
}

@end
