//
//  AQBitfieldPredicateTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
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
