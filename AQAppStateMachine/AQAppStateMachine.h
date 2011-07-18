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

/**
 This is intended to be a singleton class.
 */
@interface AQAppStateMachine : NSObject

/**
 Obtain/create the singleton state machine instance.
 @return The singleton state machine.
 */
+ (AQAppStateMachine *) appStateMachine;

/// @name Core State Changing API

/**
 Set a bit within a given range.
 @param aBit The bit value to set.
 @param index The index of the bit to set, within *range*.
 @param range The range of bits within the state machine upon which to operate.
 */
- (void) setBit: (AQBit) aBit atIndex: (NSUInteger) index ofStateBitsInRange: (NSRange) range;

/**
 Store a 32-bit value in a given range of bits.
 @param value The value to set.
 @param range The range of bits within the state machine upon which to operate.
 */
- (void) setScalar32Value: (UInt32) value forStateBitsInRange: (NSRange) range;

/**
 Store a 64-bit value in a given range of bits.
 @param value The value to set.
 @param range The range of bits within the state machine upon which to operate.
 */
- (void) setScalar64Value: (UInt64) value forStateBitsInRange: (NSRange) range;

/// @name Core notification API

/**
 Run a notification block when a given bit is modified.
 @param index The index of the bit to watch for changes.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index
								usingBlock: (void (^)(void)) block;

/**
 Run a notification block when any bit in a range is modified.
 @param index The range of bits to watch for changes.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
								 usingBlock: (void (^)(void)) block;

/**
 Run a notification block when any bit within a masked range is modified.
 @param index The range of bits to watch for changes.
 @param mask A mask showing which bits within the range should be monitored.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
						  maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block;

/**
 Run a notification block when any bit within a masked eight-byte range is modified.
 @param index The range of bits to watch for changes.
 @param mask A mask showing which bits within the range should be monitored.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
					 maskedWith64BitInteger: (UInt64) mask
								 usingBlock: (void (^)(void))block;

/**
 Run a notification block when any bit within a masked range is modified.
 @param index The range of bits to watch for changes.
 @param mask A bitfield mask showing which bits within the range should be monitored.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForChangesToStateBitsInRange: (NSRange) range
							 maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given value.
 @param index The range of bits to watch for changes.
 @param value The value against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
							  toIntegerValue: (NSUInteger) value
									   block: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given 64-bit value.
 @param index The range of bits to watch for changes.
 @param value The value against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								to64BitValue: (UInt64) value
									   block: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given bitfield value.
 @param index The range of bits to watch for changes.
 @param value The value against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
									 toValue: (AQBitfield *) value
								  usingBlock: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given masked value.
 @param index The range of bits to watch for changes.
 @param mask A mask denoting which bits within the range should be compared.
 @param value The value against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (NSUInteger) mask
							  toIntegerValue: (NSUInteger) value
									   block: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given masked 64-bit value.
 @param index The range of bits to watch for changes.
 @param mask A mask denoting which bits within the range should be compared.
 @param value The value against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
- (void) notifyForEqualityOfStateBitsInRange: (NSRange) range
								  maskedWith: (UInt64) mask
								to64BitValue: (UInt64) value
									   block: (void (^)(void)) block;

/**
 Run a notification block when the bits in a given range exactly match a given masked bitfield.
 @param index The range of bits to watch for changes.
 @param mask A mask bitfield denoting which bits within the range should be compared.
 @param value The bitfield against which to compare the range's bits.
 @param block The block to run when a modification occurs.
 */
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

/// @name Creating named enumerations

/**
 Create a named enumeration from an implicit enumeration up to 32 bits in size.
 @param maxValue The highest value contained in the enumeration.
 @param name The name to assign the enumeration.
 */
- (void) addStateMachineValuesFromZeroTo: (NSUInteger) maxValue withName: (NSString *) name;

/**
 Create a named enumeration from an implicit enumeration up to 64 bits in size.
 @param maxValue The highest value contained in the enumeration.
 @param name The name to assign the enumeration.
 */
- (void) add64BitStateMachineValuesFromZeroTo: (UInt64) maxValue withName: (NSString *) name;

/**
 Create a named enumeration from an implicit enumeration up to 32 bits in size.
 
 All other named enumeration creators funnel through this function.
 @param length The length of enumeration to create.
 @param name The name to assign the new enumeration.
 */
- (void) addStateMachineValuesUsingBitfieldOfLength: (NSUInteger) length withName: (NSString *) name;

/// @name Modifying named enumeration values

/**
 Set a scalar value (up to 64 bits in size) for a named enumeration.
 @param value The new value for the enumeration.
 @param name The name of the enumeration to modify.
 */
- (void) setValue: (UInt64) value forEnumerationWithName: (NSString *) name;

/**
 Set (to 1) an individual bit within a named enumeration.
 @param index The index of the bit to set within the enumeration.
 @param name The name of the enumeration to modify.
 */
- (void) setBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name;

/**
 Clear (set to 0) an individual bit within a named enumeration.
 @param index The index of the bit to set within the enumeration.
 @param name The name of the enumeration to modify.
 */
- (void) clearBitAtIndex: (NSUInteger) index ofEnumerationWithName: (NSString *) name;

/// @name Reading named enumeration values

/**
 Fetch the current 32-bit scalar value for a named enumeration.
 @param name The name of the enumeration to modify.
 @result The value within the enumeration, trimmed to 32 bits if necessary.
 */
- (UInt32) valueForEnumerationWithName: (NSString *) name;

/**
 Fetch the current 64-bit scalar value for a named enumeration.
 @param name The name of the enumeration to modify.
 @result The value within the enumeration, trimmed to 64 bits if necessary.
 */
- (UInt64) largeValueForEnumerationWithName: (NSString *) name;

/**
 Fetch a bitfield representing the current value of a named enumeration.
 @param name The name of the enumeration to modify.
 @result A bitfield matching the current value of the enumeration.
 */
- (AQBitfield *) bitsForEnumerationWithName: (NSString *) name;

/**
 Determine whether a given bit is set within a named enumeration.
 @param index The index within the enumeration of the bit to test.
 @param name The name of the enumeration to modify.
 @result `YES` if the specified bit is set to 1, `NO` otherwise.
 */
- (BOOL) bitIsSetAtIndex: (NSUInteger) index forName: (NSString *) name;

/**
 Determine whether a number of bits are set within a named enumeration.
 @param indexes The indices of the bits within the enumeration to test.
 @param name The name of the enumeration to modify.
 @result `YES` if the specified bits are all set to 1, `NO` otherwise.
 */
- (BOOL) bitsSetAtIndexes: (NSIndexSet *) indexes forName: (NSString *) name;

/**
 Determine whether a named enumeration's value matches a 32-bit scalar.
 @param name The name of the enumeration to modify.
 @param value The value against which to compare.
 @result `YES` if the enumeration's value matches *value*, `NO` otherwise.
 */
- (BOOL) bitValuesForName: (NSString *) name matchInteger: (UInt32) value;

/**
 Determine whether a named enumeration's value matches a bitfield.
 @param name The name of the enumeration to modify.
 @param bits The bitfield against which to compare.
 @result `YES` if the enumeration's value matches *bits*, `NO` otherwise.
 */
- (BOOL) bitValuesForName: (NSString *) name matchBits: (AQBitfield *) bits;

/// @name Notifications on named enumerations

/**
 Request notification of all changes to a named enumeration.
 @param name The name of the enumeration to monitor.
 @param block A block to run upon any changes.
 */
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
										usingBlock: (void (^)(void)) block;

/**
 Request notification of all changes matching a 32-bit mask to a named enumeration.
 @param name The name of the enumeration to monitor.
 @param mask A mask denoting which bits within the enumeration to monitor.
 @param block A block to run upon any changes.
 */
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
									  matchingMask: (NSUInteger) mask
										usingBlock: (void (^)(void)) block;

/**
 Request notification of all changes matching a 64-bit mask to a named enumeration.
 @param name The name of the enumeration to monitor.
 @param mask A mask denoting which bits within the enumeration to monitor.
 @param block A block to run upon any changes.
 */
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
								 matching64BitMask: (UInt64) mask
										usingBlock: (void (^)(void)) block;

/**
 Request notification of all changes matching a bitfield mask to a named enumeration.
 @param name The name of the enumeration to monitor.
 @param mask A bitfield denoting which bits within the enumeration to monitor.
 @param block A block to run upon any changes.
 */
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
							  matchingMaskBitfield: (AQBitfield *) mask
										usingBlock: (void (^)(void)) block;

/**
 Request notification whenever the content of a named enumeration matches a 32-bit scalar value.
 @param name The name of the enumeration to monitor.
 @param value The value against which to compare the enumeration.
 @param block A block to run upon any changes.
 */
- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										  toInteger: (NSUInteger) value
										 usingBlock: (void (^)(void)) block;

/**
 Request notification whenever the content of a named enumeration matches a 64-bit scalar value.
 @param name The name of the enumeration to monitor.
 @param value The value against which to compare the enumeration.
 @param block A block to run upon any changes.
 */
- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
										   toUInt64: (NSUInteger) value
										 usingBlock: (void (^)(void)) block;

/**
 Request notification whenever the content of a named enumeration matches a bitfield.
 @param name The name of the enumeration to monitor.
 @param bits The bitfield against which to compare the enumeration.
 @param block A block to run upon any changes.
 */
- (void) notifyEqualityOfStateMachineValuesWithName: (NSString *) name
											 toBits: (AQBitfield *) bits
										 usingBlock: (void (^)(void)) block;

@end

/**
 When monitoring items within multiple enums/ranges, we will need to supply lists of name/mask pairs.
 Masks can be an `AQBitfield` or any form of `NSNumber`, or `NSNull` for no mask.
 However, for this particular API, there *must* be a matching number of names and masks. Fill an `NSArray`
 with `NSNulls` if necessary.
 */
@interface AQAppStateMachine (MultipleEnumerationNotifications)

/**
 Request notification of all changes matching a group of named enumerations, each with its own mask.
 @param names The names of the enumerations to monitor.
 @param masks A list of `AQBitfield` or `NSNumber` masks denoting which bits within the corresponding enumeration to monitor. Use `NSNull` to specify no mask.
 @param block A block to run upon any changes.
 */
- (void) notifyChangesToStateMachineValuesWithNames: (NSArray *) names
									  matchingMasks: (NSArray *) masks
										 usingBlock: (void (^)(void)) block;

/**
 Request notification when any item from a group of named enumerations matches an associated value.
 @param names The names of the enumerations to monitor.
 @param masks A list of `AQBitfield` or `NSNumber` masks denoting which bits within the corresponding enumeration to monitor. Use `NSNull` to specify no mask.
 @param values A list of `AQBitfield` or `NSNumber` values denoting values to compare against the corresponding enumeration.
 @param block A block to run upon any changes.
 */
- (void) notifyEqualityOfStateMachineValuesWithNames: (NSArray *) names
									   matchingMasks: (NSArray *) masks
											toValues: (NSArray *) values
										  usingBlock: (void (^)(void)) block;

@end

@interface AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

/**
 Returns the internal range allocated for a named enumeration.
 
 Primarily designed for internal use. Exposed to make unit testing easier.
 @param name The named enumeration whose range to return.
 @result The range occupied by the enumeration, or `{NSNotFound, 0}` if the enumeration could not be found.
 */
- (NSRange) underlyingBitfieldRangeForName: (NSString *) name;

@end
