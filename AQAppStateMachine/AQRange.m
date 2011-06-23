//
//  AQRange.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Kobo Inc. All rights reserved.
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
