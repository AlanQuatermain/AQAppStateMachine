//
//  AQSimpleBitTestPredicate.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQSimpleBitTestPredicate.h"

@implementation AQSimpleBitTestPredicate

- (id) initWithBitValue: (AQBit) value atIndex: (NSUInteger) index
{
    self = [super init];
	if ( self == nil )
		return ( nil );
	
	_index = index;
	_value = value;
	
	return ( self );
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
	self = [super initWithCoder: aDecoder];
	if ( self == nil )
		return ( nil );
	
	_index = [aDecoder decodeIntegerForKey: @"aq.index"];
	_value = [aDecoder decodeIntegerForKey: @"aq.value"];
	
	return ( self );
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
	[super encodeWithCoder: aCoder];
	
	[aCoder encodeInteger: _index forKey: @"aq.index"];
	[aCoder encodeInteger: _value forKey: @"aq.value"];
}

- (id) copyWithZone: (NSZone *) zone
{
	return ( [[[self class] alloc] initWithBitValue: _value atIndex: _index] );
}

- (BOOL) evaluateWithObject: (id) object
{
	NSParameterAssert([object isKindOfClass: [AQBitfield class]]);
	AQBitfield * bitfield = (AQBitfield *)object;
	
	return ( [bitfield bitAtIndex: _index] == _value );
}

- (BOOL) evaluateWithObject: (id) object substitutionVariables: (NSDictionary *) bindings
{
	[NSException raise: NSInternalInconsistencyException format: @"%@ doesn't support the use of substitution variables."];
	return ( NO );
}

- (NSString *) predicateFormat
{
	// this is used in NSPredicate's description method
	return ( [NSString stringWithFormat: @"BITFIELD[%u] == %u", _index, _value] );
}

@end
