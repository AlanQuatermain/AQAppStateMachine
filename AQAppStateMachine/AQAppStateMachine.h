//
//  AQAppStateMachine.h
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
#import "AQNotifyingBitfield.h"

/*!
 This is intended to be a singleton class.
 */
@interface AQAppStateMachine : NSObject

/*!
 Obtain/create the singleton state machine instance.
 */
+ (AQAppStateMachine *) appStateMachine;

// core value change API
- (void) setBit: (AQBit) aBit atIndex: (NSUInteger) index ofStateBitsInRange: (NSRange) range;
- (void) setScalar32Value: (UInt32) value forStateBitsInRange: (NSRange) range;
- (void) setScalar64Value: (UInt64) value forStateBitsInRange: (NSRange) range;

// core notification API— everything else funnels through these functions
- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index
								usingBlock: (void (^)(void)) block;

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
								 usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
						  maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
					 maskedWith64BitInteger: (UInt64) mask
								 usingBlock: (void (^)(void))block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
							 maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block;

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
							  toIntegerValue: (NSUInteger) value
									   block: (void (^)(void)) block;
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								to64BitValue: (UInt64) value
									   block: (void (^)(void)) block;
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
									 toValue: (AQBitfield *) value
								  usingBlock: (void (^)(void)) block;

- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (NSUInteger) mask
							  toIntegerValue: (NSUInteger) value
									   block: (void (^)(void)) block;
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (UInt64) mask
								to64BitValue: (UInt64) value
									   block: (void (^)(void)) block;
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (AQBitfield *) mask
									 toValue: (AQBitfield *) value
									   block: (void (^)(void)) block;

@end

/**
 This category defines an interface whereby API clients can interact with the state machine using
 atomic-sized enumerated value ranges keyed with specific names, rather than knowing the internals
 of the (potentially quite large) bitfield layout.
 */
@interface AQAppStateMachine (NamedStateEnumerations)

// up to 32 bits of enum size
- (void) addStateMachineValuesFromZeroTo: (NSUInteger) maxValue withName: (NSString *) name;

// up to 32-64 bits of enum size
- (void) add64BitStateMachineValuesFromZeroTo: (UInt64) maxValue withName: (NSString *) name;

// generic named bit-range creator -- the others all funnel through here
- (void) addStateMachineValuesUsingBitfieldOfLength: (NSUInteger) length withName: (NSString *) name;

// setting values -- simple version
- (void) setValue: (UInt64) value forEnumerationWithName: (NSString *) name;
- (void) setBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name;
- (void) clearBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name;

// add notifications for named enumerations
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
									  matchingMask: (NSUInteger) mask
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
								 matching64BitMask: (UInt64) mask
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
							  matchingMaskBitfield: (AQBitfield *) mask
										usingBlock: (void (^)(void)) block;

- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										  toInteger: (NSUInteger) value
										 usingBlock: (void (^)(void)) block;
- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										   toUInt64: (NSUInteger) value
										 usingBlock: (void (^)(void)) block;
- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
											 toBits: (AQBitfield *) bits
										 usingBlock: (void (^)(void)) block;

- (BOOL) bitIsSetAtIndex: (NSUInteger) index forName: (NSString *) name;
- (BOOL) bitsSetAtIndexes: (NSIndexSet *) indexes forName: (NSString *) name;
- (BOOL) bitValuesForName: (NSString *) name matchInteger: (NSUInteger) value;
- (BOOL) bitValuesForName: (NSString *) name matchBits: (AQBitfield *) bits;

@end

@interface AQAppStateMachine (MultipleEnumerationNotifications)

// When monitoring items within multiple enums/ranges, we will need to supply lists of name/mask pairs.
// Masks can be an AQBitfield or any form of NSNumber, or NSNull for no mask.
// However, for this particular API, there *must* be a matching number of names and masks. Fill an NSArray
//  with NSNulls if necessary.
- (void) notifyChangesToStateMachineValuesWithNames: (NSArray *) names
									  matchingMasks: (NSArray *) masks
										 usingBlock: (void (^)(void)) block;

- (void) notifyEqualityOfStateMachineValuesWithNames: (NSArray *) names
									   matchingMasks: (NSArray *) masks
											toValues: (NSArray *) values
										  usingBlock: (void (^)(void)) block;

@end

@interface AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name;

@end
