//
//  AQStateMaskedEqualityMatchingDescriptor.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-27.
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

#import "AQStateMaskedEqualityMatchingDescriptor.h"
#import "AQBitfield.h"
#import "AQBitfieldPrivate.h"
#import "AQRange.h"
#import "AQIndexSetMasking.h"

@implementation AQStateMaskedEqualityMatchingDescriptor

- (id)initWithRanges: (NSArray *) ranges masks: (NSArray *) masks matchingValues: (NSArray *) values
{
	NSParameterAssert([values count] == [ranges count]);
    self = [super initWithRanges: ranges matchingMasks: masks];
    if ( self == nil )
		return ( nil );
	
	_mask = [AQBitfield new];
	
	@autoreleasepool
	{
		[ranges enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			NSRange rng = [obj range];
			AQBitfield * mask = nil;
			if ( [masks count] > idx )
				mask = [masks objectAtIndex: idx];
			
			if ( mask == nil )
			{
				[_mask.indexSet addIndexesInRange: rng];
			}
			else
			{
				NSMutableIndexSet * mutable = [mask.indexSet mutableCopy];
				[mutable shiftIndexesStartingAtIndex: 0 by: rng.location];
				[_mask.indexSet addIndexes: mutable];
			}
		}];
		
		_value = [AQBitfield new];
		[values enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			AQBitfield * mask = nil;
			if ( [masks count] > idx )
				mask = [masks objectAtIndex: idx];
			
			AQBitfield * modified = [obj copy];
			if ( mask != nil )
				[modified maskWithBits: mask];
			
			NSRange range = [[ranges objectAtIndex: idx] range];
			if ( range.location != 0 )
				[modified shiftBitsRightBy: range.location];
			
			[_value unionWithBitfield: modified];
		}];
	}
	
	return ( self );
}

#if !USING_ARC
- (void) dealloc
{
	[_value release];
	[_mask release];
	[super dealloc];
}
#endif

- (BOOL) matchesBitfield: (AQBitfield *) bitfield
{
	return ( [_value isEqual: [bitfield bitfieldUsingMask: _mask]] );
}

- (BOOL) isEqual: (id) object
{
	if ( [object isKindOfClass: [self class]] == NO )
		return ( NO );
	
	AQStateMaskedEqualityMatchingDescriptor * other = (AQStateMaskedEqualityMatchingDescriptor *)object;
	
	NSMutableArray * myRanges = [NSMutableArray new];
	NSMutableArray * otherRanges = [NSMutableArray new];
	__block BOOL result = YES;
	
	@autoreleasepool
	{
		NSIndexSet * maskedMe   = [_matchingIndices indexSetMaskedWithIndexSet: _mask.indexSet];
		NSIndexSet * maskedThem = [other->_matchingIndices indexSetMaskedWithIndexSet: _mask.indexSet];
		
		[maskedMe enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			AQRange * rng = [[AQRange alloc] initWithRange: range];
			[myRanges addObject: rng];
#if !USING_ARC
			[rng release];
#endif
		}];
		[maskedThem enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			AQRange * rng = [[AQRange alloc] initWithRange: range];
			[otherRanges addObject: rng];
#if !USING_ARC
			[rng release];
#endif
		}];
		
		[myRanges enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			if ( [obj isEqual: [otherRanges objectAtIndex: idx]] == NO )
			{
				result = NO;
				*stop = YES;
				return;
			}
		}];
		
		if ( result )
			result = [_value isEqual: other->_value];
	}
	
#if !USING_ARC
	[myRanges release];
	[otherRanges release];
#endif
	
	return ( result );
}

- (NSComparisonResult) compare: (AQStateMaskedEqualityMatchingDescriptor *) other
{
	NSMutableArray * myRanges = [NSMutableArray new];
	NSMutableArray * otherRanges = [NSMutableArray new];
	__block NSComparisonResult result = NSOrderedSame;
	
	@autoreleasepool
	{
		NSIndexSet * maskedMe   = [_matchingIndices indexSetMaskedWithIndexSet: _mask.indexSet];
		NSIndexSet * maskedThem = [other->_matchingIndices indexSetMaskedWithIndexSet: _mask.indexSet];
		
		[maskedMe enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			AQRange * rng = [[AQRange alloc] initWithRange: range];
			[myRanges addObject: rng];
#if !USING_ARC
			[rng release];
#endif
		}];
		[maskedThem enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			AQRange * rng = [[AQRange alloc] initWithRange: range];
			[otherRanges addObject: rng];
#if !USING_ARC
			[rng release];
#endif
		}];
		
		[myRanges enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			NSComparisonResult r = [obj compare: [otherRanges objectAtIndex: idx]];
			if ( r != NSOrderedSame )
			{
				result = r;
				*stop = YES;
				return;
			}
		}];
		
		if ( result == NSOrderedSame )
			result = [_value compare: other->_value];
	}
	
#if !USING_ARC
	[myRanges release];
	[otherRanges release];
#endif
	
	return ( result );
}

@end

@implementation AQStateMaskedEqualityMatchingDescriptor (CreationConvenience)

- (id) initWithRange: (NSRange) range matchingValue: (AQBitfield *) value
{
	AQRange * rng = [[AQRange alloc] initWithRange: range];
	NSArray * ranges = [[NSArray alloc] initWithObjects: rng, nil];
	NSArray * values = [[NSArray alloc] initWithObjects: value, nil];
	self = [self initWithRanges: ranges masks: nil matchingValues: values];
	
#if !USING_ARC
	[rng release];
	[ranges release];
	[values release];
#endif
	
	return ( self );
}

- (id) initWith32BitValue: (UInt32) value forRange: (NSRange) range
{
	AQRange * rng = [[AQRange alloc] initWithRange: range];
	AQBitfield * bitfield = [[AQBitfield alloc] initWith32BitField: value];
	
	NSArray * ranges = [[NSArray alloc] initWithObjects: rng, nil];
	NSArray * values = [[NSArray alloc] initWithObjects: bitfield, nil];
	
	self = [self initWithRanges: ranges masks: nil matchingValues: values];
	
#if !USING_ARC
	[rng release];
	[bitfield release];
	[ranges release];
	[values release];
#endif
	
	return ( self );
}

- (id) initWith64BitValue: (UInt64) value forRange: (NSRange) range
{
	AQRange * rng = [[AQRange alloc] initWithRange: range];
	AQBitfield * bitfield = [[AQBitfield alloc] initWith64BitField: value];
	
	NSArray * ranges = [[NSArray alloc] initWithObjects: rng, nil];
	NSArray * values = [[NSArray alloc] initWithObjects: bitfield, nil];
	
	self = [self initWithRanges: ranges masks: nil matchingValues: values];
	
#if !USING_ARC
	[rng release];
	[bitfield release];
	[ranges release];
	[values release];
#endif
	
	return ( self );
}

- (id) initWithRange: (NSRange) range matchingValue: (AQBitfield *) value withMask: (AQBitfield *) mask
{
	AQRange * rng = [[AQRange alloc] initWithRange: range];
	
	@autoreleasepool
	{
		self = [self initWithRanges: [NSArray arrayWithObject: rng] masks: [NSArray arrayWithObject: mask] matchingValues: [NSArray arrayWithObject: value]];
	}
	
#if !USING_ARC
	[rng release];
#endif
	
	return ( self );
}

- (id) initWith32BitValue: (UInt32) value forRange: (NSRange) range matchingMask: (UInt32) mask
{
	AQBitfield * valueObj = [[AQBitfield alloc] initWith32BitField: value];
	AQBitfield * maskObj  = [[AQBitfield alloc] initWith32BitField: mask];
	
	self = [self initWithRange: range matchingValue: valueObj withMask: maskObj];
	
#if !USING_ARC
	[valueObj release];
	[maskObj release];
#endif
	
	return ( self );
}

- (id) initWith64BitValue: (UInt64) value forRange: (NSRange) range matchingMask: (UInt64) mask
{
	AQBitfield * valueObj = [[AQBitfield alloc] initWith64BitField: value];
	AQBitfield * maskObj  = [[AQBitfield alloc] initWith64BitField: mask];
	
	self = [self initWithRange: range matchingValue: valueObj withMask: maskObj];
	
#if !USING_ARC
	[valueObj release];
	[maskObj release];
#endif
	
	return ( self );
}

@end
