//
//  AQRangeMethods.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQRangeMethods.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void DuplicateMethod(Class cls, SEL from, SEL to)
{
	Method fromMethod = class_getInstanceMethod(cls, from);
	const char * types = method_getTypeEncoding(fromMethod);
	class_addMethod(cls, to, method_getImplementation(fromMethod), types);
}

@implementation NSIndexSet (AQRangeMethods)

+ (void) load
{
	if ( [self instancesRespondToSelector: @selector(enumerateRangesUsingBlock:)] )
		return;
	
	DuplicateMethod(self, @selector(aq_enumerateRangesUsingBlock:), @selector(enumerateRangesUsingBlock:));
	DuplicateMethod(self, @selector(aq_enumerateRangesWithOptions:usingBlock:), @selector(enumerateRangesWithOptions:usingBlock:));
	DuplicateMethod(self, @selector(aq_enumerateRangesInRange:options:usingBlock:), @selector(enumerateRangesInRange:options:usingBlock:));
}

- (void)aq_enumerateRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block
{
	[self enumerateRangesInRange: NSMakeRange(0, NSNotFound) options: 0 usingBlock: block];
}

- (void)aq_enumerateRangesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block
{
	[self enumerateRangesInRange: NSMakeRange(0, NSNotFound) options: opts usingBlock: block];
}

- (void)aq_enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block
{
	__block NSUInteger rangeStartIndex = NSNotFound;
	__block NSUInteger currentIndex = NSNotFound;
	
	dispatch_group_t group = NULL;
	if ( (opts & NSEnumerationConcurrent) == NSEnumerationConcurrent)
		group = dispatch_group_create();
	
	BOOL (^isContiguous)(NSUInteger) = ^BOOL(NSUInteger idx) { return ( idx == currentIndex+1 ); };
	if ( (opts & NSEnumerationReverse) == NSEnumerationReverse )
	{
		isContiguous = ^BOOL(NSUInteger idx) { return ( idx == currentIndex-1 ); };
	}
	
	[self enumerateIndexesInRange: range options: opts usingBlock: ^(NSUInteger idx, BOOL *stop) {
		if ( currentIndex == NSNotFound )
		{
			rangeStartIndex = idx;
			currentIndex = idx;
			return;
		}
		
		if ( isContiguous(idx) )
			return;
		
		// create a range
		NSRange range;
		if ( (opts & NSEnumerationReverse) == NSEnumerationReverse )
		{
			range.location = currentIndex;
			range.length = (rangeStartIndex - currentIndex) + 1;
		}
		else
		{
			range.location = rangeStartIndex;
			range.length = (currentIndex - rangeStartIndex) + 1;
		}
		
		if ( (opts & NSEnumerationConcurrent) == NSEnumerationConcurrent )
		{
			dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{ block(range, stop); });
		}
		else
		{
			block(range, stop);
		}
		
		currentIndex = idx;
		rangeStartIndex = idx;
	}];
}

- (NSUInteger) numberOfRanges
{
	__block NSUInteger result = 0;
	[self enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) { result += 1; }];
	return ( result );
}

@end
