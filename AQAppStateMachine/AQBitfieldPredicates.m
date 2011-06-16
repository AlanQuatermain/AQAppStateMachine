//
//  AQBitfieldPredicates.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQBitfieldPredicates.h"

@implementation NSPredicate (AQBitfieldPredicates)

+ (NSPredicate *) predicateForMatchingBitValue: (AQBit) value
									   atIndex: (NSUInteger) index
{
	return ( [NSPredicate predicateWithBlock: ^BOOL(__strong id evaluatedObject, NSDictionary *__strong bindings) {
		if ( [evaluatedObject isKindOfClass: [AQBitfield class]] == NO )
			return ( NO );
		return ( [evaluatedObject bitAtIndex: index] == value );
	}] );
}

+ (NSPredicate *) predicateForMatchingAllBits: (NSUInteger) value
									  inRange: (NSRange) range
{
	return ( [NSPredicate predicateWithBlock: ^BOOL(__strong id evaluatedObject, NSDictionary *__strong bindings) {
		if ( [evaluatedObject isKindOfClass: [AQBitfield class]] == NO )
			return ( NO );
		return ( [evaluatedObject bitsInRange: range matchBits: value] );
	}] );
}

+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
								  againstRange: (NSRange) range
{
	return ( [NSPredicate predicateWithBlock: ^BOOL(__strong id evaluatedObject, NSDictionary *__strong bindings) {
		if ( [evaluatedObject isKindOfClass: [AQBitfield class]] == NO )
			return ( NO );
		return ( [evaluatedObject bitsInRange: range equalToBitfield: match] );
	}] );
}

+ (NSPredicate *) predicateForMatchingBits: (NSUInteger) value
								maskedWith: (NSUInteger) mask
								   inRange: (NSRange) range
{
	return ( [NSPredicate predicateWithBlock: ^BOOL(__strong id evaluatedObject, NSDictionary *__strong bindings) {
		if ( [evaluatedObject isKindOfClass: [AQBitfield class]] == NO )
			return ( NO );
		return ( [evaluatedObject bitsInRange: range maskedWith: mask matchBits: value] );
	}] );
}

+ (NSPredicate *) predicateForMatchingBitfield: (AQBitfield *) match
									maskedWith: (AQBitfield *) mask
								  againstRange: (NSRange) range
{
	return ( [NSPredicate predicateWithBlock: ^BOOL(__strong id evaluatedObject, NSDictionary *__strong bindings) {
		if ( [evaluatedObject isKindOfClass: [AQBitfield class]] == NO )
			return ( NO );
		return ( [evaluatedObject bitsInRange: range maskedWith: mask equalToBitfield: match] );
	}] );
}

@end
