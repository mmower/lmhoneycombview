//
//  LMHoneycombView.m
//  Elysium
//
//  Created by Matt Mower on 29/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "HoneycombView.h"

@implementation LMHoneycombView

// Object Lifecycle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      selected      = nil;
      firstDrawing  = YES;
      selectedColor = [NSColor blueColor];
      defaultColor  = [NSColor grayColor];
      borderColor   = [NSColor blackColor];
      borderWidth   = 2.0;
    }
    return self;
}

- (void)finalize {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super finalize];
}

// Properties

- (id)delegate {
  return delegate;
}

- (void)setDelegate:(id)_delegate {
  delegate = _delegate;
}

/*
 * The dataSource provides LMHexCell objects to the view, referenced by column+row,
 * on demand.
 */
- (id<LMHoneycombMatrix>)dataSource {
  return dataSource;
}

- (void)setDataSource:(id<LMHoneycombMatrix>)_dataSource {
  dataSource = _dataSource;
  
  cols = [dataSource hexColumns];
  rows = [dataSource hexRows];
}

/*
 * If the dataSource has changed (e.g. number of cells) it can force the view to regenerate
 */
- (void)dataSourceChanged {
  cols = [dataSource hexColumns];
  rows = [dataSource hexRows];
  firstDrawing = YES;
  [self setNeedsDisplay:YES];
}

- (NSColor *)defaultColor {
  return defaultColor;
}

- (void)setDefaultColor:(NSColor *)_defaultColor {
  defaultColor = _defaultColor;
}

- (NSColor *)selectedColor {
  return selectedColor;
}

- (void)setSelectedColor:(NSColor *)_selectedColor {
  selectedColor = _selectedColor;
}

- (NSColor *)borderColor {
  return borderColor;
}

- (void)setBorderColor:(NSColor *)_borderColor {
  borderColor = _borderColor;
}

- (CGFloat)borderWidth {
  return borderWidth;
}

- (void)setBorderWidth:(CGFloat)_borderWidth {
  borderWidth = _borderWidth;
}

// Drawing code

/*
 * Calculation of the hex radius is complicated by the interlocking
 * hexes where each hex, except the first, loses r/2 of it's width
 * to the previous hex. Also we have r/2 padding around the edges.
 *
 * Basic formula r = 2w / 3(cols)+1
 *
 * with padding
 *
 * r = 2w / 3(cols+1)
 */
- (CGFloat)hexRadius {
  return ( 2 * [self bounds].size.width ) / ( 3 * ( cols + 1 ) );
}

- (CGFloat)hexOffset {
  return ( 3 * [self hexRadius] ) / 2;
}

- (CGFloat)hexHeight {
  return 2 * sqrt( 0.75 * pow( [self hexRadius], 2 ) );
}

- (CGFloat)idealHeight {
  return [self hexOffset] + ( rows * [self hexHeight] );
}

- (void)calculateCellPaths:(NSRect)__bounds {
  NSPoint hexCentre;
  
  for( int col = 0; col < cols; col++ ) {
    for( int row = 0; row < rows; row ++ ) {
      hexCentre = NSMakePoint(
                    [self hexOffset] + (col * ( (3 * [self hexRadius] ) / 2 ) ),
                    [self hexOffset] + (row * [self hexHeight]) + ( col % 2 == 0 ? ([self hexHeight] / 2) : 0 )
                    );
      
      [[dataSource hexCellAtColumn:col row:row] setHexCentre:hexCentre radius:[self hexRadius]];
    }
  }
}

- (void)drawRect:(NSRect)rect {
  NSLog( @"drawing hexview" );
  if( firstDrawing ) {
    [self calculateCellPaths:[self bounds]];
    firstDrawing = NO;
  }
  
  for( int col = 0; col < cols; col++ ) {
    for( int row = 0; row < rows; row++ ) {
      [[dataSource hexCellAtColumn:col row:row] drawOnHoneycombView:self];
    }
  }
}

- (LMHexCell *)findCellAtPoint:(NSPoint)_point {
  // Find the Bezier containing this click
  for( int col = 0; col < cols; col++ ) {
    for( int row = 0; row < rows; row++ ) {
      LMHexCell *cell = [dataSource hexCellAtColumn:col row:row];
      if( [[cell path] containsPoint:_point] ) {
        return cell;
      }
    }
  }
  
  return nil;
}

// Selection handling

- (LMHexCell *)selected {
  return selected;
}

- (void)setSelected:(LMHexCell *)_selected {
  [selected setSelected:NO];
  selected = _selected;
  [selected setSelected:YES];
  
  [dataSource hexCellSelected:selected];
  if( [delegate respondsToSelector:@selector(honeycombView:hexCellSelected:)] ) {
    [delegate honeycombView:self hexCellSelected:selected];
  }
  
  [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)_event {
  NSLog( @"mouse = %f,%f", [_event locationInWindow].x, [_event locationInWindow].y );
  [self setSelected:[self findCellAtPoint:[self convertPoint:[_event locationInWindow] fromView:nil]]];
}

// Notifications

- (void)windowResized:(NSNotification *)notification;
{
  NSLog( @"New bounds = %f,%f Ideal bounds = %f,%f", [self bounds].size.width, [self bounds].size.height, [self bounds].size.width, [self idealHeight] );
  [self calculateCellPaths:[self bounds]];
  [self setNeedsDisplay:YES];
}

// View methods

- (void)viewDidMoveToWindow {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowResized:)
                                               name:NSWindowDidResizeNotification
                                             object:[self window]];
}

@end
