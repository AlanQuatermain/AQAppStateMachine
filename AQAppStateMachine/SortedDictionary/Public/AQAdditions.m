//
//  AQAdditions.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-20.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "SortedDictionary.h"
#import "SortedDictionary+Private.h"
#import "Node.h"
#import "AvlTree.h"

@implementation SortedDictionary (AQAdditions)

#if NS_BLOCKS_AVAILABLE

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0)
{
	[self enumerateKeysAndObjectsWithOptions: 0 usingBlock: block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0)
{
	dispatch_group_t group = NULL;
	
	if ( (opts & NSEnumerationConcurrent) == NSEnumerationConcurrent )
		group = dispatch_group_create();
	
	NSEnumerator * enumerator = ((opts & NSEnumerationReverse) == NSEnumerationReverse) ? [tree reverseEntryEnumerator] : [tree entryEnumerator];
	__block BOOL stop = NO;
	Node * node = nil;
	
	while ( (stop == NO) && ((node = [enumerator nextObject]) != nil) )
	{
		if ( group != NULL )
		{
			dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
				block(node.key, node.value, &stop);
			});
		}
		else
		{
			block(node.key, node.value, &stop);
		}
	}
	
	if ( group != NULL )
	{
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
		dispatch_release(group);
	}
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0)
{
	return ( [self keysOfEntriesWithOptions: 0 passingTest: predicate] );
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0)
{
	NSMutableSet * set = [NSMutableSet set];
	[self enumerateKeysAndObjectsWithOptions: opts usingBlock: ^(__strong id key, __strong id obj, BOOL *stop) {
		if ( predicate(key, obj, stop) )
			[set addObject: key];
	}];
	
	return ( set );
}

#endif

@end
