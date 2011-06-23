//
//  AQRangeMethods.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
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
		
		if ( group != NULL )
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
	
	if ( group != NULL )
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (NSUInteger) numberOfRanges
{
	__block NSUInteger result = 0;
	[self enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) { result += 1; }];
	return ( result );
}

@end
