//
//  AQBitfieldPredicates.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/NSPredicate.h>
#import "AQBitfield.h"

@interface NSPredicate (AQBitfieldPredicates)

/*!
 @abstract Match the value of a single bit in a bitfield.
 @discussion Returns a predicate which matches the value of a single bit in a bitfield.
 @param value The bit value expected. Can be 1 or 0.
 @param index The index of the bit to compare in the bitfield.
 @result A new NSPredicate.
 */
+ (NSPredicate *) predicateForMatchingBitValue: (AQBit) value
									   atIndex: (NSUInteger) index;

/*!
 @abstract Match the value of all bits in a range of a bitfield.
 @discussion Returns a predicate which evaluates to YES when all bits in a value
		match all bits in a specified range of a bitfield. The specified range must
		be less than or equal to <code>sizeof(NSUInteger)</code>.
 @param value The bit values expected. For ranges smaller than <code>sizeof(NSUInteger)</code>,
		the least-significant bytes of the value are used for the comparison. All values are
		converted to <em>big-endian</em> format for byte-by-byte comparisons.
 @param range The range of bits in the bitfield against which to compare.
 @result A new NSPredicate.
 */
+ (NSPredicate *) predicateForMatchingAllBits: (NSUInteger) value
									  inRange: (NSRange) range;

/*!
 @abstract Match the bits in one bitfield against those in a range within another bitfield.
 @discussion Returns a predicate which matches the contents of one bitfield against the contents
		of a range of bits within an equal- or larger-sized bitfield.
 @param match A bitfield defining the bits to match.
 @param range The range of bits in the bitfield against which to compare.
 @result A new NSPredicate.
 */
+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
								  againstRange: (NSRange) range;

/*!
 @abstract Match the value of certain bits in a range of a bitfield.
 @discussion Returns a predicate which evaluates to YES when a set of masked bits in a value
		match the bits in a specified range of a bitfield, masked using the same mask. The
		specified range must be less than or equal to <code>sizeof(NSUInteger)</code>.
 @param value The bit values expected. For ranges smaller than <code>sizeof(NSUInteger)</code>,
 the least-significant bytes of the value are used for the comparison. All values are
 converted to <em>big-endian</em> format for byte-by-byte comparisons.
 @param mask The mask to apply to the contents of <code>range</code> in the comparison bitfield
		before performing the comparison.
 @param range The range of bits in the bitfield against which to compare.
 @result A new NSPredicate.
 */
+ (NSPredicate *) predicateForMatchingBits: (NSUInteger) value
								maskedWith: (NSUInteger) mask
								   inRange: (NSRange) range;

/*!
 @abstract Match the bits in one bitfield against those in a range within another bitfield.
 @discussion Returns a predicate which matches the contents of one bitfield against the contents
 of a range of bits within an equal- or larger-sized bitfield.
 @param match A bitfield defining the bits to match.
 @param mask A bitfield defining the mask to apply to the contents of <code>range</code> in the
		comparison bitfield before performing the comparison.
 @param range The range of bits in the bitfield against which to compare.
 @result A new NSPredicate.
 */
+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
									maskedWith: (AQBitfield *) mask
								  againstRange: (NSRange) range;

@end
