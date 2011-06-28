//
//  AQIndexSetMasking.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-28.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQIndexSetMasking.h"

@implementation NSIndexSet (AQIndexSetMasking)

- (NSIndexSet *) indexSetMaskedWithIndexSet: (NSIndexSet *) mask
{
	NSMutableIndexSet * mutable = [self mutableCopy];
	
	@autoreleasepool
	{
		[self enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			NSUInteger overlap = [mask countOfIndexesInRange: range];
			if ( overlap == 0 )
			{
				[mutable removeIndexesInRange: range];
			}
			else if ( overlap != range.length )
			{
				// scan through these indexes
				[self enumerateIndexesInRange: range options: 0 usingBlock: ^(NSUInteger idx, BOOL *stop) {
					if ( [mask containsIndex: idx] == NO )
						[mutable removeIndex: idx];
				}];
			}
		}];
		
		if ( [mask firstIndex] > 0 )
		{
			[mutable removeIndexesInRange: NSMakeRange(0, [mask firstIndex])];
		}
		if ( [mask lastIndex] < [mutable lastIndex] )
		{
			[mutable removeIndexesInRange: NSMakeRange([mask lastIndex]+1, NSNotFound - [mask lastIndex]+1)];
		}
	}
	
#if USING_ARC
	return ( [mutable copy] );
#else
	NSIndexSet * result = [mutable copy];
	[mutable release];
	return ( [result autorelease] );
#endif
}

@end

@implementation NSMutableIndexSet (AQIndexSetMasking)

- (void) maskWithIndexSet: (NSIndexSet *) mask
{
	@autoreleasepool
	{
		NSMutableIndexSet * removals = [NSMutableIndexSet indexSet];
		[self enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
			NSUInteger overlap = [mask countOfIndexesInRange: range];
			if ( overlap == 0 )
			{
				[removals addIndexesInRange: range];
			}
			else if ( overlap != range.length )
			{
				// scan through these indexes
				[self enumerateIndexesInRange: range options: 0 usingBlock: ^(NSUInteger idx, BOOL *stop) {
					if ( [mask containsIndex: idx] == NO )
						[removals addIndex: idx];
				}];
			}
		}];
		
		[self removeIndexes: removals];
	}
}

@end
