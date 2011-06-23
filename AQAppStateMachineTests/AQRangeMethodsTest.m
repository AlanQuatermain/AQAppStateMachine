//
//  AQRangeMethodsTest.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-23.
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

#import "AQRangeMethodsTest.h"
#import "AQRangeMethods.h"
#import "AQRange.h"

@implementation AQRangeMethodsTest

@synthesize indexSet;

- (void) setUp
{
	NSMutableIndexSet * set = [NSMutableIndexSet indexSet];
	[set addIndexesInRange: NSMakeRange(0, 5)];
	[set addIndexesInRange: NSMakeRange(10, 5)];
	[set addIndexesInRange: NSMakeRange(20, 10)];
	[set addIndexesInRange: NSMakeRange(30, 5)];		// should merge with previous range
	self.indexSet = set;
}

// these tests work by comparing against the official 10.7/5.0 version of the API we're emulating for 10.6/4.0
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0

- (void) testEnumerateRanges
{
	NSMutableArray * appleResults = [NSMutableArray array];
	NSMutableArray * aqResults = [NSMutableArray array];
	
	[self.indexSet enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[appleResults addObject: r];
	}];
	
	[self.indexSet aq_enumerateRangesUsingBlock: ^(NSRange range, BOOL *stop) {
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[aqResults addObject: r];
	}];
	
	STAssertEqualObjects(appleResults, aqResults, @"Expected indexSet %@ to contain ranges %@, but got %@", self.indexSet, appleResults, aqResults);
}

- (void) testReverseEnumerateRanges
{
	NSMutableArray * appleResults = [NSMutableArray array];
	NSMutableArray * aqResults = [NSMutableArray array];
	
	[self.indexSet enumerateRangesWithOptions: NSEnumerationReverse usingBlock: ^(NSRange range, BOOL *stop) {
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[appleResults addObject: r];
	}];
	
	[self.indexSet aq_enumerateRangesWithOptions: NSEnumerationReverse usingBlock: ^(NSRange range, BOOL *stop) {
		AQRange * r = [[AQRange alloc] initWithRange: range];
		[aqResults addObject: r];
	}];
	
	STAssertEqualObjects(appleResults, aqResults, @"Expected indexSet %@ to contain reversed ranges %@, but got %@", self.indexSet, appleResults, aqResults);
}

#endif

- (void) testNumberOfRanges
{
	STAssertTrue([self.indexSet numberOfRanges] == 3, @"Expected %@ to contain 3 ranges, instead has %lu", self.indexSet, (unsigned long)[self.indexSet numberOfRanges]);
}

@end
