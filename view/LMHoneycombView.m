//
//  LMHoneycombView.m
//  Elysium
//
//  Created by Matt Mower on 29/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <HoneycombView/HoneycombView.h>

NSString* const LMHoneycombViewDefaultColor = @"default.color";
NSString* const LMHoneycombViewSelectedColor = @"selected.color";
NSString* const LMHoneycombViewBorderColor = @"border.color";
NSString* const LMHoneycombViewBorderWidth = @"border.width";

@implementation LMHoneycombView

// Object Lifecycle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      selected          = nil;
      firstDrawing      = YES;
      drawingAttributes = [[NSMutableDictionary alloc] init];
      
      [self setDefaultColor:[NSColor grayColor]];
      [self setSelectedColor:[NSColor blueColor]];
      [self setBorderColor:[NSColor blackColor]];
      [self setBorderWidth:2.0];
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
  return [drawingAttributes objectForKey:LMHoneycombViewDefaultColor];
}

- (void)setDefaultColor:(NSColor *)_defaultColor {
  [drawingAttributes setObject:_defaultColor forKey:LMHoneycombViewDefaultColor];
}

- (NSColor *)selectedColor {
  return [drawingAttributes objectForKey:LMHoneycombViewSelectedColor];
}

- (void)setSelectedColor:(NSColor *)_selectedColor {
  [drawingAttributes setObject:_selectedColor forKey:LMHoneycombViewSelectedColor];
}

- (NSColor *)borderColor {
  return [drawingAttributes objectForKey:LMHoneycombViewBorderColor];
}

- (void)setBorderColor:(NSColor *)_borderColor {
  [drawingAttributes setObject:_borderColor forKey:LMHoneycombViewBorderColor];
}

- (CGFloat)borderWidth {
  return [[drawingAttributes objectForKey:LMHoneycombViewBorderWidth] floatValue];
}

- (void)setBorderWidth:(CGFloat)_borderWidth {
  [drawingAttributes setObject:[NSNumber numberWithFloat:_borderWidth] forKey:LMHoneycombViewBorderWidth];
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

/*
 * We draw the hex using points on a circle, therefore we need to understand
 * how far offset the centre of the first hex is from the edge of the view.
 */
- (CGFloat)hexOffset:(CGFloat)_radius {
  return ( 3 * _radius ) / 2;
}

- (CGFloat)hexHeight:(CGFloat)_radius {
  return 2 * sqrt( 0.75 * pow( _radius, 2 ) );
}

- (CGFloat)idealHeight:(CGFloat)_radius {
  return [self hexOffset:_radius] + ( rows * [self hexHeight:_radius] );
}

- (CGFloat)layerAspectRatio {
  CGFloat radius = [self hexRadius];
  CGFloat ar = ( 2 * radius ) / [self hexHeight:radius];
  NSLog( @"self=%@, radius=%f, height=%f, ar=%f", self, radius, [self hexHeight:radius], ar );
  
  return ar;
}

- (void)calculateCellPaths:(NSRect)__bounds {
  NSPoint hexCentre;
  
  CGFloat radius = [self hexRadius];
  CGFloat offset = [self hexOffset:radius];
  CGFloat height = [self hexHeight:radius];
  
  for( int col = 0; col < cols; col++ ) {
    for( int row = 0; row < rows; row ++ ) {
      hexCentre = NSMakePoint(
                    ( col + 1 ) * offset,
                    offset + (row * height) + ( ( 1 - col % 2 ) * ( height / 2 ) )
                    );
      
      [[dataSource hexCellAtColumn:col row:row] setHexCentre:hexCentre radius:radius];
    }
  }
}

- (void)drawRect:(NSRect)rect {
  if( firstDrawing ) {
    [self calculateCellPaths:[self bounds]];
    firstDrawing = NO;
  }
  
  for( int col = 0; col < cols; col++ ) {
    for( int row = 0; row < rows; row++ ) {
      [[dataSource hexCellAtColumn:col row:row] drawOnHoneycombView:self withAttributes:drawingAttributes];
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
  [self setSelected:[self findCellAtPoint:[self convertPoint:[_event locationInWindow] fromView:nil]]];
}

// Notifications

- (void)windowResized:(NSNotification *)notification;
{
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
