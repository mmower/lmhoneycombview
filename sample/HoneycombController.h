//
//  HoneycombController.h
//  HoneycombView
//
//  Created by Matt Mower on 31/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <HoneycombView/HoneycombView.h>

#define CELL_OFFSET(column,row) ((column*rows)+row)

@interface HoneycombController : NSObject <LMHoneycombMatrix> {
  IBOutlet LMHoneycombView  *honeycombView;
  IBOutlet NSTextField      *columnsField;
  IBOutlet NSTextField      *rowsField;

  NSMutableArray            *cells;
  
  int                       columns;
  int                       rows;
}

- (void)generateCells;

- (void)change:(id)sender;

@end
