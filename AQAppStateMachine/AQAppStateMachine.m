//
//  AQAppStateMachine.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQAppStateMachine.h"
#import <dispatch/dispatch.h>

@implementation AQAppStateMachine

+ (AQAppStateMachine *) appStateMachine
{
	static AQAppStateMachine * __singleton = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{__singleton = [[self alloc] init];});
	
	return ( __singleton );
}

- (id) init
{
    self = [super init];
	if ( self == nil )
		return ( nil );
	
	// start out with 128 bits
	_stateBits = [[AQBitfield alloc] initWithSize: 128];
	
	return ( self );
}

- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block
{
	
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block
{
	
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block
{
	
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block
{
	
}

@end
