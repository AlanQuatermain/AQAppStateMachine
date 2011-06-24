//
//  AQNotifyingBitfield.h
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

#import <Foundation/Foundation.h>
#import "AQBitfield.h"

/**
 A Block type for processing range modification notifications.
 @param range The range of bits modified.
 */
typedef void (^AQRangeNotification)(NSRange range);

/**
 A bitfield which supports calling notification callback blocks whenever bits within certain ranges
 are modified.
 */
@interface AQNotifyingBitfield : AQBitfield

/**
 Install a notifier block for a given range of a bitfield.
 @param range The range to watch.
 @param block The block to run when any bits within _range_ are modified.
 */
- (void) notifyModificationOfBitsInRange: (NSRange) range usingBlock: (AQRangeNotification) block;

/**
 Remove a notifier for a specific range.
 @param range The range for which to search. Must exactly match a range passed to
 notifyModificationOfBitsInRange:usingBlock:.
 */
- (void) removeNotifierForBitsInRange: (NSRange) range;

/**
 Remove any notifiers attached to ranges are within a given range.
 @param range The range to search. Only notifiers whose ranges are _completely_ within this value will
 be removed.
 */
- (void) removeAllNotifiersWithinRange: (NSRange) range;

@end
