//
//  AQSimpleBitTestPredicate.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQBitfield.h"		// for AQBit

/*!
 * Tests whether a bit at a given index has a given value.
 */
@interface AQSimpleBitTestPredicate : NSPredicate
{
	NSUInteger		_index;
	AQBit			_value;
}

/*!
 * Initialize a predicate to test the value of a given bit in a bitfield.
 * @param value A bit value. Should be 0 or 1.
 * @param index The index in the bitfield of the bit to test.
 */
- (id) initWithBitValue:(AQBit)value atIndex:(NSUInteger)index;

@end
