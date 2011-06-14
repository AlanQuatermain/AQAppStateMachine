//
//  AQBitRangeMatchPredicate.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Tests whether a range of bits contains the exact pattern specified.
 */
@interface AQBitRangeMatchPredicate : NSPredicate
{
	NSRange		_range;
	NSUInteger	_value;
}

/*!
 * Initializes a predicate to test a range of bits for a matching range of values.
 * @param range The range of the bits to test. Must be &lt;= sizeof(NSUInteger).
 * @param value The value for the range of bits.
 */
- (id) initWithRange: (NSRange) range value: (NSUInteger) value;

@end
