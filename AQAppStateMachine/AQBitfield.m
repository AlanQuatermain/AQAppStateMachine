//
//  AQBitfield.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQBitfield.h"

@implementation AQBitfield
{
	NSMutableIndexSet *		_storage;
}

- (id) init
{
	self = [super init];
	if ( self == nil )
		return ( nil );
	
	_storage = [NSMutableIndexSet new];
	
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super init];
	_storage = [[aDecoder decodeObjectForKey: @"bitVectorData"] mutableCopy];
	
	return ( self );
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
	[aCoder encodeObject: _storage forKey: @"bitVectorData"];
}

- (id) copyWithZone:(NSZone *)zone
{
	AQBitfield * bitfield = [[[self class] alloc] init];
	[bitfield->_storage addIndexes: _storage];
	return ( bitfield );
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	return ( [self copyWithZone: zone] );
}

- (NSString *) description
{
	return ( [NSString stringWithFormat: @"<AQBitfield %p>{_storage = %@}", self, _storage] );
}

- (NSUInteger) hash
{
	return ( [_storage hash] );
}

- (BOOL) isEqual: (id) object
{
	if ( [object isKindOfClass: [self class]] == NO )
		return ( NO );
	
	AQBitfield * other = (AQBitfield *)object;
	return ( [_storage isEqualToIndexSet: other->_storage] );
}

- (NSUInteger) count
{
	return ( [_storage lastIndex] + 1 );
}

- (NSUInteger) countOfBit: (AQBit) bit inRange: (NSRange) range
{
	if ( bit )
		return ( [_storage countOfIndexesInRange: range] );
	else
		return ( range.length - [_storage countOfIndexesInRange: range] );
}

- (BOOL) containsBit: (AQBit) bit inRange: (NSRange) range
{
	if ( bit )
		return ( [_storage containsIndexesInRange: range] );
	
	return ( [_storage countOfIndexesInRange: range] < range.length );
}

- (AQBit) bitAtIndex: (NSUInteger) index
{
	if ( [_storage containsIndex: index] )
		return ( 1 );
	
	return ( 0 );
}

- (AQBitfield *) bitfieldFromRange: (NSRange) range
{
	AQBitfield * result = [[AQBitfield alloc] init];
	[result->_storage addIndexes: [_storage indexesInRange: range options: 0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) { return YES; }]];
	return ( result );
}

- (NSUInteger) firstIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage firstIndex] );
	
	__block NSUInteger result = 0;
	
	if ( [_storage respondsToSelector: @selector(enumerateRangesUsingBlock:)] )
	{
		[_storage enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			if ( range.location == 0 )
				result = NSMaxRange(range);
			*stop = YES;
		}];
	}
	else
	{
		__block NSUInteger lastHighest = 0;
		[_storage enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
			if ( idx - lastHighest > 1 )
			{
				result = lastHighest+1;
				*stop = YES;
			}
			
			lastHighest = idx;
		}];
	}
	
	return ( result );
}

- (NSUInteger) lastIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage lastIndex] );
	
	__block NSUInteger result = NSNotFound;
	
	if ( [_storage respondsToSelector: @selector(enumerateRangesUsingBlock:)] )
	{
		[_storage enumerateRangesWithOptions: NSEnumerationReverse usingBlock: ^(NSRange range, BOOL *stop) {
			if ( NSMaxRange(range) < NSNotFound-1 )
			{
				result = NSNotFound-1;
			}
			else if ( range.location > 0 )
			{
				result = range.location-1;
			}
			
			*stop = YES;
		}];
	}
	else
	{
		__block NSUInteger lastLowest = NSNotFound-1;
		[_storage enumerateIndexesWithOptions: NSEnumerationReverse usingBlock: ^(NSUInteger idx, BOOL *stop) {
			if ( idx < lastLowest-1 )
			{
				result = lastLowest-1;
				*stop = YES;
			}
		}];
	}
	
	return ( result );
}

- (void) flipBitAtIndex: (NSUInteger) index
{
	if ( [_storage containsIndex: index] )
		[_storage removeIndex: index];
	else
		[_storage addIndex: index];
}

- (void) flipBitsInRange: (NSRange) range
{
	for ( NSUInteger i = range.location; i < NSMaxRange(range); i++ )
	{
		[self flipBitAtIndex: i];
	}
}

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index
{
	if ( bit )
		[_storage addIndex: index];
	else
		[_storage removeIndex: index];
}

- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit
{
	if ( bit )
		[_storage addIndexesInRange: range];
	else
		[_storage removeIndexesInRange: range];
}

- (void) setAllBits: (AQBit) bit
{
	[_storage addIndexesInRange: NSMakeRange(0, NSNotFound)];
}

- (NSMutableIndexSet *) _zeroBasedIndexSetForIndexesInRange: (NSRange) range
{
	NSMutableIndexSet * tmp = [_storage mutableCopy];
	[tmp removeIndexesInRange: NSMakeRange(NSMaxRange(range), NSUIntegerMax-NSMaxRange(range))];
	if ( range.location != 0 )
		[tmp shiftIndexesStartingAtIndex: range.location by: -(NSInteger)(range.location)];
	
	return ( tmp );
}

- (BOOL) bitsInRange: (NSRange) range matchBits: (NSUInteger) bits
{
	NSParameterAssert(range.length <= sizeof(NSUInteger)*8);
	if ( range.length == 0 )
		return ( NO );
	if ( bits == 0 )
		return ( [self countOfBit: 1 inRange: range] == 0 );
	
	NSMutableIndexSet * tmp = [self _zeroBasedIndexSetForIndexesInRange: range];
	NSUInteger i;
	
	for ( i = 0; bits > 0; i++, bits >>= 1 )
	{
		if ( (((bits & 1) == 1) && ([tmp containsIndex: i] == NO)) ||
			(((bits & 1) != 1) && ([tmp containsIndex: i] == YES)) )
		{
			return ( NO );
		}
	}
	
	return ( [tmp indexGreaterThanIndex: i] == NSNotFound );
}

- (BOOL) bitsInRange: (NSRange) range equalToBitfield: (AQBitfield *) bitfield
{
	NSParameterAssert(range.length <= bitfield.count);
	if ( range.length == 0 )
		return ( NO );
	
	NSMutableIndexSet * tmp = [self _zeroBasedIndexSetForIndexesInRange: range];
	return ( [tmp isEqualToIndexSet: bitfield->_storage] );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (NSUInteger) mask matchBits: (NSUInteger) bits
{
	NSParameterAssert(range.length <= sizeof(NSUInteger)*8);
	if ( range.length == 0 )
		return ( NO );
	
	NSMutableIndexSet * tmp = [self _zeroBasedIndexSetForIndexesInRange: range];
	NSUInteger i;
	for ( i = 0; bits > 0 && mask > 0; i++, bits >>= 1, mask >>= 1 )
	{
		// skip bits not matching the mask
		if ( (mask & 1) == 0 )
			continue;
		
		if ( (((bits & 1) == 1) && ([tmp containsIndex: i] == NO)) ||
			 (((bits & 1) != 1) && ([tmp containsIndex: i] == YES)) )
		{
			return ( NO );
		}
	}
	
	return ( (mask == 0) || [tmp indexGreaterThanIndex: i] == NSNotFound );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (AQBitfield *) mask equalToBitfield: (AQBitfield *) bitfield
{
	NSParameterAssert(range.length <= bitfield.count);
	NSParameterAssert(range.length <= mask.count);
	if ( range.length == 0 )
		return ( NO );
	
	AQBitfield * tmp1 = [self bitfieldFromRange: range];
	[tmp1 shiftBitsLeftBy: range.location];
	[tmp1 maskWithBits: mask];
	
	AQBitfield * tmp2 = [bitfield copy];
	[tmp2 maskWithBits: mask];
	[tmp2->_storage removeIndexesInRange: NSMakeRange(range.length, NSUIntegerMax-range.length)];
	
	return ( [tmp1 isEqual: tmp2] );
}

- (void) shiftBitsLeftBy: (NSUInteger) bits
{
	NSInteger shift = 0 - (NSInteger)bits;
	[_storage shiftIndexesStartingAtIndex: bits by: shift];
}

- (void) shiftBitsRightBy: (NSUInteger) bits
{
	[_storage shiftIndexesStartingAtIndex: 0 by: (NSInteger)bits];
}

- (void) maskWithBits: (AQBitfield *) mask
{
	NSRange range = NSMakeRange(0, MIN(self.count, mask.count));
	
	if ( [mask->_storage respondsToSelector: @selector(enumerateRangesUsingBlock:)] )
	{
		__block NSUInteger negativeRangeLocation = 0;
		[mask->_storage enumerateRangesInRange: range options: 0 usingBlock: ^(NSRange range, BOOL *stop) {
			if ( range.location > negativeRangeLocation )
			{
				[_storage removeIndexesInRange: NSMakeRange(negativeRangeLocation, range.location - negativeRangeLocation)];
			}
			negativeRangeLocation = NSMaxRange(range);
		}];
		
		if ( negativeRangeLocation <= [_storage lastIndex] )
		{
			[_storage removeIndexesInRange: NSMakeRange(negativeRangeLocation, NSUIntegerMax-negativeRangeLocation)];
		}
	}
	else
	{
		__block NSRange negativeRange = NSMakeRange(0, 0);
		[mask->_storage enumerateIndexesInRange: range options: 0 usingBlock: ^(NSUInteger idx, BOOL *stop) {
			if ( idx != 0 && NSMaxRange(negativeRange) < idx-1 )
			{
				// expand negative range to fill the area below current index and remove all indices from local storage
				negativeRange.length = idx-negativeRange.location;
				[_storage removeIndexesInRange: negativeRange];
			}
			
			negativeRange.location = idx+1;
		}];
		
		if ( negativeRange.location <= [_storage lastIndex] )
		{
			negativeRange.length = [_storage lastIndex] - negativeRange.location;
			[_storage removeIndexesInRange: negativeRange];
		}
	}
}

@end
