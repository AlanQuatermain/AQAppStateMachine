//
//  AQStateMatchingDescriptor.m
//  
//
//  Created by Jim Dovey on 11-06-27.
//  Copyright 2011 Kobo Inc. All rights reserved.
//

#import "AQStateMatchingDescriptor.h"
#import "AQRange.h"

@implementation AQStateMatchingDescriptor

@synthesize uniqueID=_uuid;

- (id) initWithRanges: (NSArray *) ranges
{
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
		[indices addIndexesInRange: [obj range]];
	}];
	
	_matchingIndices = [indices copy];
#if !USING_ARC
	[indices release];
#endif
	
	return ( self );
}

- (id) initWithRange: (NSRange) range
{
	AQRange * rng = [[AQRange alloc] initWithRange: range];
	NSArray * ranges = [[NSArray alloc] initWithObjects:rng, nil];
	
	self = [self initWithRanges: ranges];
	
#if !USING_ARC
	[rng release];
	[ranges release];
#endif
	
	return ( self );
}

#if !USING_ARC
- (void) dealloc
{
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
	return ( [_matchingIndices countOfIndexesInRange: range] > 0 );
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

- (id) copyWithZone: (NSZone *) zone
{
	AQStateMatchingDescriptor * result = [[[self class] alloc] init];
	result->_matchingIndices = [_matchingIndices copyWithZone: zone];
	return ( result );
}

@end
