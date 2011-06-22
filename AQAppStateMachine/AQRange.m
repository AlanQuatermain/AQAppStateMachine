//
//  AQRange.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Kobo Inc. All rights reserved.
//

#import "AQRange.h"

@implementation AQRange

@synthesize range=_range;

- (id) init
{
    return ( [self initWithRange: NSMakeRange(0, 0)] );
}

- (id) initWithRange: (NSRange) range
{
	self = [super init];
	if ( self == nil )
		return ( nil );
	
	_range = range;
	
	return ( self );
}

- (NSString *) description
{
	return ( NSStringFromRange(_range) );
}

- (id) copyWithZone: (NSZone *) zone
{
	return ( [[AQRange alloc] initWithRange: _range] );
}

- (NSUInteger) hash
{
	return ( _range.location << 16 | _range.length );
}

- (BOOL) isEqual: (id) object
{
	if ( [object isKindOfClass: [self class]] == NO )
		return ( NO );
	
	AQRange * other = (AQRange *)object;
	return ( NSEqualRanges(_range, other->_range) );
}

- (BOOL) isEqualToNSRange: (NSRange) nsRange
{
	return ( NSEqualRanges(_range, nsRange) );
}

- (NSComparisonResult) compare: (AQRange *) other
{
	return ( [self compareToNSRange: other->_range] );
}

- (NSComparisonResult) compareToNSRange: (NSRange) nsRange
{
	if ( NSEqualRanges(_range, nsRange) )
		return ( NSOrderedSame );
	
	if ( _range.location < nsRange.location )
		return ( NSOrderedAscending );
	else if ( _range.location > nsRange.location )
		return ( NSOrderedDescending );
	
	// locations are identical, but lengths are not
	// in this case, we order by which is *finished* first, i.e. one with the lowest length
	if ( _range.length < nsRange.length )
		return ( NSOrderedAscending );
	
	return ( NSOrderedDescending );
}

@end
