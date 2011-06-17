//
//  AQStateMatchingDescriptor.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-17.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AQBitfield;

@interface AQStateMatchingDescriptor : NSObject <NSCopying>
{
	NSString *		_uuid;
	NSIndexSet *	_matchingIndices;
}

// designated initializer
- (id) initWithRanges: (NSIndexSet *) ranges matchingMasks: (NSArray *) masks;

@property (nonatomic, readonly) NSString * uniqueID;

- (BOOL) matchesRange: (NSRange) range;

- (NSComparisonResult) compare: (AQStateMatchingDescriptor *) other;

@end

@interface AQStateMatchingDescriptor (CreationConvenience)

// single range & mask
- (id) initWithRange: (NSRange) range matchingMask: (AQBitfield *) mask;

// masks using integral types
- (id) initWith32BitMask: (NSUInteger) mask forRange: (NSRange) range;
- (id) initWith64BitMask: (UInt64) mask forRange: (NSRange) range;

@end
