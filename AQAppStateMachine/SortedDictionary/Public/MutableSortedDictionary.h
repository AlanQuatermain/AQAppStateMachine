#import <Foundation/Foundation.h>
#import "SortedDictionary.h"


/**
 The \c MutableSortedDictionary class declares the programmatic interface to objects that manage
 mutable sorted associations of keys and values. It emulates the interface of
 \c NSMutableDictionary while maintaining and internal representation that keeps keys sorted. With
 its two efficient primitive methods - \a setObject:forKey: and \a removeObjectForKey: - this class
 adds modification operations to the basic operations it inherits from SortedDictionary.
 
 When an entry is removed from a mutable dictionary, the key and value objects that make up the
 entry receive \c release messages. If there are no further references to the objects, they’re
 deallocated. Note that if your program keeps a reference to such an object, the reference will
 become invalid unless you remember to send the object a \c retain message before it’s removed from
 the dictionary.
 
 The computational complexity of adding a key-value entry, and of removing a key-value entry is
 O(log \a n), where \a n is the number of entries already in the dictionary.
 */
@interface MutableSortedDictionary : SortedDictionary {
	}

	- (void) setObject: (id) anObject forKey: (id) aKey;
	- (void) setValue: (id) value forKey: (NSString *) key;
	- (void) addEntriesFromDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (void) addEntriesFromSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (void) setDictionary: (NSDictionary *) otherDictionary;
	- (void) setSortedDictionary: (SortedDictionary *) otherDictionary;

	- (void) removeAllObjects;
	- (void) removeObjectForKey: (id) aKey;
	- (void) removeObjectsForKeys: (NSArray *) keyArray;

@end
