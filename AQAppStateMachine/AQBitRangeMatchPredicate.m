//
//  AQBitRangeMatchPredicate.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQBitRangeMatchPredicate.h"
#import "AQBitfield.h"

@implementation AQBitRangeMatchPredicate

- (id) initWithRange: (NSRange) range value: (NSUInteger) value
{
    self = [super init];
	if ( self == nil )
		return ( nil );
	
	_range = range;
	_value = value;
	
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super initWithCoder: aDecoder];
	if ( self == nil )
		return ( nil );
	
	_range = [[aDecoder decodeObjectForKey: @"aq.range"] rangeValue];
	_value = [aDecoder decodeIntegerForKey: @"aq.value"];
	
	return ( self );
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
	[super encodeWithCoder: aCoder];
	
	[aCoder encodeObject: [NSValue valueWithRange: _range] forKey: @"aq.range"];
	[aCoder encodeInteger: _value forKey: @"aq.value"];
}

- (id) copyWithZone: (NSZone *) zone
{
	return ( [[[self class] alloc] initWithRange: _range value: _value] );
}

- (BOOL) evaluateWithObject: (id) object
{
	NSParameterAssert([object isKindOfClass: [AQBitfield class]]);
	AQBitfield * bitfield = (AQBitfield *)object;
	
	return ( [bitfield bitsInRange: _range matchBits: _value] );
}

- (BOOL) evaluateWithObject: (id) object substitutionVariables: (NSDictionary *) bindings
{
	[NSException raise: NSInternalInconsistencyException format: @"%@ doesn't support the use of substitution variables."];
	return ( NO );
}

- (NSString *) predicateFormat
{
	// this is used in NSPredicate's description method
	return ( [NSString stringWithFormat: @"BITFIELD[%u..%u] == %#x", _range.location, NSMaxRange(_range), _value] );
}

@end
