//
//  AQBitfield.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQBitfield.h"

#define NSMakeRangeFromCF(cfr) NSMakeRange( cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length )
#define CFMakeRangeFromNS(nsr) CFRangeMake( nsr.location == NSNotFound ? kCFNotFound : nsr.location, nsr.length )

@implementation AQBitfield
{
	CFMutableBitVectorRef	_vector;
}

+ (AQBitfield *) bitfieldWithSize: (NSUInteger) numberOfBits
{
	return ( [[self alloc] initWithSize: numberOfBits] );
}

- (id) initWithSize: (NSUInteger) numberOfBits
{
	self = [super init];
	if ( self == nil )
		return ( nil );
	
	_vector = CFBitVectorCreateMutable(kCFAllocatorDefault, numberOfBits);
	if ( _vector == NULL )
		self = nil;		// release via ARC
	
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super init];
	
	NSData * bits = [aDecoder decodeObjectForKey: @"bitVectorData"];
	CFBitVectorRef immutable = CFBitVectorCreate(kCFAllocatorDefault, (const UInt8 *)[bits bytes], [bits length] * sizeof(uint8_t));
	if ( immutable == NULL )
	{
		self = nil;
		return ( nil );
	}
	
	_vector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, CFBitVectorGetCount(immutable), immutable);
	
	CFRelease(immutable);
	
	return ( self );
}

- (void) dealloc
{
	// yay ARC! No -release this or -release that! Except I'm using malloc, so:
	if ( _vector != NULL )
		CFRelease( _vector );
	
	// however: I don't need to call [super dealloc] under ARC -- WIN!
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
	CFRange rng = CFRangeMake(0, CFBitVectorGetCount(_vector));
	NSUInteger len = rng.length / sizeof(UInt8);
	
	UInt8 * bytes = malloc(rng.length / sizeof(UInt8));
	CFBitVectorGetBits(_vector, rng, bytes);
	
	NSData * data = [NSData dataWithBytesNoCopy: bytes length: len];		// transfers ownership of bytes
	[aCoder encodeObject: data forKey: @"bitVectorData"];
}

- (id) copyWithZone:(NSZone *)zone
{
	AQBitfield * bitfield = [[[self class] alloc] init];
	bitfield->_vector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, CFBitVectorGetCount(_vector), _vector);
	return ( bitfield );
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	return ( [self copyWithZone: zone] );
}

- (NSUInteger) count
{
	return ( (NSUInteger)CFBitVectorGetCount(_vector) );
}

- (void) setCount: (NSUInteger) count
{
	CFBitVectorSetCount(_vector, count);
}

- (NSUInteger) countOfBit: (AQBit) bit inRange: (NSRange) range
{
	return ( (NSUInteger)CFBitVectorGetCountOfBit(_vector, CFMakeRangeFromNS(range), (CFBit)bit) );
}

- (BOOL) containsBit: (AQBit) bit inRange: (NSRange) range
{
	return ( (BOOL)CFBitVectorContainsBit(_vector, CFMakeRangeFromNS(range), (CFBit)bit) );
}

- (AQBit) bitAtIndex: (NSUInteger) index
{
	return ( (AQBit)CFBitVectorGetBitAtIndex(_vector, (CFIndex)index) );
}

- (AQBitfield *) bitfieldFromRange: (NSRange) range
{
	NSParameterAssert(range.length != 0);
	UInt8 * bytes = malloc(range.length / sizeof(UInt8));
	CFBitVectorGetBits(_vector, CFMakeRangeFromNS(range), bytes);
	
	AQBitfield * result = [[AQBitfield alloc] init];
	CFBitVectorRef immutable = CFBitVectorCreate(kCFAllocatorDefault, bytes, (CFIndex)range.length);
	result->_vector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, (CFIndex)range.length, immutable);
	CFRelease(immutable);
	
	return ( result );
}

- (NSData *) bits
{
	if ( CFBitVectorGetCount(_vector) == 0 )
		return ( [NSData data] );
	
	NSUInteger byteSize = CFBitVectorGetCount(_vector) / sizeof(UInt8);
	UInt8 * bytes = malloc(byteSize);
	CFBitVectorGetBits(_vector, CFRangeMake(0, CFBitVectorGetCount(_vector)), bytes);
	return ( [NSData dataWithBytesNoCopy: bytes length: byteSize] );
}

- (NSUInteger) firstIndexOfBit: (AQBit) bit
{
	return ( (NSUInteger)CFBitVectorGetFirstIndexOfBit(_vector, CFRangeMake(0, CFBitVectorGetCount(_vector)), (CFBit)bit) );
}

- (NSUInteger) lastIndexOfBit: (AQBit) bit
{
	return ( (NSUInteger)CFBitVectorGetLastIndexOfBit(_vector, CFRangeMake(0, CFBitVectorGetCount(_vector)), (AQBit)bit) );
}

- (void) flipBitAtIndex: (NSUInteger) index
{
	CFBitVectorFlipBitAtIndex(_vector, (CFIndex)index);
}

- (void) flipBitsInRange: (NSRange) range
{
	CFBitVectorFlipBits(_vector, CFMakeRangeFromNS(range));
}

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index
{
	CFBitVectorSetBitAtIndex(_vector, (CFIndex)index, (CFBit)bit);
}

- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit
{
	CFBitVectorSetBits(_vector, CFMakeRangeFromNS(range), (CFBit)bit);
}

- (void) setAllBits: (AQBit) bit
{
	CFBitVectorSetBits(_vector, CFRangeMake(0, CFBitVectorGetCount(_vector)), (CFBit)bit);
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
	
	return ( memcmp(vBytes, cBytes, sizeof(bits)) == 0 );
}

@end
