//
//  LMHoneycombView.h
//  Elysium
//
//  Created by Matt Mower on 29/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LMHoneycombMatrix.h"

@class LMHexCell;

@interface LMHoneycombView : NSView {
  LMHexCell             *selected;
  
  id<LMHoneycombMatrix> dataSource;
  id                    delegate;
  
  int                   cols;
  int                   rows;
  
  BOOL                  firstDrawing;
  
  NSColor               *selectedColor;
  NSColor               *defaultColor;
  NSColor               *borderColor;
  CGFloat               borderWidth;
}

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (id<LMHoneycombMatrix>)dataSource;
- (void)setDataSource:(id<LMHoneycombMatrix>)dataSource;
- (void)dataSourceChanged;

- (LMHexCell *)selected;
- (void)setSelected:(LMHexCell *)selected;

- (CGFloat)hexRadius;
- (CGFloat)hexOffset:(CGFloat)radius;
- (CGFloat)hexHeight:(CGFloat)radius;
- (CGFloat)idealHeight:(CGFloat)radius;

- (NSColor *)selectedColor;
- (NSColor *)defaultColor;
- (NSColor *)borderColor;
- (CGFloat)borderWidth;

- (LMHexCell *)findCellAtPoint:(NSPoint)point;

- (void)calculateCellPaths:(NSRect)bounds;

@end

// Define a category on NSObject for our delegate methods
@interface NSObject (LMHoneycombViewDelegate)
- (void)honeycombView:(LMHoneycombView *)honeycombView hexCellSelected:(LMHexCell *)cell;
@end
