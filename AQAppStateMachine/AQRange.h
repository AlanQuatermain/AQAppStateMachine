//
//  AQRange.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Kobo Inc. All rights reserved.
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

/**
 A simple object wrapper around an `NSRange` structure which implements some sorting logic.
 */
@interface AQRange : NSObject <NSCopying>
{
	NSRange		_range;
}

/**
 Initialize a new `AQRange` instance.
 
 This is the designated initializer for `AQRange`.
 @param range The `NSRange` whose value the receiver will take on.
 @return The new instance.
 */
- (id) initWithRange: (NSRange) range;

/// The underlying range represented by this object.
@property (nonatomic, readonly) NSRange range;

/**
 Test for equality against another object.
 @param object The object against which to compare.
 @result `YES` if the objects match, `NO` otherwise.
 */
- (BOOL) isEqual: (id) object;

/**
 Test for equality with an `NSRange` structure.
 @param nsRange The range against which to compare.
 @result `YES` if the objects match, `NO` otherwise.
 */
- (BOOL) isEqualToNSRange: (NSRange) nsRange;

/**
 Compare one AQRange against another.
 @param other The range against which to compare the receiver.
 @return An `NSComparisonResult` describing the relative ordering of the two objects.
 */
- (NSComparisonResult) compare: (AQRange *) other;

/**
 Compare against an `NSRange` structure.
 @param nsRange The range against which to compare the receiver.
 @return An `NSComparisonResult` describing the relative ordering of the two objects.
 */
- (NSComparisonResult) compareToNSRange: (NSRange) nsRange;

@end
