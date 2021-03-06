//
//  AQNotifyingBitfieldTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
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

#import "AQNotifyingBitfieldTests.h"
#import "AQNotifyingBitfield.h"

@implementation AQNotifyingBitfieldTests

@synthesize bitfield;

- (void) setUp
{
	AQNotifyingBitfield * tmp = [AQNotifyingBitfield new];
	[tmp setBitsInRange: NSMakeRange(0, 10) usingBit: 1];
	self.bitfield = tmp;
}

- (void) testSingleNotificationForRange
{
	__block BOOL notified = NO;
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(0, 5) usingBlock: ^(NSRange range) {
		notified = YES;
	}];
	
	[self.bitfield flipBitAtIndex: 8];
	STAssertFalse(notified, @"Should not have been notified for change outside of notification range");
	
	[self.bitfield flipBitAtIndex: 4];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notified, @"Should have been notified for change within notification range");
}

- (void) testMultipleNotificationsForRange
{
	__block NSUInteger notifications1 = 0;
	__block NSUInteger notifications2 = 0;
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(0, 5) usingBlock: ^(NSRange range) {
		notifications1 += 1;
	}];
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(3, 5) usingBlock: ^(NSRange range) {
		notifications2 += 1;
	}];
	
	[self.bitfield flipBitAtIndex: 8];
	STAssertTrue(notifications1 == 0, @"Notification for 0..4 should not fire for modification at 8");
	STAssertTrue(notifications2 == 0, @"Notification for 3..7 should not fire for modification at 8");
	
	[self.bitfield flipBitAtIndex: 0];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notifications1 == 1, @"Flip at bit 0 should trigger notification for bits 0..4");
	STAssertTrue(notifications2 == 0, @"Flip at bit 0 should NOT trigger notification for bits 3..7");
	
	[self.bitfield flipBitAtIndex: 6];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notifications1 == 1, @"Flip at bit 6 should NOT trigger notification for bits 0..4");
	STAssertTrue(notifications2 == 1, @"Flip at bit 6 should trigger notification for bits 3..7");
	
	[self.bitfield flipBitAtIndex: 4];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notifications1 == 2, @"Flip at bit 4 should trigger notification for bits 0..4");
	STAssertTrue(notifications2 == 2, @"Flip at bit 4 should trigger notification for bits 3..7");
}

- (void) testRangeModifiedNotifications
{
	__block BOOL notified = NO;
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(3, 10) usingBlock: ^(NSRange range) {
		notified = YES;
	}];
	
	[self.bitfield setBitsInRange: NSMakeRange(20, 5) usingBit: 1];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertFalse(notified, @"Modifying bits 20..24 should NOT trigger notification for bits 3..12");
	
	[self.bitfield setBitsInRange: NSMakeRange(8, 10) usingBit: 0];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notified, @"Modifying bits 8..17 should trigger notification for bits 3..12");
}

- (void) testNotificationRemoval
{
	__block BOOL notified = NO;
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(0, 5) usingBlock: ^(NSRange range) {
		notified = YES;
	}];
	
	[self.bitfield flipBitAtIndex: 4];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notified, @"Should have been notified for change within notification range");
	
	notified = NO;
	[self.bitfield removeNotifierForBitsInRange: NSMakeRange(0, 5)];
	
	[self.bitfield flipBitAtIndex: 4];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertFalse(notified, @"Should NOT have been notified for change within a removed notification range");
}

- (void) testNotificationBulkRemoval
{
	__block BOOL notified = NO;
	[self.bitfield notifyModificationOfBitsInRange: NSMakeRange(5, 5) usingBlock: ^(NSRange range) {
		notified = YES;
	}];
	
	[self.bitfield flipBitAtIndex: 8];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertTrue(notified, @"Should have been notified for change within notification range");
	
	notified = NO;
	[self.bitfield removeAllNotifiersWithinRange: NSMakeRange(0, 20)];
	
	[self.bitfield flipBitAtIndex: 8];
	[NSThread sleepForTimeInterval: 0.1];
	STAssertFalse(notified, @"Should NOT have been notified for change within a removed notification range");
}

@end
