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
#import "AQStateMatchingDescriptor.h"
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
}

- (void) _runNotificationBlocksForChangeInRange: (NSRange) range
{
	for ( AQStateMatchingDescriptor * match in _matchDescriptors )
	{
		if ( [match matchesRange: range] == NO )
			continue;
		
		dispatch_block_t block = (dispatch_block_t)[_notifierLookup objectForKey: [match uniqueID]];
		if ( block != nil )
			block();
	}
}

- (void) _notifyForChangesToStatesMatchingDescriptor: (AQStateMatchingDescriptor *) desc
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
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRange: range matchingMask: nil];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
						  maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWith32BitMask: mask forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWith64BitInteger: (UInt64) mask
								  usingBlock: (void (^)(void))block
{
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWith64BitMask: mask forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
							 maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRange: range matchingMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

@end

@implementation AQAppStateMachine (NamedStateEnumerations)

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

@end

@implementation AQAppStateMachine (MultipleEnumerationNotifications)

- (void) notifyChangesToStateMachineValuesWithNames: (NSArray *) names
									  matchingMasks: (NSArray *) masks
										 usingBlock: (void (^)(void)) block
{
	NSParameterAssert([names count] == [masks count]);
	NSParameterAssert(block != nil);
	
	NSMutableArray * ranges = [NSMutableArray new];
	[names enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop){[ranges addObject: obj];}];
	
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
			for ( NSUInteger i = 0; i > 0; i++, bits >>= 1 )
			{
				if ( (bits & 1) == 1 )
					[field setBit: 1 atIndex: i];
			}
			
			[bitmasks addObject: field];
		}
		else
		{
			// throw an exception, but only on debug builds
			NSAssert(NO, @"Invalid object type in masks array: %@", NSStringFromClass([obj class]));
		}
	}];
	
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRanges: ranges
																		   matchingMasks: bitmasks];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
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
	
	return ( result );
}

- (BOOL) bitValuesForName: (NSString *) name matchInteger: (NSUInteger) value
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

@implementation AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name
{
	AQRange * object = [_namedRanges objectForKey: name];
	if ( object == nil )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( object.range );
}

@end
