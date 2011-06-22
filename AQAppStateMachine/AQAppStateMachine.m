//
//  AQAppStateMachine.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQAppStateMachine.h"
#import "AQRange.h"
#import "AQStateMatchingDescriptor.h"
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
	
	// start out with 32 bits
	_stateBits = [[AQNotifyingBitfield alloc] init];
	_namedRanges = [NSMutableDictionary new];
	_matchDescriptors = [NSMutableArray new];
	_notifierLookup = [NSMutableDictionary new];
	_syncQ = dispatch_queue_create("net.alanquatermain.state-machine.sync", DISPATCH_QUEUE_SERIAL);
	
	return ( self );
}

- (void) dealloc
{
	if ( _syncQ != NULL )
		dispatch_release(_syncQ);
}

- (void) _runNotificationBlocksForChangeInRange: (NSRange) range
{
	for ( AQStateMatchingDescriptor * match in _matchDescriptors )
	{
		if ( [match matchesRange: range] == NO )
			continue;
		
		dispatch_block_t block = (dispatch_block_t)[_notifierLookup objectForKey: [match uniqueID]];
		if ( block != nil )
			block();
	}
}

- (void) _notifyForChangesToStatesMatchingDescriptor: (AQStateMatchingDescriptor *) desc
										  usingBlock: (void (^)(void)) block
{
	[_matchDescriptors addObject: desc];
	[_notifierLookup setObject: block forKey: [desc uniqueID]];
	
	NSRange notifyRange = desc.fullRange;
	[_stateBits notifyModificationOfBitsInRange: notifyRange usingBlock: ^(NSRange range) {
		// find and run any stored blocks
		[self _runNotificationBlocksForChangeInRange: range];
	}];
}

- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block
{
	[self notifyForChangesToStateBitsInRange: NSMakeRange(index, 1) usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block
{
	// create match descriptor and store it
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRange: range matchingMask: nil];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
						  maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWith32BitMask: mask forRange: range];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

- (void) notifyForChangesToStateBitsInRange: (NSRange) range
							 maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block
{
	AQStateMatchingDescriptor * desc = [[AQStateMatchingDescriptor alloc] initWithRange: range matchingMask: mask];
	[self _notifyForChangesToStatesMatchingDescriptor: desc usingBlock: block];
}

@end

@implementation AQAppStateMachine (NamedStateEnumerations)

static inline NSUInteger HighestOneBit32(NSUInteger x)
{
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	return ( x & ~(x >> 1) );
}

static inline NSUInteger HighestOneBit64(UInt64 x)
{
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	x |= x >> 32;
	return ( (NSUInteger)(x & ~(x >> 1)) );
}

- (void) addStateMachineValuesFromZeroTo: (NSUInteger) maxValue withName: (NSString *) name
{
	[self addStateMachineValuesUsingBitfieldOfLength: HighestOneBit32(maxValue) withName: name];
}

- (void) add64BitStateMachineValuesFromZeroTo: (UInt64) maxValue withName: (NSString *) name
{
	[self addStateMachineValuesUsingBitfieldOfLength: HighestOneBit64(maxValue) withName: name];
}

- (void) addStateMachineValuesUsingBitfieldOfLength: (NSUInteger) length withName: (NSString *) name
{
	// round up to byte-size if necessary
	length = (length + 7) & ~7;
	
	dispatch_sync(_syncQ, ^{
		AQRange * range = [[AQRange alloc] initWithRange: NSMakeRange(_stateBits.count, length)];
		[_namedRanges setObject: range forKey: name];
	});
}

@end

@implementation AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name
{
	AQRange * object = [_namedRanges objectForKey: name];
	if ( object == nil )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( object.range );
}

@end
