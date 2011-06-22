//
//  AQStateMatchingDescriptorTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQStateMatchingDescriptorTests.h"
#import "AQStateMatchingDescriptor.h"
#import "AQBitfield.h"
#import "AQRange.h"

@implementation AQStateMatchingDescriptorTests

- (void) testUniqueIDs
{
	AQStateMatchingDescriptor * desc1 = [[AQStateMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 10) matchingMask: nil];
	AQStateMatchingDescriptor * desc2 = [[AQStateMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 10) matchingMask: nil];
	
	STAssertTrue([desc1.uniqueID isEqualToString: desc2.uniqueID] == NO, @"Descriptor unique IDs are supposed to be *unique*, dammit!");
}

- (void) testSingleRangeAndMask
{
	AQBitfield * mask = [AQBitfield new];
	[mask setBitsInRange: NSMakeRange(0, 6) usingBit: 1];
	
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 20) matchingMask: mask];
	STAssertNotNil(desc, @"Expected to be able to at least create an object!");
	
	NSRange yes = NSMakeRange(0, 6);
	NSRange no  = NSMakeRange(10, 5);
	STAssertTrue([desc matchesRange: yes], @"Expected range %@ to match descriptor %@", NSStringFromRange(yes), desc);
	STAssertFalse([desc matchesRange: no], @"Expected range %@ to NOT match descriptor %@", NSStringFromRange(no), desc);
}

- (void) testMultipleRangesWithMasks
{
	NSRange range1 = NSMakeRange(0, 20);
	AQBitfield * mask1 = [AQBitfield new];
	[mask1 setBitsInRange: NSMakeRange(0, 6) usingBit: 1];
	
	NSRange range2 = NSMakeRange(25, 5);
	AQBitfield * mask2 = [AQBitfield new];
	[mask2 setBitsInRange: NSMakeRange(0, 4) usingBit: 1];
	
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRanges: [NSArray arrayWithObjects: [[AQRange alloc] initWithRange: range1], [[AQRange alloc] initWithRange: range2], nil] matchingMasks: [NSArray arrayWithObjects: mask1, mask2, nil]];
	
	NSRange yes = NSMakeRange(0, 6);
	NSRange no  = NSMakeRange(29, 1);
	STAssertTrue([desc matchesRange: yes], @"Expected range %@ to match descriptor %@", NSStringFromRange(yes), desc);
	STAssertFalse([desc matchesRange: no], @"Expected range %@ to NOT match descriptor %@", NSStringFromRange(no), desc);
}

- (void) testComparisons
{
	NSRange range = NSMakeRange(0, 10);
	NSRange equal = NSMakeRange(0, 10);
	NSRange higherForLength = NSMakeRange(0, 20);
	NSRange higherForLocation = NSMakeRange(10, 10);
	
	AQStateMatchingDescriptor * descRange = [[AQStateMatchingDescriptor alloc] initWithRange: range matchingMask: nil];
	AQStateMatchingDescriptor * descEqual = [[AQStateMatchingDescriptor alloc] initWithRange: equal matchingMask: nil];
	AQStateMatchingDescriptor * descLength = [[AQStateMatchingDescriptor alloc] initWithRange: higherForLength matchingMask: nil];
	AQStateMatchingDescriptor * descLocation = [[AQStateMatchingDescriptor alloc] initWithRange: higherForLocation matchingMask: nil];
	
	STAssertTrue([descRange compare: descEqual] == NSOrderedSame, @"Expected comparison of %@ to %@ to return 'same', got %lu", descRange, descEqual, (unsigned long)[descRange compare: descEqual]);
	STAssertTrue([descRange compare: descLength] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descRange, descLength, (unsigned long)[descRange compare: descLength]);
	STAssertTrue([descLength compare: descRange] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descLength, descRange, (unsigned long)[descLength compare: descRange]);
	STAssertTrue([descRange compare: descLocation] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descRange, descLocation, (unsigned long)[descRange compare: descLocation]);
	STAssertTrue([descLocation compare: descRange] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descLocation, descRange, (unsigned long)[descLocation compare: descRange]);
}

- (void) testFullRange
{
	AQRange * r1 = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * r2 = [[AQRange alloc] initWithRange: NSMakeRange(15, 5)];
	NSRange totalRange = NSMakeRange(0, 20);
	
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRanges: [NSArray arrayWithObjects: r1, r2, nil] matchingMasks: nil];
	STAssertTrue(NSEqualRanges(totalRange, desc.fullRange), @"Expected total range of %@ to be %@, got %@", desc, NSStringFromRange(totalRange), NSStringFromRange(desc.fullRange));
}

@end
