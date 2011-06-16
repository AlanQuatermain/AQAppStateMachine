//
//  AQRange.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Kobo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQRange : NSObject
{
	NSRange		_range;
}

- (id) initWithRange: (NSRange) range;		// designated initializer

@property (nonatomic, readonly) NSRange range;

- (BOOL) isEqual: (id) object;
- (BOOL) isEqualToNSRange: (NSRange) nsRange;

- (NSComparisonResult) compare: (AQRange *) other;
- (NSComparisonResult) compareToNSRange: (NSRange) nsRange;

@end
