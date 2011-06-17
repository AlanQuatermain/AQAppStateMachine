//
//  AQAppStateMachine.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQNotifyingBitfield.h"

/*!
 This is intended to be a singleton class.
 */
@interface AQAppStateMachine : NSObject
{
	AQNotifyingBitfield *	_stateBits;
	NSMutableDictionary *	_namedRanges;
	NSMutableArray *		_matchDescriptors;
	NSMutableDictionary *	_notifierLookup;
	dispatch_queue_t		_syncQ;
}

/*!
 Obtain/create the singleton state machine instance.
 */
+ (AQAppStateMachine *) appStateMachine;

// core notification API— everything else funnels through these functions
- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block;

@end

/*!
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

@end

@interface AQAppStateMachine (MultipleEnumerationNotifications)

// TODO: Figure out a nice API to assign a block to bits in multiple named state enum ranges
// Probably it'll involve a custom descriptor object

@end

@interface AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name;

@end
