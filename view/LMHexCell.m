//
//  LMHexCell.m
//  Elysium
//
//  Created by Matt Mower on 29/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "LMHexCell.h"

#import "LMHoneycombView.h"

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
    // NSLog( @"Cell %@ initial selected state = %@", self, selected ? @"YES" : @"NO" );
  }
  
  return self;
}

- (NSBezierPath *)path {
  return path;
}

- (void)setPath:(NSBezierPath *)_path {
  path = _path;
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
  // NSLog( @"Cell %@ selected = %@", self, _selected ? @"YES" : @"NO" );
  selected = _selected;
}

- (id)data {
  return data;
}

- (void)setData:(id)_data {
  data = _data;
}

- (void)drawOnHoneycombView:(LMHoneycombView *)_view {
  // NSLog( @"Cell %@ %@ selected", self, selected ? @"is" : @"is not" );
  
  if( selected ) {
    [[_view selectedColor] set];
  } else {
    [[_view defaultColor] set];
  }
  [path fill];
  
  [[_view borderColor] set];
  [path setLineWidth:[_view borderWidth]];
  [path stroke];
}

@end
