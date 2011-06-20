#import <Foundation/Foundation.h>
#import "SortedDictionary.h"


@interface SortedDictionary (Private)

	- initWithTree: (AvlTree *) newTree;
	- (void) addEntriesFromDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (void) addEntriesFromSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag;

@end
