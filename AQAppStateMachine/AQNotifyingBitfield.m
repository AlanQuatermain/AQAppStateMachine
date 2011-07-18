//
//  AQNotifyingBitfield.m
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

#import "AQNotifyingBitfield.h"
#import "AQRange.h"
#import "MutableSortedDictionary.h"

@implementation AQNotifyingBitfield
{
	MutableSortedDictionary *	_lookup;
	dispatch_queue_t			_syncQ;
	dispatch_group_t			_group;
}

- (id) init
{
    self = [super init];
	if ( self == nil )
		return ( nil );
	
	_lookup = [MutableSortedDictionary new];
	_syncQ = dispatch_queue_create("net.alanquatermain.notifyingbitfield.sync", DISPATCH_QUEUE_SERIAL);
	
	return ( self );
}

- (void) dealloc
{
	if ( _syncQ != NULL )
		dispatch_release(_syncQ);
#if !USING_ARC
	[_lookup release];
	[super dealloc];
#endif
}

- (void) notifyModificationOfBitsInRange: (NSRange) range usingBlock: (AQRangeNotification) block
{
	dispatch_async(_syncQ, ^{
		AQRange * rangeObject = [[AQRange alloc] initWithRange: range];
		AQRangeNotification copied = [block copy];
		[_lookup setObject: copied forKey: rangeObject];
#if !USING_ARC
		[rangeObject release];
		[copied autorelease];
#endif
	});
}

- (void) removeNotifierForBitsInRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		AQRange * obj = [[AQRange alloc] initWithRange: range];
		[_lookup removeObjectForKey: obj];
#if !USING_ARC
		[obj release];
#endif
	});
}

- (void) removeAllNotifiersWithinRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		NSMutableSet * keys = [NSMutableSet new];
		
		[_lookup enumerateKeysAndObjectsUsingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
			NSRange testRange = [key range];
			if ( NSEqualRanges(testRange, NSIntersectionRange(range, testRange)) == NO )
			{
				if ( testRange.location > NSMaxRange(range) )
					*stop = YES;
				return;		// not wholly contained in the input range
			}
			
			[keys addObject: key];
		}];
		
		for ( id key in keys )
		{
			[_lookup removeObjectForKey: key];
		}
		
#if !USING_ARC
		[keys release];
#endif
	});
}

- (void) _updatedBitsInRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		[_lookup enumerateKeysAndObjectsUsingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
			if ( NSIntersectionRange(range, [key range]).length != 0 )
			{
				AQRangeNotification block = (AQRangeNotification)obj;
				if ( block != nil )
				{
					dispatch_async(dispatch_get_global_queue(0, 0), ^{ block([key range]); });
				}
			}
			else if ( NSMaxRange(range) < [key range].location )
			{
				*stop = YES;
			}
		}];
	});
}

@end
