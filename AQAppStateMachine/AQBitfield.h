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

// this is an NSUInteger only for CPU optimization. Its value should always be 0 or 1.
typedef CFBit AQBit;

@interface AQBitfield : NSObject <NSCopying, NSMutableCopying, NSCoding>

- (NSUInteger) hash;
- (BOOL) isEqual: (id) object;

@property (nonatomic, readonly) NSUInteger count;		// number of significant bits

- (NSUInteger) countOfBit: (AQBit) bit inRange: (NSRange) range;

- (BOOL) containsBit: (AQBit) bit inRange: (NSRange) range;
- (AQBit) bitAtIndex: (NSUInteger) index;

- (AQBitfield *) bitfieldFromRange: (NSRange) range;	// throws NSRangeException

- (NSUInteger) firstIndexOfBit: (AQBit) bit;
- (NSUInteger) lastIndexOfBit: (AQBit) bit;

- (void) flipBitAtIndex: (NSUInteger) index;
- (void) flipBitsInRange: (NSRange) range;

- (void) setBit: (AQBit) bit atIndex: (NSUInteger) index;
- (void) setBitsInRange: (NSRange) range usingBit: (AQBit) bit;

- (void) setAllBits: (AQBit) bit;

// 'range' must be <= sizeof(NSUInteger), will compare least-significant bits of 'bits'
- (BOOL) bitsInRange: (NSRange) range matchBits: (NSUInteger) bits;
- (BOOL) bitsInRange: (NSRange) range equalToBitfield: (AQBitfield *) bitfield;

- (BOOL) bitsInRange: (NSRange) range maskedWith: (NSUInteger) mask matchBits: (NSUInteger) bits;
- (BOOL) bitsInRange: (NSRange) range maskedWith: (AQBitfield *) mask equalToBitfield: (AQBitfield *) bitfield;

- (void) shiftBitsLeftBy: (NSUInteger) bits;
- (void) shiftBitsRightBy: (NSUInteger) bits;

- (void) maskWithBits: (AQBitfield *) mask;

@end
