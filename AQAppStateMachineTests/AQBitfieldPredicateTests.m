//
//  AQBitfieldPredicateTests.m
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

#import "AQBitfieldPredicateTests.h"
#import "AQBitfield.h"
#import "AQBitfieldPredicates.h"

@implementation AQBitfieldPredicateTests
@synthesize bitfield;

- (void) setUp
{
	AQBitfield * tmp = [AQBitfield new];
	[tmp setBitsInRange: NSMakeRange(0, 10) usingBit: 1];
	[tmp setBit: 1 atIndex: 15];
	[tmp setBit: 1 atIndex: 20];
	self.bitfield = tmp;
}

- (void) testMatchingBitValueAtIndex
{
	NSPredicate * yes1 = [NSPredicate predicateForMatchingBitValue: 1 atIndex: 5];
	NSPredicate * yes2 = [NSPredicate predicateForMatchingBitValue: 0 atIndex: 10];
	NSPredicate * no1  = [NSPredicate predicateForMatchingBitValue: 1 atIndex: 10];
	NSPredicate * no2  = [NSPredicate predicateForMatchingBitValue: 0 atIndex: 5];
	
	STAssertTrue([yes1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes1);
	STAssertTrue([yes2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes2);
	STAssertFalse([no1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no1);
	STAssertFalse([no2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no2);
}

- (void) testMatchingAllBitsInRange
{
	NSPredicate * yes1 = [NSPredicate predicateForMatchingAllBits: 0xF inRange: NSMakeRange(0, 4)];
	NSPredicate * yes2 = [NSPredicate predicateForMatchingAllBits: 0x0 inRange: NSMakeRange(21, 4)];
	NSPredicate * no1  = [NSPredicate predicateForMatchingAllBits: 0xF inRange: NSMakeRange(15, 4)];
	NSPredicate * no2  = [NSPredicate predicateForMatchingAllBits: 0x0 inRange: NSMakeRange(20, 4)];
	
	STAssertTrue([yes1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes1);
	STAssertTrue([yes2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes2);
	STAssertFalse([no1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no1);
	STAssertFalse([no2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no2);
}

- (void) testMatchingBitfieldAgainstRange
{
	AQBitfield * test1 = [AQBitfield new];
	[test1 setBitsInRange: NSMakeRange(0, 5) usingBit: 1];
	
	AQBitfield * test0 = [AQBitfield new];
	
	NSPredicate * yes1 = [NSPredicate predicateForMatchingBitfield: test1 againstRange: NSMakeRange(0, 5)];
	NSPredicate * yes2 = [NSPredicate predicateForMatchingBitfield: test0 againstRange: NSMakeRange(21, 5)];
	NSPredicate * no1  = [NSPredicate predicateForMatchingBitfield: test1 againstRange: NSMakeRange(20, 5)];
	NSPredicate * no2  = [NSPredicate predicateForMatchingBitfield: test0 againstRange: NSMakeRange(0, 5)];
	
	STAssertTrue([yes1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes1);
	STAssertTrue([yes2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes2);
	STAssertFalse([no1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no1);
	STAssertFalse([no2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no2);
}

- (void) testMatchingWithMaskAndRange
{
	NSUInteger value = 0xF;
	NSUInteger mask = 0x3;
	
	NSPredicate * yes1 = [NSPredicate predicateForMatchingBits: value maskedWith: mask inRange: NSMakeRange(0, 4)];
	NSPredicate * yes2 = [NSPredicate predicateForMatchingBits: value maskedWith: mask inRange:NSMakeRange(8, 4)];
	NSPredicate * no1  = [NSPredicate predicateForMatchingBits: value maskedWith: mask inRange:NSMakeRange(10, 4)];
	NSPredicate * no2  = [NSPredicate predicateForMatchingBits: value maskedWith: mask inRange: NSMakeRange(9, 4)];
	
	STAssertTrue([yes1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes1);
	STAssertTrue([yes2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes2);
	STAssertFalse([no1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no1);
	STAssertFalse([no2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no2);
}

- (void) testMatchingBitfieldWithMaskAndRange
{
	AQBitfield * test1 = [AQBitfield new];
	[test1 setBitsInRange: NSMakeRange(0, 5) usingBit: 1];
	
	AQBitfield * test0 = [AQBitfield new];
	
	AQBitfield * mask = [AQBitfield new];
	[mask setBitsInRange: NSMakeRange(1, 4) usingBit: 1];
	
	NSPredicate * yes1 = [NSPredicate predicateForMatchingBitfield: test1 maskedWith: mask againstRange: NSMakeRange(0, 5)];
	NSPredicate * yes2 = [NSPredicate predicateForMatchingBitfield: test0 maskedWith: mask againstRange: NSMakeRange(15, 5)];
	NSPredicate * no1  = [NSPredicate predicateForMatchingBitfield: test1 maskedWith: mask againstRange: NSMakeRange(15, 5)];
	NSPredicate * no2  = [NSPredicate predicateForMatchingBitfield: test0 maskedWith: mask againstRange: NSMakeRange(18, 5)];
	
	STAssertTrue([yes1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes1);
	STAssertTrue([yes2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ to match predicate %@", self.bitfield, yes2);
	STAssertFalse([no1 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no1);
	STAssertFalse([no2 evaluateWithObject: self.bitfield], @"Expected bitfield %@ NOT to match predicate %@", self.bitfield, no2);
}

@end
