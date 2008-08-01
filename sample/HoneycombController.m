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
    cells = [[NSMutableArray alloc] initWithCapacity:204];
  }
  
  return self;
}

- (void)awakeFromNib {
  for( int col = 0; col < 17; col++ ) {
    for( int row = 0; row < 12; row++ ) {
      [cells addObject:[[LMHexCell alloc] initWithColumn:col row:row data:nil]];
    }
  }
}

- (int)hexColumns {
  return 17;
}

- (int)hexRows {
  return 12;
}

- (LMHexCell *)hexCellAtColumn:(int)column row:(int)row {
  return [cells objectAtIndex:((column*12)+row)];
}

- (void)hexCellSelected:(LMHexCell *)cell {
  NSLog( @"Selected hex at grid reference: %d,%d", [cell column], [cell row] );
}

@end
