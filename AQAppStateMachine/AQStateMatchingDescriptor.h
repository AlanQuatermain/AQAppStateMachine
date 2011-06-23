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

@interface AQStateMatchingDescriptor : NSObject <NSCopying>
{
	NSString *		_uuid;
	NSIndexSet *	_matchingIndices;
}

// designated initializer
// to specify 'no mask' in an array, use NSNull
- (id) initWithRanges: (NSArray *) ranges matchingMasks: (NSArray *) masks;

@property (nonatomic, readonly) NSString * uniqueID;
@property (nonatomic, readonly) NSRange fullRange;

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
