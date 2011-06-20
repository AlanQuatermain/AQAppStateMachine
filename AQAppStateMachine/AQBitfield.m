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
	return ( [_storage countOfIndexesInRange: range] );
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

- (NSData *) bits
{
	// TODO: Implement
	return ( nil );
}

- (NSUInteger) firstIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage firstIndex] );
	
	// TODO: Search for negative space
	return ( 0 );
}

- (NSUInteger) lastIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage lastIndex] );
	
	// TODO: Search for negative space
	return ( 0 );
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
	[_storage addIndexesInRange: NSMakeRange(0, NSUIntegerMax)];
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
	NSParameterAssert(range.length <= sizeof(NSUInteger));
	if ( range.length == 0 )
		return ( NO );
	
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
	NSParameterAssert(range.length == bitfield.count);
	if ( range.length == 0 )
		return ( NO );
	
	NSMutableIndexSet * tmp = [self _zeroBasedIndexSetForIndexesInRange: range];
	return ( [tmp isEqualToIndexSet: bitfield->_storage] );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (NSUInteger) mask matchBits: (NSUInteger) bits
{
	NSParameterAssert(range.length <= sizeof(NSUInteger));
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
	
	return ( [tmp indexGreaterThanIndex: i] == NSNotFound );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (AQBitfield *) mask equalToBitfield: (AQBitfield *) bitfield
{
	NSParameterAssert(range.length == bitfield.count);
	NSParameterAssert(range.length == mask.count);
	if ( range.length == 0 )
		return ( NO );
	
	NSMutableIndexSet * tmp = [self _zeroBasedIndexSetForIndexesInRange: range];
	NSMutableIndexSet * test = [bitfield mutableCopy];
	
	[tmp removeIndexes: mask->_storage];
	[test removeIndexes: mask->_storage];
	
	return ( [tmp isEqualToIndexSet: test] );
}

@end
