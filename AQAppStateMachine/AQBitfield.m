//
//  AQBitfield.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  Neither the name of the project's author nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AQBitfield.h"
#import "AQBitfieldPrivate.h"

@implementation AQBitfield

- (id) _initFromNSIndexSet: (NSIndexSet *) indexSet
{
	self = [self init];		// call the designated initializer like a good boy, now
	if ( self == nil )
		return ( nil );
	
	[_storage addIndexes: indexSet];
	
	return ( self );
}

- (id) init
{
	self = [super init];
	if ( self == nil )
		return ( nil );
	
	_storage = [NSMutableIndexSet new];
	
	return ( self );
}

- (id) initWith32BitField: (UInt32) bits
{
	self = [self init];
	if ( self == nil )
		return ( nil );
	
	for ( NSUInteger i = 0; bits != 0; i++, bits >>= 1 )
	{
		if ( (bits & 1) == 1 )
			[_storage addIndex: i];
	}
	
	return ( self );
}

- (id) initWith64BitField: (UInt64) bits
{
	self = [self init];
	if ( self == nil )
		return ( nil );
	
	for ( NSUInteger i = 0; bits != 0; i++, bits >>= 1ull )
	{
		if ( (bits & 1ull) == 1ull )
			[_storage addIndex: i];
	}
	
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super init];
	_storage = [[aDecoder decodeObjectForKey: @"bitVectorData"] mutableCopy];
	
	return ( self );
}

#if !USING_ARC
- (void) dealloc
{
	[_storage release];
	[super dealloc];
}
#endif

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

- (NSComparisonResult) compare: (AQBitfield *) other
{
	NSUInteger mine = [_storage firstIndex];
	NSUInteger theirs = [other->_storage firstIndex];
	
	while ( mine != NSNotFound && theirs != NSNotFound )
	{
		if ( mine > theirs )
			return ( NSOrderedDescending );
		else if ( mine > theirs )
			return ( NSOrderedAscending );
	}
	
	if ( mine != NSNotFound && theirs == NSNotFound )
		return ( NSOrderedDescending );
	else if ( mine == NSNotFound && theirs != NSNotFound )
		return ( NSOrderedAscending );
	
	return ( NSOrderedSame );
}

- (NSUInteger) count
{
	NSUInteger last = [_storage lastIndex];
	if ( last == NSNotFound )
		return ( 0 );
	
	return ( last + 1 );
}

- (NSRange) rangeOfAllBits
{
	if ( [_storage count] == 0 )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( NSMakeRange([_storage firstIndex], [_storage lastIndex]-[_storage firstIndex]) );
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
#if USING_ARC
	return ( result );
#else
	return ( [result autorelease] );
#endif
}

- (NSUInteger) firstIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage firstIndex] );
	
	__block NSUInteger result = 0;
	
	[_storage enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
		if ( range.location == 0 )
			result = NSMaxRange(range);
		*stop = YES;
	}];
	
	return ( result );
}

- (NSUInteger) lastIndexOfBit: (AQBit) bit
{
	if ( bit )
		return ( [_storage lastIndex] );
	
	__block NSUInteger result = NSNotFound;
	
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
	
	return ( result );
}

- (UInt32) scalarBitsFromRange: (NSRange) range
{
	NSParameterAssert(range.length <= sizeof(UInt32)*8);
	if ( range.length > sizeof(UInt32)*8 )
	{
		[NSException raise: NSRangeException format: @"%@ specifies a range larger than the size of a 32-bit quantity", NSStringFromRange(range)];
	}
	
	__block UInt32 result = 0;
	
	[_storage enumerateIndexesInRange: range options: 0 usingBlock: ^(NSUInteger idx, BOOL *stop) {
		idx -= range.location;
		result |= (1 << idx);
	}];
	
	return ( result );
}

- (UInt64) scalarBitsFrom64BitRange: (NSRange) range
{
	NSParameterAssert(range.length <= sizeof(UInt64)*8);
	if ( range.length > sizeof(UInt64)*8 )
	{
		[NSException raise: NSRangeException format: @"%@ specifies a range larger than the size of a 64-bit quantity", NSStringFromRange(range)];
	}
	
	__block UInt64 result = 0ull;
	
	[_storage enumerateIndexesInRange: range options: 0 usingBlock: ^(NSUInteger idx, BOOL *stop) {
		idx -= (UInt64)range.location;
		result |= (1ull << idx);
	}];
	
	return ( result );
}

- (void) flipBitAtIndex: (NSUInteger) index
{
	if ( [_storage containsIndex: index] )
		[_storage removeIndex: index];
	else
		[_storage addIndex: index];
	
	[self _updatedBitsInRange: NSMakeRange(index, 1)];
}

- (void) flipBitsInRange: (NSRange) range
{
	for ( NSUInteger i = range.location; i < NSMaxRange(range); i++ )
	{
		if ( [_storage containsIndex: i] )
			[_storage removeIndex: i];
		else
			[_storage addIndex: i];
	}
	
	[self _updatedBitsInRange: range];
}

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index
{
	if ( bit )
		[_storage addIndex: index];
	else
		[_storage removeIndex: index];
	
	[self _updatedBitsInRange: NSMakeRange(index, 1)];
}

- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit
{
	if ( bit )
		[_storage addIndexesInRange: range];
	else
		[_storage removeIndexesInRange: range];
	
	[self _updatedBitsInRange: range];
}

- (void) setBitsFrom32BitValue: (UInt32) value
{
	NSUInteger i = 0;
	for ( i = 0; i < 32; i++, value >>= 1 )
	{
		if ( (value & 1) == 1 )
			[_storage addIndex: i];
		else
			[_storage removeIndex: i];
	}
	
	[self _updatedBitsInRange: NSMakeRange(0, i)];
}

- (void) setBitsFrom64BitValue: (UInt64) value
{
	NSUInteger i = 0;
	for ( i = 0; i < 64; i++, value >>= 1 )
	{
		if ( (value & 1) == 1 )
			[_storage addIndex: i];
		else
			[_storage removeIndex: i];
	}
	
	[self _updatedBitsInRange: NSMakeRange(0, i)];
}

- (void) setBitsInRange: (NSRange) range from32BitValue: (UInt32) value
{
	if ( range.length > 32 )
		[NSException raise: NSInvalidArgumentException format: @"Range supplied to -%@ must have a length of 32 or less (received range %@)", NSStringFromClass([self class]), NSStringFromRange(range)];
	
	NSUInteger i = 0;
	for ( i = 0; i < range.length; i++, value >>= 1 )
	{
		if ( (value & 1) == 1 )
			[_storage addIndex: range.location + i];
		else
			[_storage removeIndex: range.location + i];
	}
	
	[self _updatedBitsInRange: NSMakeRange(range.location, i)];
}

- (void) setBitsInRange: (NSRange) range from64BitValue: (UInt64) value
{
	if ( range.length > 64 )
		[NSException raise: NSInvalidArgumentException format: @"Range supplied to -%@ must have a length of 64 or less (received range %@)", NSStringFromClass([self class]), NSStringFromRange(range)];
	
	NSUInteger i = 0;
	for ( i = 0; i < range.length; i++, value >>= 1 )
	{
		if ( (value & 1) == 1 )
			[_storage addIndex: range.location + i];
		else
			[_storage removeIndex: range.location + i];
	}
	
	[self _updatedBitsInRange: NSMakeRange(range.location, i)];
}

- (void) unionWithBitfield: (AQBitfield *) bitfield
{
	[_storage addIndexes: bitfield->_storage];
	[self _updatedBitsInRange: [bitfield rangeOfAllBits]];
}

- (void) setAllBits: (AQBit) bit
{
	[_storage addIndexesInRange: NSMakeRange(0, NSNotFound)];
	[self _updatedBitsInRange: NSMakeRange(0, NSNotFound)];
}

- (NSMutableIndexSet *) _zeroBasedIndexSetForIndexesInRange: (NSRange) range
{
	NSMutableIndexSet * tmp = [_storage mutableCopy];
	[tmp removeIndexesInRange: NSMakeRange(NSMaxRange(range), NSUIntegerMax-NSMaxRange(range))];
	if ( range.location != 0 )
		[tmp shiftIndexesStartingAtIndex: range.location by: -(NSInteger)(range.location)];

#if USING_ARC
	return ( tmp );
#else
	return ( [tmp autorelease] );
#endif
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
	if ( range.length == 0 )
		return ( NO );
	
	AQBitfield * tmp1 = [self bitfieldFromRange: range];
	[tmp1 shiftBitsLeftBy: range.location];
	[tmp1 maskWithBits: mask];
	
	AQBitfield * tmp2 = [bitfield copy];
#if !USING_ARC
	[tmp2 autorelease];
#endif
	[tmp2 maskWithBits: mask];
	[tmp2->_storage removeIndexesInRange: NSMakeRange(range.length, NSUIntegerMax-range.length)];
	
	return ( [tmp1 isEqual: tmp2] );
}

- (void) shiftBitsLeftBy: (NSUInteger) bits
{
	if ( [_storage count] == 0 )
		return;
	
	NSRange myRange = [self rangeOfAllBits];
	if ( myRange.location > bits )
	{
		myRange.location -= bits;
		myRange.length += bits;
	}
	else
	{
		myRange.length += myRange.location;
		myRange.location = 0;
	}
	
	NSInteger shift = 0 - (NSInteger)bits;
	[_storage shiftIndexesStartingAtIndex: bits by: shift];
	[self _updatedBitsInRange: myRange];
}

- (void) shiftBitsRightBy: (NSUInteger) bits
{
	if ( [_storage count] == 0 )
		return;
	
	NSRange myRange = [self rangeOfAllBits];
	if ( NSMaxRange(myRange) + bits < NSNotFound )
	{
		myRange.length += bits;
	}
	else
	{
		myRange.length += NSMaxRange(myRange) - NSNotFound;
	}
	
	[_storage shiftIndexesStartingAtIndex: 0 by: (NSInteger)bits];
	[self _updatedBitsInRange: myRange];
}

- (void) maskWithBits: (AQBitfield *) mask
{
	NSRange range = NSMakeRange(0, MIN(self.count, mask.count));
	__block NSRange changed = {0, 0};
	
	if ( [mask->_storage respondsToSelector: @selector(enumerateRangesUsingBlock:)] )
	{
		__block NSUInteger negativeRangeLocation = 0;
		[mask->_storage enumerateRangesInRange: range options: 0 usingBlock: ^(NSRange range, BOOL *stop) {
			if ( range.location > negativeRangeLocation )
			{
				NSRange r = NSMakeRange(negativeRangeLocation, range.location - negativeRangeLocation);
				[_storage removeIndexesInRange: r];
				changed = NSUnionRange(changed, r);
			}
			negativeRangeLocation = NSMaxRange(range);
		}];
		
		if ( negativeRangeLocation <= [_storage lastIndex] )
		{
			NSRange r = NSMakeRange(negativeRangeLocation, NSUIntegerMax-negativeRangeLocation);
			[_storage removeIndexesInRange: r];
			changed = NSUnionRange(changed, r);
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
				changed = NSUnionRange(changed, negativeRange);
			}
			
			negativeRange.location = idx+1;
		}];
		
		if ( negativeRange.location <= [_storage lastIndex] )
		{
			negativeRange.length = [_storage lastIndex] - negativeRange.location;
			[_storage removeIndexesInRange: negativeRange];
			changed = NSUnionRange(changed, negativeRange);
		}
	}
	
	[self _updatedBitsInRange: changed];
}

- (AQBitfield *) bitfieldUsingMask: (AQBitfield *) mask
{
	AQBitfield * field = [self copy];
	[field maskWithBits: mask];
#if USING_ARC
	return ( field );
#else
	return ( [field autorelease] );
#endif
}

- (AQBitfield *) bitfieldFromLeftShiftingBy: (NSUInteger) bits
{
	AQBitfield * result = [self copy];
	[result shiftBitsLeftBy: bits];
#if USING_ARC
	return ( result );
#else
	return ( [result autorelease] );
#endif
}

- (AQBitfield *) bitfieldFromRightShiftingBy: (NSUInteger) bits
{
	AQBitfield * result = [self copy];
	[result shiftBitsRightBy: bits];
#if USING_ARC
	return ( result );
#else
	return ( [result autorelease] );
#endif
}

@end

@implementation NSIndexSet (AQBitfieldCreation)

- (AQBitfield *) bitfieldRepresentation
{
#if USING_ARC
	return ( [[AQBitfield alloc] _initFromNSIndexSet: self] );
#else
	return ( [[[AQBitfield alloc] _initFromNSIndexSet: self] autorelease] );
#endif
}

@end

@implementation AQBitfield (_PrivateIndexSetAccess)

- (NSMutableIndexSet *) indexSet
{
#if USING_ARC
	return ( _storage );
#else
	return ( [[_storage retain] autorelease] );
#endif
}

- (void) _updatedBitsInRange: (NSRange) range
{
	// this class does nothing-- it's for subclassers to implement
}

@end
