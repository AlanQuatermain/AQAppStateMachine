//
//  AQNotifyingBitfield.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
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
}

- (void) notifyModificationOfBitsInRange: (NSRange) range usingBlock: (AQRangeNotification) block
{
	dispatch_async(_syncQ, ^{
		AQRange * rangeObject = [[AQRange alloc] initWithRange: range];
		[_lookup setObject: [block copy] forKey: rangeObject];
	});
}

- (void) removeNotifierForBitsInRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		AQRange * obj = [[AQRange alloc] initWithRange: range];
		[_lookup removeObjectForKey: obj];
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
	});
}

- (void) _scheduleNotificationsForIndex: (NSUInteger) index
{
	dispatch_async(_syncQ, ^{
		[_lookup enumerateKeysAndObjectsUsingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
			if ( NSLocationInRange(index, [key range]) )
			{
				AQRangeNotification block = (AQRangeNotification)obj;
				if ( block != nil )
				{
					dispatch_async(dispatch_get_global_queue(0, 0), ^{ block([key range]); });
				}
			}
			else if ( index < [key range].location )
			{
				*stop = YES;
			}
		}];
	});
}

- (void) _scheduleNotificationsForRange: (NSRange) range
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

- (void) flipBitAtIndex: (NSUInteger) index
{
	[super flipBitAtIndex: index];
	[self _scheduleNotificationsForIndex: index];
}

- (void) flipBitsInRange: (NSRange) range
{
	[super flipBitsInRange: range];
	[self _scheduleNotificationsForRange: range];
}

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index
{
	[super setBit: bit atIndex: index];
	[self _scheduleNotificationsForIndex: index];
}

- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit
{
	[super setBitsInRange: range usingBit: bit];
	[self _scheduleNotificationsForRange: range];
}

- (void) setAllBits: (AQBit) bit
{
	[super setAllBits: bit];
	
	// always scheduling for all bits
	dispatch_async(_syncQ, ^{
		[_lookup enumerateKeysAndObjectsUsingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
			AQRangeNotification block = (AQRangeNotification)obj;
			dispatch_async(dispatch_get_global_queue(0, 0), ^{ block([key range]); });
		}];
	});
}

@end
