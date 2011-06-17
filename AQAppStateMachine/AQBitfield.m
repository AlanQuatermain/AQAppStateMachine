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

- (BOOL) bitsInRange: (NSRange) range matchBits: (NSUInteger) bits
{
	NSParameterAssert(range.length <= sizeof(NSUInteger));
	if ( range.length == 0 )
		return ( NO );
	
	NSUInteger swappedBits = CFSwapInt32HostToBig((uint32_t)bits);
	
	UInt8 * vBytes = malloc(sizeof(bits));
	bzero(vBytes, sizeof(bits));
	
	UInt8 * cBytes = (UInt8 *)&swappedBits;
	
	CFBitVectorGetBits(_vector, CFMakeRangeFromNS(range), vBytes);
	
	BOOL result = (memcmp(vBytes, cBytes, sizeof(bits)) == 0);
	free(vBytes);
	
	return ( result );
}

- (BOOL) bitsInRange: (NSRange) range equalToBitfield: (AQBitfield *) bitfield
{
	NSParameterAssert(range.length == bitfield.count);
	if ( range.length == 0 )
		return ( NO );
	
	UInt8 * vBytes = malloc(range.length);
	bzero(vBytes, range.length);
	
	UInt8 * cBytes = (UInt8 *)malloc(range.length);
	bzero(cBytes, range.length);
	
	CFBitVectorGetBits(_vector, CFMakeRangeFromNS(range), vBytes);
	CFBitVectorGetBits(bitfield->_vector, CFRangeMake(0, bitfield.count), cBytes);
	
	BOOL result = (memcmp(vBytes, cBytes, range.length) == 0);
	free(vBytes);
	free(cBytes);
	
	return ( result );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (NSUInteger) mask matchBits: (NSUInteger) bits
{
	NSParameterAssert(range.length <= sizeof(NSUInteger));
	if ( range.length == 0 )
		return ( NO );
	
	// mask the bits we're comparing against
	bits &= mask;
	
	NSUInteger swappedBits = CFSwapInt32HostToBig((uint32_t)bits);
	NSUInteger swappedMask = CFSwapInt32HostToBig((uint32_t)mask);
	
	UInt8 * vBytes = malloc(sizeof(bits));
	bzero(vBytes, sizeof(bits));
	
	// mask the bits we've pulled from the bitfield
	NSUInteger *pCompareNum = (NSUInteger *)vBytes;
	*pCompareNum &= swappedMask;
	
	UInt8 * cBytes = (UInt8 *)&swappedBits;
	
	CFBitVectorGetBits(_vector, CFMakeRangeFromNS(range), vBytes);
	
	BOOL result = (memcmp(vBytes, cBytes, sizeof(bits)) == 0);
	free(vBytes);
	
	return ( result );
}

- (BOOL) bitsInRange: (NSRange) range maskedWith: (AQBitfield *) mask equalToBitfield: (AQBitfield *) bitfield
{
	NSParameterAssert(range.length == bitfield.count);
	NSParameterAssert(range.length == mask.count);
	if ( range.length == 0 )
		return ( NO );
	
	int byteLen = (range.length + 7) / 8;
	UInt8 * vBytes = malloc(range.length / sizeof(UInt8));
	bzero(vBytes, range.length);
	
	UInt8 * cBytes = (UInt8 *)malloc(range.length);
	bzero(cBytes, range.length);
	
	UInt8 * mBytes = malloc(range.length);
	bzero(mBytes, range.length);
	
	CFBitVectorGetBits(_vector, CFMakeRangeFromNS(range), vBytes);
	CFBitVectorGetBits(bitfield->_vector, CFRangeMake(0, bitfield.count), cBytes);
	CFBitVectorGetBits(mask->_vector, CFRangeMake(0, bitfield.count), mBytes);
	
	// apply the mask to both ranges
	for ( int i = 0; i < byteLen; i++ )
	{
		vBytes[i] &= mBytes[i];
		cBytes[i] &= mBytes[i];
	}
	
	BOOL result = (memcmp(vBytes, cBytes, range.length) == 0);
	free(vBytes);
	free(cBytes);
	free(mBytes);
	
	return ( result );
}

@end
