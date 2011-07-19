//
//  AQAppStateMachineCoreTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-23.
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

#import "AQAppStateMachineCoreTests.h"
#import "AQAppStateMachine.h"

static NSString * const kSampleOneName = @"Sample One";
static NSString * const kSampleTwoName = @"Sample Two";

enum
{
	kSampleOneFirst,		// 00
	kSampleOneSecond,		// 01
	kSampleOneThird,		// 10
	kSampleOneFourth,		// 11
	
	kSampleOneCount
};

enum
{
	kSampleTwoFirst,		// 00
	kSampleTwoSecond,		// 01
	kSampleTwoThird,		// 10
	kSampleTwoFourth,		// 11
	
	kSampleTwoCount
};

@implementation AQAppStateMachineCoreTests
{
	AQAppStateMachine * stateMachine;
}

- (void) setUp
{
	// temporary version just for the tests
	stateMachine = [AQAppStateMachine new];
	
	// add the named ranges
	[stateMachine addStateMachineValuesFromZeroTo: kSampleOneCount withName: kSampleOneName];
	[stateMachine addStateMachineValuesFromZeroTo: kSampleTwoCount withName: kSampleTwoName];
	
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
}

- (void) tearDown
{
#if !USING_ARC
	[stateMachine release];
#endif
	// ARC code-- no -release, just nilify it
	stateMachine = nil;
}

- (void) testSimpleValues
{
	STAssertTrue([stateMachine valueForEnumerationWithName: kSampleOneName] == kSampleOneSecond, @"Expected value for %@ to be %lu, got %lu", kSampleOneName, kSampleOneSecond, [stateMachine valueForEnumerationWithName: kSampleOneName]);
	
	[stateMachine clearBitAtIndex: 0 ofEnumerationWithName: kSampleOneName];
	STAssertTrue([stateMachine valueForEnumerationWithName: kSampleOneName] == kSampleOneFirst, @"Expected value for %@ to be %lu, got %lu", kSampleOneName, kSampleOneFirst, [stateMachine valueForEnumerationWithName: kSampleOneName]);
}

- (void) testNamedRanges
{
	// the state machine will round up to byte-size to allocate ranges, like so:
	NSUInteger sampleOneBitCount = (kSampleOneCount + 7) & ~7;
	NSUInteger sampleTwoBitCount = (kSampleTwoCount + 7) & ~7;
	
	STAssertTrue(NSEqualRanges(NSMakeRange(0, sampleOneBitCount), [stateMachine underlyingBitfieldRangeForName: kSampleOneName]), @"The underlying range is unexpectedly %@", NSStringFromRange([stateMachine underlyingBitfieldRangeForName: kSampleOneName]));
	STAssertTrue(NSEqualRanges(NSMakeRange(sampleOneBitCount, sampleTwoBitCount), [stateMachine underlyingBitfieldRangeForName: kSampleTwoName]), @"The underlying range is unexpectedly %@", NSStringFromRange([stateMachine underlyingBitfieldRangeForName: kSampleTwoName]));
}

- (void) testChangesToSingleBitInRange
{
	STAssertTrue([stateMachine bitIsSetAtIndex: 1 forName: kSampleTwoName], @"Expected bit one of %@ to be set", kSampleTwoName);
	
	[stateMachine clearBitAtIndex: 1 ofEnumerationWithName: kSampleTwoName];
	STAssertTrue([stateMachine bitIsSetAtIndex: 1 forName: kSampleTwoName] == NO, @"Expected bit one of %@ NOT to be set", kSampleTwoName);
	
	[stateMachine setBitAtIndex: 1 ofEnumerationWithName: kSampleTwoName];
	STAssertTrue([stateMachine bitIsSetAtIndex: 1 forName: kSampleTwoName], @"Expected bit one of %@ to be set", kSampleTwoName);
}

- (void) testChangesToValueInRange
{
	STAssertTrue([stateMachine bitValuesForName: kSampleTwoName matchInteger: kSampleTwoThird], @"Expected range %@ to contain %lu", kSampleTwoName, kSampleTwoThird);
	
	[stateMachine setValue: kSampleTwoSecond forEnumerationWithName: kSampleTwoName];
	STAssertTrue([stateMachine bitValuesForName: kSampleTwoName matchInteger: kSampleTwoSecond], @"Expected range %@ to contain %lu", kSampleTwoName, kSampleTwoSecond);
}

- (void) testEnumerationChangeNotifications
{
	__block BOOL matched = NO;
	[stateMachine notifyChangesToStateMachineValuesWithName: kSampleOneName usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleOneFirst forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called upon change to value in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called upon change to value in %@", kSampleTwoName);
}

- (void) testSingleBitChangeNotifications
{
	__block BOOL matched = NO;
	[stateMachine notifyChangesToStateMachineValuesWithName: kSampleOneName matchingMask: 0x01 usingBlock: ^{ matched = YES; }];
	
	[stateMachine setBitAtIndex: 0 ofEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called upon change to bit zero in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine setBitAtIndex: 1 ofEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called upon change to bit one in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine clearBitAtIndex: 0 ofEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called upon change to bit zero in %@", kSampleOneName);
}

- (void) testValueChangeNotifications
{
	__block BOOL matched = NO;
	[stateMachine notifyChangesToStateMachineValuesWithName: kSampleTwoName matchingMask: kSampleTwoThird usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoThird was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called when kSampleTwoSecond was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoFourth forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoFourth was set in %@", kSampleTwoName);
}

- (void) testEqualityNotifications
{
	static NSString * const kEqualityEnum = @"Equality";
	static const NSUInteger kMatchValue   = 548;
	
	[stateMachine addStateMachineValuesFromZeroTo: USHRT_MAX withName: kEqualityEnum];
	
	__block BOOL matched = NO;
	[stateMachine notifyEqualityOfStateMachineValuesWithName: kEqualityEnum toInteger: 548 usingBlock: ^{ matched = YES; }];
	
	// set that value, verify that the match is called
	[stateMachine setValue: kMatchValue forEnumerationWithName: kEqualityEnum];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected equality notifier on %@ to fire when value was set to %lu", kEqualityEnum, (unsigned long)kMatchValue);
	
	// set a different value, ensure it does NOT fire the notification
	matched = NO;
	[stateMachine setValue: kMatchValue+1 forEnumerationWithName: kEqualityEnum];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected equality notifier on %@ NOT to fire when value was set to %lu", kEqualityEnum, (unsigned long)kMatchValue);
	
	// set it again and verify that it once more fires
	matched = NO;
	[stateMachine setValue: kMatchValue forEnumerationWithName: kEqualityEnum];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected equality notifier on %@ to fire when value was re-set to %lu", kEqualityEnum, (unsigned long)kMatchValue);
}

- (void) testMultipleValueChangeNotifications
{
	__block BOOL matched = NO;
	NSArray * values = [NSArray arrayWithObjects: kSampleOneName, kSampleTwoName, nil];
	NSArray * masks  = [NSArray arrayWithObjects: [NSNull null], [NSNull null], nil];
	
	[stateMachine notifyChangesToStateMachineValuesWithNames: values matchingMasks: masks usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoThird was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleOneSecond was set in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoFourth forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoFourth was set in %@", kSampleTwoName);
}

- (void) testMultipleValueChangeNotificationsWithMasks
{
	__block BOOL matched = NO;
	NSArray * values = [NSArray arrayWithObjects: kSampleOneName, kSampleTwoName, nil];
	NSArray * masks  = [NSArray arrayWithObjects: [NSNumber numberWithInt: kSampleOneThird], [NSNumber numberWithInt: kSampleTwoThird], nil];
	
	[stateMachine notifyChangesToStateMachineValuesWithNames: values matchingMasks: masks usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoThird was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleOneSecond was set in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoFourth forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when kSampleTwoFourth was set in %@", kSampleTwoName);
}

- (void) testMultipleValueEqualityNotifications
{
	__block BOOL matched = NO;
	NSArray * names  = [NSArray arrayWithObjects: kSampleOneName, kSampleTwoName, nil];
	NSArray * masks  = [NSArray arrayWithObjects: [NSNull null], [NSNull null], nil];
	NSArray * values = [NSArray arrayWithObjects: [NSNumber numberWithInt: kSampleOneSecond], [NSNumber numberWithInt: kSampleTwoSecond], nil];
	
	// reset the state machine
	[stateMachine setValue: 0 forEnumerationWithName: kSampleOneName];
	[stateMachine setValue: 0 forEnumerationWithName: kSampleTwoName];
	
	[stateMachine notifyEqualityOfStateMachineValuesWithNames: names matchingMasks: masks toValues: values usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleTwoSecond forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called when kSampleTwoThird was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when both kSampleOneSecond was set in %@ and kSampleTwoSecond was set in %@", kSampleOneName, kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoFourth forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block to be called when kSampleTwoFourth was set in %@", kSampleTwoName);
}

- (void) testMultipleValueEqualityNotificationsWithMasks
{
	__block BOOL matched = NO;
	NSArray * names  = [NSArray arrayWithObjects: kSampleOneName, kSampleTwoName, nil];
	NSArray * masks  = [NSArray arrayWithObjects: [NSNumber numberWithInt: kSampleOneThird], [NSNumber numberWithInt: kSampleTwoThird], nil];
	NSArray * values = [NSArray arrayWithObjects: [NSNumber numberWithInt: kSampleOneFourth], [NSNumber numberWithInt: kSampleTwoFourth], nil];
	
	// reset the state machine
	[stateMachine setValue: 0 forEnumerationWithName: kSampleOneName];
	[stateMachine setValue: 0 forEnumerationWithName: kSampleTwoName];
	
	[stateMachine notifyEqualityOfStateMachineValuesWithNames: names matchingMasks: masks toValues: values usingBlock: ^{ matched = YES; }];
	
	[stateMachine setValue: kSampleTwoThird forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called when only kSampleTwoThird was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneSecond forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called when kSampleOneSecond was set in %@", kSampleOneName);
	
	matched = NO;
	[stateMachine setValue: kSampleTwoFourth forEnumerationWithName: kSampleTwoName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertFalse(matched, @"Expected block NOT to be called when kSampleTwoFourth was set in %@", kSampleTwoName);
	
	matched = NO;
	[stateMachine setValue: kSampleOneFourth forEnumerationWithName: kSampleOneName];
	
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
	STAssertTrue(matched, @"Expected block to be called when both kSampleTwoFourth nad kSampleOneFourth were set", kSampleTwoName);
}

@end
