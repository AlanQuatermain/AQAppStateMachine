//
//  AQRangeTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
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
