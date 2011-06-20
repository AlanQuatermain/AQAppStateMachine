#import <Foundation/Foundation.h>


@class Node;


@interface AvlTree : NSObject <NSCopying> {
		Node		*root;
		NSUInteger	count;
	}

	@property (readonly, nonatomic) Node		*root;
	@property (readonly, nonatomic) NSUInteger	count;

	- (id) init;

	- (BOOL) containsKey: (id) aKey;
	- (id) objectForKey: (id) aKey;

	- (NSEnumerator *) entryEnumerator;
	- (NSEnumerator *) reverseEntryEnumerator;

	- (void) setObject: (id) anObject forKey: (id) aKey;
	- (void) removeAllObjects;
	- (void) removeObjectForKey: (id) aKey;

	- (NSString *) description;

	// NSCoding
	- (void) encodeWithCoder: (NSCoder *) encoder;
	- (id) initWithCoder: (NSCoder *) decoder;

	// NSCopying
	- (id) copyWithZone: (NSZone *) zone;

@end
