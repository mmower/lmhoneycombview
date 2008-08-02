//
//  HoneycombController.m
//  HoneycombView Test App
//
//  Created by Matt Mower on 31/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "HoneycombController.h"

@implementation HoneycombController

- (id)init {
  if( self = [super init] ) {
    columns = 17;
    rows    = 12;
  }
  
  return self;
}

- (void)awakeFromNib {
  [columnsField setIntValue:columns];
  [rowsField setIntValue:rows];
  [self generateCells];
}

- (void)generateCells {
  cells = [[NSMutableArray alloc] initWithCapacity:(columns*rows)];
  for( int col = 0; col < columns; col++ ) {
    for( int row = 0; row < rows; row++ ) {
      [cells addObject:[[LMHexCell alloc] initWithColumn:col row:row]];
    }
  }
}

- (int)hexColumns {
  return columns;
}

- (int)hexRows {
  return rows;
}

- (LMHexCell *)hexCellAtColumn:(int)column row:(int)row {
  return [cells objectAtIndex:CELL_OFFSET(column,row)];
}

- (void)hexCellSelected:(LMHexCell *)cell {
  NSLog( @"Selected hex at grid reference: %d,%d", [cell column], [cell row] );
}

- (void)change:(id)sender {
  columns = [columnsField intValue];
  if( columns < 1 ) {
    columns = 1;
  }
  
  rows = [rowsField intValue];
  if( rows < 1 ) {
    rows = 1;
  }
  
  [self generateCells];
  [honeycombView dataSourceChanged];
}

@end
