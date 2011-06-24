//
//  AQBitfield.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
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

#import <Foundation/Foundation.h>

/// A register-width type representing a single bit. Its value should always be `0` or `1`.
typedef CFBit AQBit;

/**
 A class representing a bitfield of indeterminate size.
 */
@interface AQBitfield : NSObject <NSCopying, NSMutableCopying, NSCoding>

/// @name Comparisons

/// Returns a hash code for the object's current state.
- (NSUInteger) hash;

/**
 Check for equality with another object.
 @param object The object to compare.
 @return `YES` if the objects are equal, `NO` otherwise.
 */
- (BOOL) isEqual: (id) object;

/// @name Counting

/**
 The number of significant bits within the bitfield.
 
 *NB:* This returns the number of bits in the range which covers all `1` bits in the bitfield.
 i.e. it will return `((index of highest 1-bit) + 1)`.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 Count the number of bits with a particular value within a range.
 @param bit The bit value to count.
 @param range The range of bits to check.
 @return The number of bits set to the value of _bit_ within _range_.
 */
- (NSUInteger) countOfBit: (AQBit) bit inRange: (NSRange) range;

/**
 Determine whether a given bit value exists within a range.
 @param bit The bit value for which to search.
 @param range The range of bits to check.
 @return `YES` if the given bit value exists within the range, `NO` otherwise.
 */
- (BOOL) containsBit: (AQBit) bit inRange: (NSRange) range;

/// @name Bit Accessors

/**
 Inspect the value of a specified bit.
 @param index The index of the bit to check.
 @result The value of the specified bit.
 */
- (AQBit) bitAtIndex: (NSUInteger) index;

/**
 Obtain a (zero-based) bitfield containing a copy of all bits from a given range.
 @param range The range of the receiver from which to create the new bitfield.
 @result A new bitfield containing the bits from the specified range.
 @exception NSRangeException Thrown if the range is beyond that allowable (`0..NSNotFound`)
 */
- (AQBitfield *) bitfieldFromRange: (NSRange) range;

/// @name Significant Bits

/**
 Find the index of the least-significant bit containing a specified value.
 @param bit The bit value for which to search.
 @return The index of the least-significant bit with the given value.
 */
- (NSUInteger) firstIndexOfBit: (AQBit) bit;

/**
 Find the index of the most-significant bit containing a specified value.
 @param bit The bit value for which to search.
 @return The index of the most-significant bit with the given value.
 */
- (NSUInteger) lastIndexOfBit: (AQBit) bit;

/// @name Toggling Bits

/**
 Toggle the value of a particular bit.
 @param index The index of the bit whose value to toggle.
 */
- (void) flipBitAtIndex: (NSUInteger) index;

/**
 Toggle all bits in a given range.
 @param range The range of bits to toggle.
 */
- (void) flipBitsInRange: (NSRange) range;

/// @name Setting Bits

/**
 Set the value of a specific bit.
 @param bit The value to set.
 @param index The index of the bit to set.
 */
- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index;

/**
 Set the value of all bits in a range.
 @param range The range of bits to modify.
 @param bit The value to set.
 */
- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit;

/**
 Fills the entire bitfield (from `0` to `NSNotFound-1`) with a given value.
 @param bit The value to use.
 */
- (void) setAllBits: (AQBit) bit;

/// @name Matching bit values

/**
 Look for a match within the bitfield to an integer-sized value.
 @param range The range of bits to compare. Must be `<= sizeof(NSUInteger)`. Compares least-significant bits of _bits_.
 @param bits The value to compare against.
 @return `YES` if a match is found, `NO` otherwise.
 */
- (BOOL) bitsInRange: (NSRange) range matchBits: (NSUInteger) bits;

/**
 Look for a match within a sub-range of the bitfield.
 @param range The range of bits to compare.
 @param bitfield A zero-based bitfield corresponding to the bits within _range_ to compare.
 @return `YES` if a match is found, `NO` otherwise.
 */
- (BOOL) bitsInRange: (NSRange) range equalToBitfield: (AQBitfield *) bitfield;

/**
 Look for a match within the bitfield to an integer-sized value according to a mask.
 @param range The range of bits to compare. Must be `<= sizeof(NSUInteger)`. Compares least-significant bits of _bits_.
 @param mask A mask to determine which bits in the bitfield's sub-range to actually compare.
 @param bits The value to compare against.
 @return `YES` if a match is found, `NO` otherwise.
 */
- (BOOL) bitsInRange: (NSRange) range maskedWith: (NSUInteger) mask matchBits: (NSUInteger) bits;

/**
 Look for a match within a sub-range of the bitfield according to a mask.
 @param range The range of bits to compare.
 @param mask A mask to determine which bits in the bitfield's sub-range to actually compare.
 @param bitfield A zero-based bitfield corresponding to the bits within \a range to compare.
 @return `YES` if a match is found, `NO` otherwise.
 */
- (BOOL) bitsInRange: (NSRange) range maskedWith: (AQBitfield *) mask equalToBitfield: (AQBitfield *) bitfield;

/// Bitwise Operations

/**
 Shift all bits in the field to the left.
 @param bits The number of places to shift.
 */
- (void) shiftBitsLeftBy: (NSUInteger) bits;

/**
 Shift all bits in the field to the right.
 @param bits The number of places to shift.
 */
- (void) shiftBitsRightBy: (NSUInteger) bits;

/**
 Mask a bitfield using a bitwise AND operation.
 @param mask The mask to apply to the bitfield's current state.
 */
- (void) maskWithBits: (AQBitfield *) mask;

@end
