//
//  AQNotifyingBitfield.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQBitfield.h"

@interface AQNotifyingBitfield : AQBitfield

- (void) notifyModificationOfBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block;

- (void) removeNotifierForBitsInRange: (NSRange) range;		// exact range match
- (void) removeAllNotifiersWithinRange: (NSRange) range;	// any wholly-contained ranges

@end
