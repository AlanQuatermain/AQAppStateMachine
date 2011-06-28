//
//  AQStateMatchingDescriptor.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-17.
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

#import "AQStateMatchingDescriptor.h"
#import "AQRange.h"
#import "AQBitfield.h"
#import "AQRangeMethods.h"

@implementation AQStateMatchingDescriptor

@synthesize uniqueID=_uuid;

- (id) initWithRanges: (NSArray *) ranges matchingMasks: (NSArray *) masks
{
	NSParameterAssert([masks count] == 0 || [ranges count] == [masks count]);
	
    self = [super init];
    if ( self == nil )
		return ( nil );
	
	// create a unique identifier
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
#if USING_ARC
	_uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
#else
	_uuid = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
#endif
	CFRelease(uuid);
	
	NSMutableIndexSet * indices = [NSMutableIndexSet new];
	[ranges enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		AQBitfield * mask = nil;
		NSRange range = [obj range];
		if ( [masks count] != 0 )
		{
			mask = [masks objectAtIndex: idx];
			if ( (id)mask == [NSNull null] )
				mask = nil;
		}
		
		if ( mask == nil )
		{
			[indices addIndexesInRange: range];
		}
		else
		{
			// have to iterate & check each bit against the mask
			for ( NSUInteger i = range.location, j=0; i < NSMaxRange(range); i++, j++ )
			{
				if ( [mask bitAtIndex: j] == 1 )
					[indices addIndex: i];
			}
		}
	}];
	
	_matchingIndices = [indices copy];
#if !USING_ARC
	[indices release];
#endif
    
    return ( self );
}

#if !USING_ARC
- (void) dealloc
{
	[_uuid release];
	[_matchingIndices release];
	[super dealloc];
}
#endif

- (NSRange) fullRange
{
	NSUInteger first = [_matchingIndices firstIndex];
	NSUInteger last = [_matchingIndices lastIndex];
	
	if ( first == NSNotFound )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( NSMakeRange(first, (last - first) + 1) );
}

- (BOOL) matchesRange: (NSRange) range
{
	return ( [_matchingIndices intersectsIndexesInRange: range] );
}

- (id) copyWithZone: (NSZone *) zone
{
	AQStateMatchingDescriptor * theCopy = [[[self class] alloc] init];
	theCopy->_uuid = [_uuid copy];
	theCopy->_matchingIndices = [_matchingIndices copy];
	return ( theCopy );
}

- (BOOL) isEqual: (id) object
{
	if ( [object isKindOfClass: [AQStateMatchingDescriptor class]] == NO )
		return ( NO );
	
	AQStateMatchingDescriptor * other = (AQStateMatchingDescriptor *)object;
	return ( [_matchingIndices isEqual: other->_matchingIndices] );
}

- (NSComparisonResult) compare: (AQStateMatchingDescriptor *) other
{
	__block NSUInteger otherIdx = [other->_matchingIndices firstIndex];
	__block NSComparisonResult result = NSOrderedSame;
	[_matchingIndices enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
		if ( idx == otherIdx )
		{
			otherIdx = [other->_matchingIndices indexGreaterThanIndex: otherIdx];
			return;		// continue comparison
		}
		else if ( otherIdx == NSNotFound )
		{
			result = NSOrderedDescending;
			*stop = YES;
			return;
		}
		
		result = (idx < otherIdx ? NSOrderedAscending : NSOrderedDescending);
		*stop = YES;
	}];
	
	if ( result != NSOrderedSame )
		return ( result );
	
	if ( otherIdx != NSNotFound )
		return ( NSOrderedAscending );
	
	return ( NSOrderedSame );
}

- (NSString *) description
{
	return ( [NSString stringWithFormat: @"%@{uniqueID=%@, matchingIndices=%@}", [super description], _uuid, _matchingIndices] );
}

@end

@implementation AQStateMatchingDescriptor (CreationConvenience)

- (id) initWithRange: (NSRange) range matchingMask: (AQBitfield *) mask
{
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: (mask ? [NSArray arrayWithObject: mask] : nil)] );
}

- (id) initWith32BitMask: (NSUInteger) mask forRange: (NSRange) range
{
	if ( mask == 0 )
		return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
						matchingMasks: nil] );
	
	AQBitfield * field = [[AQBitfield alloc] init];
#if !USING_ARC
	[field autorelease];
#endif
	for ( NSUInteger i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

- (id) initWith64BitMask: (UInt64) mask forRange: (NSRange) range
{
	if ( mask == 0 )
		return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
						matchingMasks: nil] );
	
	AQBitfield * field = [[AQBitfield alloc] init];
#if !USING_ARC
	[field autorelease];
#endif
	for ( UInt64 i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

@end
