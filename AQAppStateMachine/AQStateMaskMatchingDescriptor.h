//
//  AQStateMatchingDescriptor.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-17.
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

@class AQBitfield;

/**
 A class describing a comparison match for an AQBitfield.
 */
@interface AQStateMatchingDescriptor : NSObject <NSCopying>
{
	NSString *		_uuid;
	NSIndexSet *	_matchingIndices;
}

/**
 Initialize a new descriptor.
 
 If masks are only required for some but not all entries in the _ranges_ array, the
 corresponding entry in the _masks_ array should be an `NSNull` instance.
 @param ranges An array of AQRange objects specifying ranges to match.
 @param masks An array of AQBitfield objects providing masks to apply to the ranges. May be `nil`.
 @return The newly-initialized instance.
 */
- (id) initWithRanges: (NSArray *) ranges matchingMasks: (NSArray *) masks;

/// A unique identifier for this descriptor.
@property (nonatomic, readonly) NSString * uniqueID;
/// The full range covered by this descriptor.
@property (nonatomic, readonly) NSRange fullRange;

/**
 Determine whether a descriptor checks any bits within a specific range.
 @param range The range of bits to compare.
 @result `YES` if the descriptor checks bits within _range_, `NO` otherwise.
 */
- (BOOL) matchesRange: (NSRange) range;

/**
 Compare two descriptors.
 @param other The descriptor against which to compare the receiver.
 @return An `NSComparisonResult` indicating the relative sort ordering of the two descriptors.
 */
- (NSComparisonResult) compare: (AQStateMatchingDescriptor *) other;

@end

/// Convenience functions for creating descriptors for single range/mask pairs.
@interface AQStateMatchingDescriptor (CreationConvenience)

/**
 Initialize a descriptor using a single range and mask.
 @param range The range to match.
 @param mask A mask specifying which bits within the range to match. May be `nil`.
 @return The newly-initialized instance.
 */
- (id) initWithRange: (NSRange) range matchingMask: (AQBitfield *) mask;

/**
 Initialize a descriptor using a single range and a 32-bit mask.
 @param mask A mask specifying which bits within the range to match. Do not pass zero.
 @param range The range to match.
 @return The newly-initialized instance.
 */
- (id) initWith32BitMask: (NSUInteger) mask forRange: (NSRange) range;

/**
 Initialize a descriptor using a single range and a 64-bit mask.
 @param mask A mask specifying which bits within the range to match. Do not pass zero.
 @param range The range to match.
 @return The newly-initialized instance.
 */
- (id) initWith64BitMask: (UInt64) mask forRange: (NSRange) range;

@end
