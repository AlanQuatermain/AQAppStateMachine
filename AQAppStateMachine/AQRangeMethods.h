//
//  AQRangeMethods.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (AQRangeMethods)

// so the compiler is happy if we don't target iOS 5 at all
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_5_0
- (void)enumerateRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block;
- (void)enumerateRangesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block;
- (void)enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block;
#endif

// our implementations, to be swapped in if necessary at runtime
- (void)aq_enumerateRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block;
- (void)aq_enumerateRangesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block;
- (void)aq_enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange range, BOOL *stop))block;

// custom methods
- (NSUInteger) numberOfRanges;

@end
