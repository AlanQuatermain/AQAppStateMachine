//
//  AQStateMatchingDescriptor.h
//  
//
//  Created by Jim Dovey on 11-06-27.
//  Copyright 2011 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A class describing a range-mased match for an AQBitfield.
 */
@interface AQStateMatchingDescriptor : NSObject <NSCopying>
{
	NSString *		_uuid;
	NSIndexSet *	_matchingIndices;
}

/**
 Initialize a new descriptor.
 
 This is the designated initializer for the AQStateMatchingDescriptor class.
 @param ranges An array of AQRange objects specifying ranges to match.
 @return The newly-initialized instance.
 */
- (id) initWithRanges: (NSArray *) ranges;

/**
 Initialize a descriptor using a single range.
 @param range A range specifying which state bits to match.
 @return The newly-initialized instance.
 */
- (id) initWithRange: (NSRange) range;

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
