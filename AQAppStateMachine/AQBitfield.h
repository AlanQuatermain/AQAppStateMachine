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
{
@protected
	NSMutableIndexSet *		_storage;
}

/// @name Initialization

/**
 Initialize an empty bitfield.
 
 This is the designated initializer for the AQBitfield class.
 @return A new bitfield instance, with all bits set to zero.
 */
- (id) init;

/**
 Initialize a bitfield using a 32-bit scalar value.
 @param bits A 32-bit quantity whose bits will be used as initial content for the bitfield.
 @return A new bitfield initialized with a copy of the bits within _bits_.
 */
- (id) initWith32BitField: (UInt32) bits;

/**
 Initialize a bitfield using a 64-bit scalar value.
 @param bits A 64-bit quantity whose bits will be used as initial content for the bitfield.
 @return A new bitfield initialized with a copy of the bits within _bits_.
 */
- (id) initWith64BitField: (UInt64) bits;

/// @name Comparisons

/// Returns a hash code for the object's current state.
- (NSUInteger) hash;

/**
 Check for equality with another object.
 @param object The object to compare.
 @return `YES` if the objects are equal, `NO` otherwise.
 */
- (BOOL) isEqual: (id) object;

/**
 Compare the receiver against another bitfield.
 @param other The bitfield against which to compare the receiver.
 @return An `NSComparisonResult` indicating the fields' relative ordering.
 */
- (NSComparisonResult) compare: (AQBitfield *) other;

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

/**
 Obtain a 32-bit scalar value representing a range of bits within the field.
 @param range The range from which to copy the bits.
 @exception NSRangeException Thrown if the _range_ parameter specifies a length greater than 4.
 @return A 32-bit value representing the bits in the given _range_.
 */
- (UInt32) scalarBitsFromRange: (NSRange) range;

/**
 Obtain a 64-bit scalar value representing a range of bits within the field.
 @param range The range from which to copy the bits.
 @exception NSRangeException Thrown if the _range_ parameter specifies a length greater than 8.
 @return A 64-bit value representing the bits in the given _range_.
 */
- (UInt64) scalarBitsFrom64BitRange: (NSRange) range;

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
 Set the bits in the least-significant four words to those in a 32-bit quantity.
 @param value The value whose bits to copy.
 */
- (void) setBitsFrom32BitValue: (UInt32) value;

/**
 Set the bits in the least-significant eight words to those in a 64-bit quantity.
 @param value The value whose bits to copy.
 */
- (void) setBitsFrom64BitValue: (UInt64) value;

/**
 Set the bits in the given range to those in a 32-bit quantity.
 @param value The value whose bits to copy.
 @param range The range of bits to modify.
 @exception NSInvalidArgumentException Thrown if the supplied range is greater than 32 bits in length.
 */
- (void) setBitsInRange: (NSRange) range from32BitValue: (UInt32) value;

/**
 Set the bits in the given range to those in a 64-bit quantity.
 @param value The value whose bits to copy.
 @param range The range of bits to modify.
 @exception NSInvalidArgumentException Thrown if the supplied range is greater than 64 bits in length.
 */
- (void) setBitsInRange: (NSRange) range from64BitValue: (UInt64) value;

/**
 Copy all 1 bits from another bitfield.
 @param bitfield The bitfield with which to merge the receiver.
 */
- (void) unionWithBitfield: (AQBitfield *) bitfield;

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

/**
 Obtain a copy of the receiver, masked with the given bits.
 @param mask The mask to apply to the bitfield's current state.
 */
- (AQBitfield *) bitfieldUsingMask: (AQBitfield *) mask;

/**
 Obtain a bitfield matching the receiver with all bits shifted to the left.
 @param bits The number of places to shift.
 @return A new bitfield instance.
 */
- (AQBitfield *) bitfieldFromLeftShiftingBy: (NSUInteger) bits;

/**
 Obtain a bitfield matching the receiver with all bits shifted to the roght.
 @param bits The number of places to shift.
 @return A new bitfield instance.
 */
- (AQBitfield *) bitfieldFromRightShiftingBy: (NSUInteger) bits;

@end

/**
 Convenience methods to build AQBitfields directly from NSIndexSets.
 */
@interface NSIndexSet (AQBitfieldCreation)

/**
 Create an AQBitfield using the contents of the receiver.
 */
- (AQBitfield *) bitfieldRepresentation;

@end
