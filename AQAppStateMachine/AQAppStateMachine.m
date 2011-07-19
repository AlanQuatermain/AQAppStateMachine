//
//  AQAppStateMachine.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
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

#import "AQAppStateMachine.h"
#import "AQRange.h"
#import "AQStateMaskMatchingDescriptor.h"
#import "AQStateMaskedEqualityMatchingDescriptor.h"
#import <dispatch/dispatch.h>

@implementation AQAppStateMachine
{
	AQNotifyingBitfield *	_stateBits;
	NSMutableDictionary *	_namedRanges;
	NSMutableArray *		_matchDescriptors;
	NSMutableDictionary *	_notifierLookup;
	dispatch_queue_t		_syncQ;
	NSUInteger				_nextRangeStart;
}

+ (AQAppStateMachine *) appStateMachine
{
	static AQAppStateMachine * __singleton = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{__singleton = [[self alloc] init];});
	
	return ( __singleton );
}

- (id) init
{
    self = [super init];
	if ( self == nil )
		return ( nil );
	
	// start out with 32 bits
	_stateBits = [[AQNotifyingBitfield alloc] init];
	_namedRanges = [NSMutableDictionary new];
	_matchDescriptors = [NSMutableArray new];
	_notifierLookup = [NSMutableDictionary new];
	_syncQ = dispatch_queue_create("net.alanquatermain.state-machine.sync", DISPATCH_QUEUE_SERIAL);
	
	return ( self );
}

- (void) dealloc
{
	if ( _syncQ != NULL )
		dispatch_release(_syncQ);
#if !USING_ARC
	[_stateBits release];
	[_namedRanges release];
	[_matchDescriptors release];
	[_notifierLookup release];
	[super dealloc];
#endif
}

- (void) _runNotificationBlocksForChangeInRange: (NSRange) range
{
	for ( AQStateMaskMatchingDescriptor * match in _matchDescriptors )
	{
		if ( [match isKindOfClass: [AQStateMaskedEqualityMatchingDescriptor class]] )
		{
			if ( [(AQStateMaskedEqualityMatchingDescriptor *)match matchesBitfield: _stateBits] == NO )
				continue;
		}
		else if ( [match matchesRange: range] == NO )
		{
			continue;
		}
		
		dispatch_block_t block = (dispatch_block_t)[_notifierLookup objectForKey: [match uniqueID]];
		if ( block != nil )
			block();
	}
}

- (void) _notifyForChangesToStatesMatchingDescriptor: (AQStateMaskMatchingDescriptor *) desc
										  usingBlock: (void (^)(void)) block
{
	[_matchDescriptors addObject: desc];
	[_notifierLookup setObject: block forKey: [desc uniqueID]];
	
	NSRange notifyRange = desc.fullRange;
	[_stateBits notifyModificationOfBitsInRange: notifyRange usingBlock: ^(NSRange range) {
		// find and run any stored blocks
		[self _runNotificationBlocksForChangeInRange: range];
	}];
}

- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block
{
	[self notifyForChangesToStateBitsInRange: NSMakeRange(index, 1) usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block
{
	// create match descriptor and store it
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRange: range matchingMask: nil];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) setBit: (AQBit) aBit atIndex: (NSUInteger) index ofStateBitsInRange: (NSRange) range
{
	[_stateBits setBit: aBit atIndex: range.location + index];
}

- (void) setScalar32Value: (UInt32) value forStateBitsInRange: (NSRange) range
{
	[_stateBits setBitsInRange: range from32BitValue: value];
}

- (void) setScalar64Value: (UInt64) value forStateBitsInRange: (NSRange) range
{
	[_stateBits setBitsInRange: range from64BitValue: value];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
						  maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWith32BitMask: mask forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWith64BitInteger: (UInt64) mask
								  usingBlock: (void (^)(void))block
{
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWith64BitMask: mask forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
							 maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRange: range matchingMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
							  toIntegerValue: (NSUInteger) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith32BitValue: value forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								to64BitValue: (UInt64) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith64BitValue: value forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
									 toValue: (AQBitfield *) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWithRange: range matchingValue: value];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (NSUInteger) mask
							  toIntegerValue: (NSUInteger) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith32BitValue: value forRange: range matchingMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (UInt64) mask
								to64BitValue: (UInt64) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith64BitValue: value forRange: range matchingMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif	
}

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (AQBitfield *) mask
									 toValue: (AQBitfield *) value
								  usingBlock: (void (^)(void)) block
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWithRange: range matchingValue: value withMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[desc release];
#endif
}

@end

@implementation AQAppStateMachine (NamedStateEnumerations)

#if 0
static inline NSUInteger HighestOneBit32(NSUInteger x)
{
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	return ( x & ~(x >> 1) );
}

static inline NSUInteger HighestOneBit64(UInt64 x)
{
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	x |= x >> 32;
	return ( (NSUInteger)(x & ~(x >> 1)) );
}
#else
static inline NSUInteger HighestOneBit32(NSUInteger x)
{
	NSUInteger i = 0;
	for ( i = 0; i < 32; i++, x >>= 1 )
	{
		if ( x == 0 )
			break;
	}
	return ( i );
}

static inline NSUInteger HighestOneBit64(UInt64 x)
{
	NSUInteger i = 0;
	for ( i = 0; i < 64; i++, x >>= 1 )
	{
		if ( x == 0 )
			break;
	}
	return ( i );
}
#endif

- (void) addStateMachineValuesFromZeroTo: (NSUInteger) maxValue withName: (NSString *) name
{
	[self addStateMachineValuesUsingBitfieldOfLength: HighestOneBit32(maxValue) withName: name];
}

- (void) add64BitStateMachineValuesFromZeroTo: (UInt64) maxValue withName: (NSString *) name
{
	[self addStateMachineValuesUsingBitfieldOfLength: HighestOneBit64(maxValue) withName: name];
}

- (void) addStateMachineValuesUsingBitfieldOfLength: (NSUInteger) length withName: (NSString *) name
{
	// round up to byte-size if necessary
	length = (length + 7) & ~7;
	
	dispatch_sync(_syncQ, ^{
		AQRange * range = [[AQRange alloc] initWithRange: NSMakeRange(_nextRangeStart, length)];
		[_namedRanges setObject: range forKey: name];
		_nextRangeStart = NSMaxRange(range.range);
	});
}

- (void) setValue: (UInt64) value forEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return;
	
	[self setScalar64Value: value forStateBitsInRange: rng];
}

- (void) setBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return;
	
	[self setBit: 1 atIndex: index ofStateBitsInRange: rng];
}

- (void) clearBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return;
	
	[self setBit: 0 atIndex: index ofStateBitsInRange: rng];
}

- (UInt32) valueForEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return ( 0 );
	
	return ( [_stateBits scalarBitsFromRange: rng] );
}

- (UInt64) largeValueForEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return ( 0ull );
	
	return ( [_stateBits scalarBitsFrom64BitRange: rng] );
}

- (AQBitfield *) bitsForEnumerationWithName: (NSString *) name
{
	NSRange rng = [self underlyingBitfieldRangeForName: name];
	if ( rng.location == NSNotFound )
		return ( nil );
	
	return ( [_stateBits bitfieldFromRange: rng] );
}

- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
										usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForChangesToStateBitsInRange: range.range usingBlock: block];
}

- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
									  matchingMask: (NSUInteger) mask
										usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForChangesToStateBitsInRange: range.range maskedWithInteger: mask usingBlock: block];
}

- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
								 matching64BitMask: (UInt64) mask
										usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForChangesToStateBitsInRange: range.range maskedWith64BitInteger: mask usingBlock: block];
}

- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
							  matchingMaskBitfield: (AQBitfield *) mask
										usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForChangesToStateBitsInRange: range.range maskedWithBits: mask usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										  toInteger: (NSUInteger) value
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range toIntegerValue: value usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										   toUInt64: (UInt64) value
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range to64BitValue: value usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
											 toBits: (AQBitfield *) bits
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range toValue: bits usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										 maskedWith: (NSUInteger) mask
										  toInteger: (NSUInteger) value
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range maskedWith: mask toIntegerValue: value usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										 maskedWith: (UInt64) mask
										   toUInt64: (UInt64) value
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range maskedWith: mask to64BitValue: value usingBlock: block];
}

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										 maskedWith: (AQBitfield *) mask
											 toBits: (AQBitfield *) bits
										 usingBlock: (void (^)(void)) block
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return;			// nonexistent named range
	
	[self notifyForEqualityOfStateBitsInRange: range.range maskedWith: mask toValue: bits usingBlock: block];
}

- (BOOL) bitIsSetAtIndex: (NSUInteger) index forName: (NSString *) name
{
	AQRange * range = [_namedRanges objectForKey: name];
	if ( range == nil )
		return ( NO );
	
	index += range.range.location;
	if ( [_stateBits bitAtIndex: index] == 1 )
		return ( YES );
	
	return ( NO );
}

- (BOOL) bitsSetAtIndexes: (NSIndexSet *) indexes forName: (NSString *) name
{
	AQRange * rangeObj = [_namedRanges objectForKey: name];
	if ( rangeObj == nil )
		return ( NO );
	
	NSMutableIndexSet * test = [indexes mutableCopy];
	if ( rangeObj.range.location != 0 )
		[test shiftIndexesStartingAtIndex: 0 by: rangeObj.range.location];
	
	__block BOOL result = YES;
	[test enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
		if ( [_stateBits countOfBit: 1 inRange: range] != range.length )
		{
			result = NO;
			*stop = YES;
		}
	}];
	
#if !USING_ARC
	[test release];
#endif
	
	return ( result );
}

- (BOOL) bitValuesForName: (NSString *) name matchInteger: (UInt32) value
{
	AQRange * rangeObj = [_namedRanges objectForKey: name];
	if ( rangeObj == nil )
		return ( NO );
	
	return ( [_stateBits bitsInRange: rangeObj.range matchBits: value] );
}

- (BOOL) bitValuesForName: (NSString *) name matchBits: (AQBitfield *) bits
{
	AQRange * rangeObj = [_namedRanges objectForKey: name];
	if ( rangeObj == nil )
		return ( NO );
	
	return ( [_stateBits bitsInRange: rangeObj.range equalToBitfield: bits] );
}

@end

@implementation AQAppStateMachine (MultipleEnumerationNotifications)

- (void) notifyChangesToStateMachineValuesWithNames: (NSArray *) names
									  matchingMasks: (NSArray *) masks
										 usingBlock: (void (^)(void)) block
{
	NSParameterAssert([names count] == [masks count]);
	NSParameterAssert(block != nil);
	
	NSMutableArray * ranges = [NSMutableArray new];
	[names enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		NSRange range = [self underlyingBitfieldRangeForName: obj];
		if ( range.location == NSNotFound )
		{
			NSAssert(NO, @"No range registered for name '%@'", obj);
		}
		
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[ranges addObject: r];
#if !USING_ARC
		[r release];
#endif
	}];
	
	NSMutableArray * bitmasks = [NSMutableArray new];
	[masks enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		if ( [obj isKindOfClass: [AQBitfield class]] )
		{
			[bitmasks addObject: obj];
		}
		else if ( [obj isKindOfClass: [NSNumber class]] )
		{
			AQBitfield * field = [AQBitfield new];
			UInt64 bits = [obj unsignedLongLongValue];
			for ( NSUInteger i = 0; i < 64; i++, bits >>= 1 )
			{
				if ( (bits & 1) == 1 )
					[field setBit: 1 atIndex: i];
			}
			
			[bitmasks addObject: field];
		}
		else if ( obj != [NSNull null] )
		{
			// throw an exception, but only on debug builds
			NSAssert(NO, @"Invalid object type in masks array: %@", NSStringFromClass([obj class]));
		}
	}];
	
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRanges: ranges
																				   matchingMasks: bitmasks];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[ranges release];
	[bitmasks release];
	[desc release];
#endif
}

- (void) notifyEqualityOfStateMachineValuesWithNames: (NSArray *) names
									   matchingMasks: (NSArray *) masks
											toValues: (NSArray *) values
										  usingBlock: (void (^)(void)) block
{
	NSParameterAssert([names count] == [masks count]);
	NSParameterAssert(block != nil);
	
	NSMutableArray * ranges = [NSMutableArray new];
	[names enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		NSRange range = [self underlyingBitfieldRangeForName: obj];
		if ( range.location == NSNotFound )
		{
			NSAssert(NO, @"No range registered for name '%@'", obj);
		}
		
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[ranges addObject: r];
#if !USING_ARC
		[r release];
#endif
	}];
	
	NSMutableArray * bitmasks = [NSMutableArray new];
	[masks enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		if ( [obj isKindOfClass: [AQBitfield class]] )
		{
			[bitmasks addObject: obj];
		}
		else if ( [obj isKindOfClass: [NSNumber class]] )
		{
			AQBitfield * field = [AQBitfield new];
			UInt64 bits = [obj unsignedLongLongValue];
			for ( NSUInteger i = 0; bits > 0; i++, bits >>= 1 )
			{
				if ( (bits & 1) == 1 )
					[field setBit: 1 atIndex: i];
			}
			
			[bitmasks addObject: field];
		}
		else if ( obj != [NSNull null] )
		{
			// throw an exception, but only on debug builds
			NSAssert(NO, @"Invalid object type in masks array: %@", NSStringFromClass([obj class]));
		}
	}];
	
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWithRanges: ranges masks: bitmasks matchingValues: values];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
#if !USING_ARC
	[ranges release];
	[bitmasks release];
	[desc release];
#endif
}

@end

@implementation AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name
{
	AQRange * object = [_namedRanges objectForKey: name];
	if ( object == nil )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( object.range );
}

@end
