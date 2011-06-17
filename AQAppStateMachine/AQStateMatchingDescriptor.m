//
//  AQStateMatchingDescriptor.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-17.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQStateMatchingDescriptor.h"
#import "AQRange.h"
#import "AQBitfield.h"

@implementation AQStateMatchingDescriptor

@synthesize uniqueID=_uuid;

- (id) initWithRanges: (NSIndexSet *) ranges matchingMasks: (NSArray *) masks
{
	NSParameterAssert([masks count] == 0 || [ranges count] == [masks count]);
	
    self = [super init];
    if ( self == nil )
		return ( nil );
	
	// create a unique identifier
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	_uuid = objc_retainedObject(CFUUIDCreateString(kCFAllocatorDefault, uuid));
	CFRelease(uuid);
	
	NSMutableIndexSet * indices = [NSMutableIndexSet new];
	__block NSUInteger idx = 0;
	[ranges enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
		AQBitfield * mask = nil;
		if ( [masks count] != 0 )
		{
			mask = [masks objectAtIndex: idx++];
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
    
    return ( self );
}

- (BOOL) matchesRange: (NSRange) range
{
	return ( [_matchingIndices countOfIndexesInRange: range] > 0 );
}

@end

@implementation AQStateMatchingDescriptor (CreationConvenience)

- (id) initWithRange: (NSRange) range matchingMask: (AQBitfield *) mask
{
	return ( [self initWithRanges: [NSIndexSet indexSetWithIndexesInRange: range]
					matchingMasks: [NSArray arrayWithObject: mask]] );
}

- (id) initWith32BitMask: (NSUInteger) mask forRange: (NSRange) range
{
	AQBitfield * field = [[AQBitfield alloc] initWithSize: 32];
	for ( NSUInteger i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSIndexSet indexSetWithIndexesInRange: range]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

- (id) initWith64BitMask: (UInt64) mask forRange: (NSRange) range
{
	AQBitfield * field = [[AQBitfield alloc] initWithSize: 64];
	for ( UInt64 i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSIndexSet indexSetWithIndexesInRange: range]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

@end
