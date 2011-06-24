//
//  AQBitfieldPredicates.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
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

#import <Foundation/NSPredicate.h>
#import "AQBitfield.h"

/**
 Custom predicate constructors for dealing with AQBitfield instances.
 */
@interface NSPredicate (AQBitfieldPredicates)

/**
 Match the value of a single bit in a bitfield.
 @param value The bit value expected. Can be `1` or `0`.
 @param index The index of the bit to compare in the bitfield.
 @return A new `NSPredicate`.
 */
+ (NSPredicate *) predicateForMatchingBitValue: (AQBit) value
									   atIndex: (NSUInteger) index;

/*!
 Match the value of all bits in a range of a bitfield.
 
 Returns a predicate which evaluates to YES when all bits in a value
 match all bits in a specified range of a bitfield. The specified range must
 be less than or equal to `sizeof(NSUInteger)`.
 @param value The bit values expected. For ranges smaller than `sizeof(NSUInteger)`,
 the least-significant bytes of the value are used for the comparison. All values are
 converted to *big-endian* format for byte-by-byte comparisons.
 @param range The range of bits in the bitfield against which to compare.
 @return A new `NSPredicate`.
 */
+ (NSPredicate *) predicateForMatchingAllBits: (NSUInteger) value
									  inRange: (NSRange) range;

/*!
 Match the bits in one bitfield against those in a range within another bitfield.
 
 Returns a predicate which matches the contents of one bitfield against the contents
 of a range of bits within an equal- or larger-sized bitfield.
 @param match A bitfield defining the bits to match.
 @param range The range of bits in the bitfield against which to compare.
 @return A new `NSPredicate`.
 */
+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
								  againstRange: (NSRange) range;

/*!
 Match the value of certain bits in a range of a bitfield.
 
 Returns a predicate which evaluates to `YES` when a set of masked bits in a value
 match the bits in a specified range of a bitfield, masked using the same mask. The
 specified range must be less than or equal to `sizeof(NSUInteger)`.
 @param value The bit values expected. For ranges smaller than `sizeof(NSUInteger)`,
 the least-significant bytes of the value are used for the comparison. All values are
 converted to *big-endian* format for byte-by-byte comparisons.
 @param mask The mask to apply to the contents of _range_ in the comparison bitfield
		before performing the comparison.
 @param range The range of bits in the bitfield against which to compare.
 @return A new `NSPredicate`.
 */
+ (NSPredicate *) predicateForMatchingBits: (NSUInteger) value
								maskedWith: (NSUInteger) mask
								   inRange: (NSRange) range;

/*!
 Match the bits in one bitfield against those in a range within another bitfield.
 
 Returns a predicate which matches the contents of one bitfield against the contents
 of a range of bits within an equal- or larger-sized bitfield.
 @param match A bitfield defining the bits to match.
 @param mask A bitfield defining the mask to apply to the contents of rangein the
		comparison bitfield before performing the comparison.
 @param range The range of bits in the bitfield against which to compare.
 @return A new `NSPredicate`.
 */
+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
									maskedWith: (AQBitfield *) mask
								  againstRange: (NSRange) range;

@end
