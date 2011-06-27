#import "SortedDictionary+Private.h"
#import "AvlTree.h"
#import "EntryEnumerator.h"


@implementation SortedDictionary (Private)


- initWithTree: (AvlTree *) newTree {
	if (self = [super init]) {
#if USING_ARC
		tree = newTree;
#else
		tree = [newTree retain];
#endif
	}
	return self;
}


- (void) addEntriesFromDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag {
	for (id key in [otherDictionary keyEnumerator]) {
		id value = [otherDictionary objectForKey: key];
#if USING_ARC
		[tree setObject: (flag ? [value copy] : value) forKey: key];
#else
		[tree setObject: (flag ? [[value copy] autorelease] : value) forKey: key];
#endif
	}
}


- (void) addEntriesFromSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag {
	for	(NSObject<SortedDictionaryEntry> *entry in [otherDictionary entryEnumerator]) {
#if USING_ARC
		[tree setObject: (flag ? [[entry value] copy] : [entry value]) forKey: [entry key]];
#else
		[tree setObject: (flag ? [[[entry value] copy] autorelease] : [entry value]) forKey: [entry key]];
#endif
	}
}


@end
