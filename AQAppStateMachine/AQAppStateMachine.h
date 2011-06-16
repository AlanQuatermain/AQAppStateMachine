//
//  AQAppStateMachine.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQBitfield.h"

/*!
 This is intended to be a singleton class.
 */
@interface AQAppStateMachine : NSObject
{
	AQBitfield *	_stateBits;
}

/*!
 Obtain/create the singleton state machine instance.
 */
+ (AQAppStateMachine *) appStateMachine;

- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block;

@end
