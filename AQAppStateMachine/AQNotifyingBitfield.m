//
//  AQNotifyingBitfield.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQNotifyingBitfield.h"
#import "AQRange.h"

@implementation AQNotifyingBitfield
{
	id						_order;		// NSMutableArray or NSMutableOrderedSet (if available)
	NSMutableDictionary *	_lookup;
	dispatch_queue_t		_syncQ;
}

- (id) initWithSize: (NSUInteger) numberOfBits
{
    self = [super initWithSize: numberOfBits];
	if ( self == nil )
		return ( nil );
	
	if ( [NSMutableOrderedSet self] )
		_order = [NSMutableOrderedSet new];
	else
		_order = [NSMutableArray new];
	
	_lookup = [NSMutableDictionary new];
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
		NSUInteger existingIdx = [_order indexOfObject: rangeObject];
		if ( existingIdx == NSNotFound )
		{
			[_order addObject: rangeObject];
			[_order sortUsingSelector: @selector(compare:)];
		}
		
		[_lookup setObject: [block copy] forKey: rangeObject];
	});
}

- (void) removeNotifierForBitsInRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		AQRange * obj = [[AQRange alloc] initWithRange: range];
		[_order removeObject: obj];
		[_lookup removeObjectForKey: obj];
	});
}

- (void) removeAllNotifiersWithinRange: (NSRange) range
{
	dispatch_async(_syncQ, ^{
		NSMutableIndexSet * indicesToRemove = [NSMutableIndexSet indexSet];
		
		[_order enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			NSRange testRange = [obj range];
			if ( NSEqualRanges(testRange, NSIntersectionRange(range, testRange)) == NO )
			{
				if ( testRange.location > NSMaxRange(range) )
					*stop = YES;
				return;		// not wholly contained in the input range
			}
			
			[indicesToRemove addIndex: idx];
			[_lookup removeObjectForKey: obj];
		}];
		
		[_order removeObjectsAtIndexes: indicesToRemove];
	});
}

- (void) _scheduleNotificationForRange: (AQRange *) range
{
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		AQRangeNotification block = (AQRangeNotification)[_lookup objectForKey: range];
		if ( block != nil )
			block(range.range);
	});
}

- (void) flipBitAtIndex: (NSUInteger) index
{
	[super flipBitAtIndex: index];
	
	dispatch_async(_syncQ, ^{
		[_order enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			if ( NSLocationInRange(index, [obj range]) )
			{
				[self _scheduleNotificationForRange: obj];
			}
			else if ( index < [obj range].location )
			{
				*stop = YES;
			}
		}];
	});
}

- (void) flipBitsInRange: (NSRange) range
{
	[super flipBitsInRange: range];
	
	dispatch_async(_syncQ, ^{
		[_order enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			if ( NSIntersectionRange(range, [obj range]).location != NSNotFound )
			{
				[self _scheduleNotificationForRange: obj];
			}
			else if ( NSMaxRange(range) < [obj range].location )
			{
				*stop = YES;
			}
		}];
	});
}

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index
{
	[super setBit: bit atIndex: index];
	
	dispatch_async(_syncQ, ^{
		[_order enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			if ( NSLocationInRange(index, [obj range]) )
			{
				[self _scheduleNotificationForRange: obj];
			}
			else if ( index < [obj range].location )
			{
				*stop = YES;
			}
		}];
	});
}

- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit
{
	[super setBitsInRange: range usingBit: bit];
	
	dispatch_async(_syncQ, ^{
		[_order enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
			if ( NSIntersectionRange(range, [obj range]).location != NSNotFound )
			{
				[self _scheduleNotificationForRange: obj];
			}
			else if ( NSMaxRange(range) < [obj range].location )
			{
				*stop = YES;
			}
		}];
	});
}

- (void) setAllBits: (AQBit) bit
{
	[super setAllBits: bit];
	
	// always scheduling for all bits
	dispatch_async(_syncQ, ^{
		[_lookup enumerateKeysAndObjectsUsingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
			[self _scheduleNotificationForRange: obj];
		}];
	});
}

@end
