#import <Foundation/Foundation.h>


@class EntryEnumerator;


@interface ObjectEnumerator : NSEnumerator {
		EntryEnumerator	*entryEnum;
	}

	- (id) initWithEnumerator: (NSEnumerator *) anEnumerator;

	- (NSArray *) allObjects;
	- (id) nextObject;

@end
