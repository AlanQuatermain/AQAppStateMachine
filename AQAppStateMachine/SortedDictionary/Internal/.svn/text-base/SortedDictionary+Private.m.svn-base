#import "SortedDictionary+Private.h"
#import "AvlTree.h"
#import "EntryEnumerator.h"


@implementation SortedDictionary (Private)


- initWithTree: (AvlTree *) newTree {
	if (self = [super init]) {
		tree = [newTree retain];
	}
	return self;
}


- (void) addEntriesFromDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag {
	for (id key in [otherDictionary keyEnumerator]) {
		id value = [otherDictionary objectForKey: key];
		[tree setObject: (flag ? [[value copy] autorelease] : value) forKey: key];
	}
}


- (void) addEntriesFromSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag {
	for	(NSObject<SortedDictionaryEntry> *entry in [otherDictionary entryEnumerator]) {
		[tree setObject: (flag ? [[[entry value] copy] autorelease] : [entry value]) forKey: [entry key]];
	}
}


@end
