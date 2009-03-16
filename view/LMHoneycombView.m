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
NSString* const LMHoneycombViewSelectedBorderColor = @"selected.border.color";
NSString* const LMHoneycombViewBorderWidth = @"border.width";

@interface LMHoneycombView (PrivateMethods)

- (void)drawCells:(NSMutableDictionary *)currentDrawingAttributes;

@end


@implementation LMHoneycombView

// Object Lifecycle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      mSelected             = nil;
      mRecalculateCellPaths = YES;
      mDrawingAttributes    = [[NSMutableDictionary alloc] init];
      
      [self setDefaultColor:[NSColor grayColor]];
      [self setSelectedColor:[NSColor blueColor]];
      [self setBorderColor:[NSColor blackColor]];
      [self setSelectedBorderColor:[NSColor blackColor]];
      [self setBorderWidth:2.0];
    }
    return self;
}

- (void)finalize {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super finalize];
}


#pragma mark Properties

@synthesize mDelegate;
@synthesize mDrawingAttributes;
@synthesize mRecalculateCellPaths;
@synthesize mCols;
@synthesize mRows;
@synthesize mSelected;

- (void)setSelected:(LMHexCell *)selected {
  [mSelected setSelected:NO];
  mSelected = selected;
  [mSelected setSelected:YES];
  
  [[self dataSource] hexCellSelected:mSelected];
  if( [[self delegate] respondsToSelector:@selector(honeycombView:hexCellSelected:)] ) {
    [[self delegate] honeycombView:self hexCellSelected:mSelected];
  }
  
  [self setNeedsDisplay:YES];
}


@synthesize mDataSource;
/*
 * The dataSource provides LMHexCell objects to the view, referenced by column+row,
 * on demand.
 */

- (void)setDataSource:(id<LMHoneycombMatrix>)dataSource {
  mDataSource = dataSource;
  [self dataSourceChanged];
}


/*
 * If the dataSource has changed (e.g. number of cells) it can force the view to regenerate
 */
- (void)dataSourceChanged {
  mCols     = [[self dataSource] hexColumns];
  mRows     = [[self dataSource] hexRows];
  mSelected = nil;
  
  [self setRecalculateCellPaths:YES];
  [self setNeedsDisplay:YES];
}


#pragma mark Drawing color pseudo-properties

- (NSColor *)defaultColor {
  return [[self drawingAttributes] objectForKey:LMHoneycombViewDefaultColor];
}

- (void)setDefaultColor:(NSColor *)defaultColor {
  [[self drawingAttributes] setObject:defaultColor forKey:LMHoneycombViewDefaultColor];
}

- (NSColor *)selectedColor {
  return [[self drawingAttributes] objectForKey:LMHoneycombViewSelectedColor];
}

- (void)setSelectedColor:(NSColor *)selectedColor {
  [[self drawingAttributes] setObject:selectedColor forKey:LMHoneycombViewSelectedColor];
}

- (NSColor *)borderColor {
  return [[self drawingAttributes] objectForKey:LMHoneycombViewBorderColor];
}

- (void)setBorderColor:(NSColor *)borderColor {
  [[self drawingAttributes] setObject:borderColor forKey:LMHoneycombViewBorderColor];
}

- (NSColor *)selectedBorderColor {
  return [[self drawingAttributes] objectForKey:LMHoneycombViewSelectedBorderColor];
}

- (void)setSelectedBorderColor:(NSColor *)selectedBorderColor {
  [[self drawingAttributes] setObject:selectedBorderColor forKey:LMHoneycombViewSelectedBorderColor];
}

- (CGFloat)borderWidth {
  return [[[self drawingAttributes] objectForKey:LMHoneycombViewBorderWidth] floatValue];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
  [[self drawingAttributes] setObject:[NSNumber numberWithFloat:borderWidth] forKey:LMHoneycombViewBorderWidth];
}


#pragma mark Drawing support

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
  return ( 2 * [self bounds].size.width ) / ( 3 * ( [self cols] + 1 ) );
}


/*
 * We draw the hex using points on a circle, therefore we need to understand
 * how far offset the centre of the first hex is from the edge of the view.
 */
- (CGFloat)hexOffset:(CGFloat)radius {
  return ( 3 * radius ) / 2;
}


- (CGFloat)hexHeight:(CGFloat)radius {
  return 2 * sqrt( 0.75 * pow( radius, 2 ) );
}


- (CGFloat)idealHeight:(CGFloat)radius {
  return [self hexOffset:radius] + ( [self rows] * [self hexHeight:radius] );
}


- (CGFloat)layerAspectRatio {
  CGFloat radius = [self hexRadius];
  CGFloat ar = ( 2 * radius ) / [self hexHeight:radius];
  NSLog( @"self=%@, radius=%f, height=%f, ar=%f", self, radius, [self hexHeight:radius], ar );
  
  return ar;
}


- (void)calculateCellPaths:(NSRect)bounds {
  NSPoint hexCentre;
  
  CGFloat radius = [self hexRadius];
  CGFloat offset = [self hexOffset:radius];
  CGFloat height = [self hexHeight:radius];
  
  for( int col = 0; col < [self cols]; col++ ) {
    for( int row = 0; row < [self rows]; row ++ ) {
      hexCentre = NSMakePoint(
                    ( col + 1 ) * offset,
                    offset + (row * height) + ( ( col % 2 ) * ( height / 2 ) )
                    );
      
      [[[self dataSource] hexCellAtColumn:col row:row] setHexCentre:hexCentre radius:radius];
    }
  }
}


- (void)drawCells:(NSMutableDictionary *)currentDrawingAttributes {
  LMHexCell *cell;
  for( int col = 0; col < [self cols]; col++ ) {
    for( int row = 0; row < [self rows]; row++ ) {
      cell = [[self dataSource] hexCellAtColumn:col row:row];
      if( cell != [self selected] ) {
        [currentDrawingAttributes setDictionary:[self drawingAttributes]];
        [cell drawOnHoneycombView:self withAttributes:currentDrawingAttributes];
      }
    }
  }
}


- (void)drawRect:(NSRect)rect {
  NSMutableDictionary *currentDrawingAttributes = [NSMutableDictionary dictionary];
  
  if( [self recalculateCellPaths] ) {
    [self calculateCellPaths:[self bounds]];
    [self setRecalculateCellPaths:NO];
  }
  
  [self drawCells:currentDrawingAttributes];
  [currentDrawingAttributes setDictionary:[self drawingAttributes]];
  [[self selected] drawOnHoneycombView:self withAttributes:currentDrawingAttributes];
}


#pragma mark Event handling

- (void)mouseDown:(NSEvent *)event {
  [self setSelected:[self findCellAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]]];
}


- (void)rightMouseDown:(NSEvent *)event {
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  
  NSMenu *contextMenu = [[self findCellAtPoint:point] contextMenu];
  if( contextMenu ) {
    NSPopUpButtonCell *cell = [[NSPopUpButtonCell alloc] initTextCell:@"Context Menu" pullsDown:YES];
    [cell setMenu:contextMenu];
    [cell setAutoenablesItems:YES];
    [cell performClickWithFrame:NSMakeRect(point.x,point.y,1,1) inView:self];
    // [NSMenu popUpContextMenu:contextMenu withEvent:_event_ forView:self];
  }
}


- (LMHexCell *)findCellAtPoint:(NSPoint)point {
  // Find the Bezier containing this click
  for( int col = 0; col < [self cols]; col++ ) {
    for( int row = 0; row < [self rows]; row++ ) {
      LMHexCell *cell = [[self dataSource] hexCellAtColumn:col row:row];
      if( [[cell path] containsPoint:point] ) {
        return cell;
      }
    }
  }
  
  return nil;
}


#pragma mark Notifications

- (void)windowResized:(NSNotification *)notification {
  [self setRecalculateCellPaths:YES];
  [self setNeedsDisplay:YES];
}


#pragma mark NSView overrides

- (void)viewDidMoveToWindow {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowResized:)
                                               name:NSWindowDidResizeNotification
                                             object:[self window]];
}

@end
