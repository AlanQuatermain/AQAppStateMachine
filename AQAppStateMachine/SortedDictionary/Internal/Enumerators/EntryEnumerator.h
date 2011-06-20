#import <Foundation/Foundation.h>
#import "SortedDictionaryEntry.h"


@class Node;


@interface EntryEnumerator : NSEnumerator {
		Node	*node;
		SEL		first;
		SEL		second;
	}

	- (NSArray *) allObjects;
	- (id) nextObject;

@end
