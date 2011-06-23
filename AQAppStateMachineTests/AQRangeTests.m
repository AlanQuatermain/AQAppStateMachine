//
//  AQRangeTests.m
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

#import "AQRangeTests.h"
#import "AQRange.h"

@implementation AQRangeTests

- (void) testEquality
{
	AQRange * range = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * equal = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * fail  = [[AQRange alloc] initWithRange: NSMakeRange(0, 20)];
	
	STAssertEqualObjects(range, equal, @"Expected %@ to equal %@", range, equal);
	STAssertFalse([range isEqual: fail], @"Expected %@ to NOT equal %@", range, fail);
	STAssertFalse([range isEqual: @"Hello"], @"Expected %@ to NOT equal the string 'Hello'", range);
	STAssertTrue([range isEqualToNSRange: equal.range], @"Expected %@ to equal %@", range, NSStringFromRange(equal.range));
	STAssertFalse([range isEqualToNSRange: fail.range], @"Expected %@ to NOT equal %@", range, fail.range);
}

- (void) testComparisons
{
	AQRange * range = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * equal = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * higherForLength = [[AQRange alloc] initWithRange: NSMakeRange(0, 20)];
	AQRange * higherForLocation = [[AQRange alloc] initWithRange: NSMakeRange(10, 10)];
	
	STAssertTrue([range compare: equal] == NSOrderedSame, @"Expected comparison of %@ to %@ to return 'same', got %lu", range, equal, (unsigned long)[range compare: equal]);
	STAssertTrue([range compare: higherForLength] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", range, higherForLength, (unsigned long)[range compare: higherForLength]);
	STAssertTrue([higherForLength compare: range] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", higherForLength, range, (unsigned long)[higherForLength compare: range]);
	STAssertTrue([range compare: higherForLocation] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", range, higherForLocation, (unsigned long)[range compare: higherForLocation]);
	STAssertTrue([higherForLocation compare: range] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", higherForLocation, range, (unsigned long)[higherForLocation compare: range]);
	STAssertTrue([range compareToNSRange: higherForLength.range] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", range, NSStringFromRange(higherForLength.range), (unsigned long)[range compareToNSRange: higherForLength.range]);
}

@end
