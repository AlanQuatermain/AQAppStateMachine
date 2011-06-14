//
//  AQBitfield.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-14.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

// this is an NSUInteger only for CPU optimization. Its value should always be 0 or 1.
typedef CFBit AQBit;

@interface AQBitfield : NSObject <NSCopying, NSMutableCopying, NSCoding>

+ (AQBitfield *) bitfieldWithSize: (NSUInteger) numberOfBits;

- (id) initWithSize: (NSUInteger) numberOfBits;

@property (nonatomic, assign) NSUInteger count;		// number of significant bits

- (NSUInteger) countOfBit: (AQBit) bit inRange: (NSRange) range;

- (BOOL) containsBit: (AQBit) bit inRange: (NSRange) range;
- (AQBit) bitAtIndex: (NSUInteger) index;

- (AQBitfield *) bitfieldFromRange: (NSRange) range;	// throws NSRangeException

@property (nonatomic, readonly) NSData * bits;

- (NSUInteger) firstIndexOfBit: (AQBit) bit;
- (NSUInteger) lastIndexOfBit: (AQBit) bit;

- (void) flipBitAtIndex: (NSUInteger) index;
- (void) flipBitsInRange: (NSRange) range;

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index;
- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit;

- (void) setAllBits: (AQBit) bit;

// 'range' must be <= sizeof(NSUInteger), will compare least-significant bits of 'bits'
- (BOOL) bitsInRange: (NSRange) range matchBits: (NSUInteger) bits;

@end
