//
//  AQBitfieldTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-20.
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

#import "AQBitfieldTests.h"
#import "AQBitfield.h"

@implementation AQBitfieldTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) testSetBits
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBit: 1 atIndex: 42];
	STAssertTrue(bitfield.count == 43, @"Bitfield with one bit set at index 42 should have a count of 43");
	STAssertTrue([bitfield bitAtIndex: 42] == 1, @"Failed to store bit at index 42");
}

- (void) testSetBitsInRange
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(42, 20);
	[bitfield setBitsInRange: rng usingBit: 1];
	STAssertTrue(bitfield.count == NSMaxRange(rng), @"Bitfield's count should be equal to the index of the highest set bit plus one.");
	STAssertTrue([bitfield countOfBit: 1 inRange: rng] == rng.length, @"After setting all bits in a range, the count of 1 bits in that range should equal the range's length");
}

- (void) testSetVariousBits
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 5);
	[bitfield setBitsInRange: rng usingBit: 1];
	[bitfield setBit: 1 atIndex: 42];
	STAssertTrue(bitfield.count == 43, @"A bitfield with its highestbit set at index 42 should have a count of 43");
	STAssertTrue([bitfield countOfBit: 1 inRange: NSMakeRange(0, bitfield.count)] == 6, @"Bitfield with bits set in range 0-4 and at index 42 should have 6 bits set");
	STAssertTrue([bitfield countOfBit: 1 inRange: NSMakeRange(5, 20)] == 0, @"Bitfield with bits at 0..4 and 42 set should have no 1 bits in range 5..24");
	STAssertTrue([bitfield countOfBit: 0 inRange: rng] == 0, @"Bitfield with all bits set at 0..4 should have no zero bits in that range, instead has %lu", (unsigned long)[bitfield countOfBit: 0 inRange: rng]);
}

- (void) testRemoveBits
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 100);
	[bitfield setBitsInRange: rng usingBit: 1];
	
	STAssertTrue([bitfield countOfBit: 1 inRange: rng] == 100, @"Bitfield with first 100 bits set should have no zero bits in that range");
	[bitfield setBit: 0 atIndex: 42];
	STAssertTrue([bitfield countOfBit: 1 inRange: rng] == 99, @"Bitfield with first 100 bits set except bit 42 should have 99 nonzero bits in that range");
	STAssertTrue([bitfield countOfBit: 0 inRange: rng] == 1, @"Bitfield with first 100 bits set except bit 42 should have 1 zero bit in that range, instead has %lu", (unsigned long)[bitfield countOfBit: 0 inRange: rng]);
}

- (void) testEquality
{
	AQBitfield * bitfield1 = [AQBitfield new];
	AQBitfield * bitfield2 = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 100);
	
	[bitfield1 setBitsInRange: rng usingBit: 1];
	[bitfield2 setBitsInRange: rng usingBit: 1];
	STAssertEqualObjects(bitfield1, bitfield2, @"Expected equality from bitfields %@ and %@", bitfield1, bitfield2);
	STAssertTrue([bitfield1 hash] == [bitfield2 hash], @"Expected equal bitfields to have the same hash, but got %lu vs. %lu", (unsigned long)[bitfield1 hash], (unsigned long)[bitfield2 hash]);
	
	[bitfield2 setBitsInRange: NSMakeRange(0, 5) usingBit: 0];
	STAssertFalse([bitfield1 isEqual: bitfield2], @"Expected non-equality from bitfields %@ and %@", bitfield1, bitfield2);
	
	// last simple thing
	STAssertEqualObjects(bitfield1, bitfield1, @"Expected object to equal itself, at least! %@", bitfield1);
}

- (void) testBitfieldFromRange
{
	AQBitfield * bitfield1 = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 50);
	NSRange trim = NSMakeRange(25, 50);
	
	[bitfield1 setBitsInRange: rng usingBit: 1];
	
	AQBitfield * bitfield2 = [bitfield1 bitfieldFromRange: trim];
	
	// new bitfield should have bits in range 0-25 set, 25-50 unset
	STAssertTrue([bitfield2 countOfBit: 1 inRange: trim] == 25, @"Sub-bitfield should contains all bits brought over from source but instead has %@", bitfield2);
	STAssertTrue([bitfield2 countOfBit: 1 inRange: rng] == 25, @"Sub-bitfield should contain no bits from outside the range copied from its source, but has %@", bitfield2);
}

- (void) testCopy
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBit: 1 atIndex: 12];
	[bitfield setBitsInRange: NSMakeRange(20, 10) usingBit: 1];
	
	AQBitfield * theCopy = [bitfield copy];
	STAssertEqualObjects(bitfield, theCopy, @"Expected %@ to be equal to its copy %@", bitfield, theCopy);
}

- (void) testFirstIndexOfBit
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBitsInRange: NSMakeRange(0, 20) usingBit: 1];
	
	STAssertTrue([bitfield firstIndexOfBit: 1] == 0, @"Expected first index of bit 1 in %@ to be 0, instead got %lu", bitfield, (unsigned long)[bitfield firstIndexOfBit: 1]);
	STAssertTrue([bitfield firstIndexOfBit: 0] == 20, @"Expected first index of bit 0 in %@ to be 20, instead got %lu", bitfield, (unsigned long)[bitfield firstIndexOfBit: 0]);
}

- (void) testLastIndexOfBit
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setAllBits: 1];
	[bitfield setBitsInRange: NSMakeRange(0, 20) usingBit: 0];
	
	STAssertTrue([bitfield lastIndexOfBit: 1] == NSNotFound-1, @"Expected last index of bit 1 in %@ to be %lu, instead got %lu", bitfield, NSNotFound-1, (unsigned long)[bitfield lastIndexOfBit: 1]);
	STAssertTrue([bitfield lastIndexOfBit: 0] == 19, @"Expected last index of bit 0 in %@ to be 19, instead got %lu", bitfield, (unsigned long)[bitfield lastIndexOfBit: 0]);
}

- (void) testFlipBitAtIndex
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 20);
	[bitfield setBitsInRange: rng usingBit: 1];
	[bitfield flipBitAtIndex: 10];
	
	STAssertTrue([bitfield countOfBit: 1 inRange: rng] == 19, @"Expected bitfield with 20 set bits and 1 toggled to have 19 set bits in range 0-20, instead got %lu", (unsigned long)[bitfield countOfBit: 1 inRange: rng]);
	STAssertTrue([bitfield bitAtIndex: 10] == 0, @"Expected bitfield with 20 set bits and 1 toggled at index 10 to have a 0 bit at index 10");
}

- (void) testFlipBits
{
	AQBitfield * bitfield1 = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 20);
	[bitfield1 setBitsInRange: rng usingBit: 1];
	[bitfield1 setBit: 0 atIndex: 10];
	
	AQBitfield * bitfield2 = [AQBitfield new];
	[bitfield2 setBit: 1 atIndex: 10];
	
	[bitfield1 flipBitsInRange: rng];
	STAssertEqualObjects(bitfield1, bitfield2, @"Expected bitfield %@ with bits in range 0..20 flipped to equal bitfield %@", bitfield1, bitfield2);
}

- (void) testBitShifts
{
	AQBitfield * bitfield1 = [AQBitfield new];
	AQBitfield * bitfield2 = [AQBitfield new];
	
	[bitfield1 setBit: 1 atIndex: 12];
	[bitfield1 setBit: 1 atIndex: 17];
	
	[bitfield2 setBit: 1 atIndex: 14];
	[bitfield2 setBit: 1 atIndex: 19];
	
	AQBitfield * rightShifted = [bitfield1 copy];
	[rightShifted shiftBitsRightBy: 2];
	
	STAssertEqualObjects(rightShifted, bitfield2, @"Expected right-shifted %@ (%@) to equal %@", bitfield1, rightShifted, bitfield2);
	
	AQBitfield * leftShifted = [bitfield2 copy];
	[leftShifted shiftBitsLeftBy: 2];
	
	STAssertEqualObjects(leftShifted, bitfield1, @"Expected left-shifted %@ (%@) to equal %@", bitfield2, leftShifted, bitfield1);
}

- (void) testBitsInRangeAgainstInteger
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBitsInRange: NSMakeRange(0, 8) usingBit: 1];
	[bitfield setBit: 1 atIndex: 31];
	
	NSUInteger test = 0x800000FF;
	STAssertTrue([bitfield bitsInRange: NSMakeRange(0, 32) matchBits: test], @"Expected bitfield %@ to match bits in integer %#x", bitfield, (unsigned int)test);
}

- (void) testBitsInRangeAgainstBitfield
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(20, 8);
	[bitfield setBitsInRange: rng usingBit: 1];
	[bitfield setBit: 1 atIndex: 31];
	
	rng.location = 0;
	AQBitfield * test = [AQBitfield new];
	[test setBitsInRange: rng usingBit: 1];
	[test setBit: 1 atIndex: 31-20];
	
	rng.location += 20;
	rng.length = 12;
	
	STAssertTrue([bitfield bitsInRange: rng equalToBitfield: test], @"Expected bits in range %@ of %@ to match %@", NSStringFromRange(rng), bitfield, test);
	
	[test shiftBitsRightBy: 1];
	STAssertFalse([bitfield bitsInRange: rng equalToBitfield: test], @"Expected bits in range %@ of %@ to NOT match %@", NSStringFromRange(rng), bitfield, test);
}

- (void) testMaskWithBits
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBitsInRange: NSMakeRange(0, 20) usingBit: 1];
	[bitfield setBit: 0 atIndex: 15];
	// 11111111111111101111
	
	AQBitfield * mask = [AQBitfield new];
	[mask setBitsInRange: NSMakeRange(5, 5) usingBit: 1];
	[mask setBit: 1 atIndex: 15];
	// 00000111110000010000
	
	AQBitfield * expected = [AQBitfield new];
	[expected setBitsInRange: NSMakeRange(5, 5) usingBit: 1];
	
	AQBitfield * result = [bitfield copy];
	[result maskWithBits: mask];
	STAssertEqualObjects(result, expected, @"Expected %@ masked with %@ to equal %@, but instead got %@", bitfield, mask, expected, result);
}

- (void) testMaskedBitsInRangeAgainstInteger
{
	AQBitfield * bitfield = [AQBitfield new];
	[bitfield setBitsInRange: NSMakeRange(0, 8) usingBit: 1];
	[bitfield setBit: 1 atIndex: 31];
	
	NSUInteger mask = 0x80000077;
	
	NSUInteger test = 0xFFFFFFFF;
	STAssertTrue([bitfield bitsInRange: NSMakeRange(0, 32) maskedWith: mask matchBits: test], @"Expected bitfield %@ to match bits in integer %#x when masked with %#x", bitfield, (unsigned int)test);
	
	mask = 0xF00000FF;
	STAssertFalse([bitfield bitsInRange: NSMakeRange(0, 32) maskedWith: mask matchBits: test], @"Expected bitfield %@ NOT to match bits in integer %#x", bitfield, (unsigned int)test);
}

- (void) testMaskedBitsInRangeAgainstBitfield
{
	AQBitfield * bitfield = [AQBitfield new];
	NSRange rng = NSMakeRange(0, 16);
	[bitfield setBitsInRange: rng usingBit: 1];
	[bitfield setBit: 1 atIndex: 80];
	
	rng.location = 0;
	AQBitfield * test = [AQBitfield new];
	[test setBitsInRange: NSMakeRange(0, 100) usingBit: 1];
	
	rng.length = 100-20;
	
	AQBitfield * mask = [AQBitfield new];
	[mask setBitsInRange: NSMakeRange(0, 16) usingBit: 1];
	[mask setBit: 0 atIndex: 7];
	[mask setBit: 0 atIndex: 15];
	[mask setBit: 1 atIndex: 80];
	
	STAssertTrue([bitfield bitsInRange: rng maskedWith: mask equalToBitfield: test], @"Expected bits in range %@ of %@ masked with %@ to match %@", NSStringFromRange(rng), bitfield, mask, test);
	
	[test shiftBitsRightBy: 1];
	STAssertFalse([bitfield bitsInRange: rng maskedWith: mask equalToBitfield: test], @"Expected bits in range %@ of %@ to NOT match %@", NSStringFromRange(rng), bitfield, test);
}

#endif

@end
