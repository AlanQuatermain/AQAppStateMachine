//
//  AQIndexSetMasking.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-28.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (AQIndexSetMasking)
- (NSIndexSet *) indexSetMaskedWithIndexSet: (NSIndexSet *) mask;
@end

@interface NSMutableIndexSet (AQIndexSetMasking)
- (void) maskWithIndexSet: (NSIndexSet *) mask;
@end
