/*!
 @header SortedDictionary.h
 TADAA
 */


#import <Foundation/Foundation.h>
#import "SortedDictionaryEntry.h"


@class AvlTree;


/**
 The SortedDictionary class declares the programmatic interface to dictionaries that maintain their
 keys in order. It emulates the interface of \c NSDictionary while maintaining an internal
 representation that keeps keys sorted. SortedDictionary objects manage immutable associations of
 keys and values. Use this class or its subclass MutableSortedDictionary when you need a convenient
 and efficient way to retrieve data associated with an arbitrary key, as well as the ability to
 enumerate key-value associations sorted by keys without having to sort.
 
 A key-value pair within a sorted dictionary is called an entry. Each entry consists of one object
 that represents the key and a second object that is that key’s value. Within a sorted
 dictionary, the keys are unique. That is, no two keys in a single dictionary are equal (as
 determined by \a isEqual:). In general, a key can be any object (provided that it conforms to the
 \c NSCopying protocol, and responds to the \a isLessThan: message —- see below).  The order of keys
 in the dictionary is defined by the \a isLessThan: message. Neither a key nor a value can be
 \c nil; if you need to represent a null value in a dictionary, you should use \c NSNull.
 
 An instance of SortedDictionary is an immutable dictionary: you establish its entries when it’s
 created and cannot modify them afterward.  An instance of MutableSortedDictionary is a mutable
 dictionary: you can add or delete entries at any time, and the object automatically allocates
 memory as needed.  The dictionary classes adopt the \c NSCopying and \c NSMutableCopying protocols,
 making it convenient to convert a dictionary of one type to the other.
  
 Internally, a sorted dictionary uses a self balancing binary tree to organize its storage and to
 provide rapid access to a value given the corresponding key.  However, the methods defined in this
 cluster insulate you from the complexities of working with trees and the algorithms involved in
 keeping them balanced.  The methods described below take keys and values directly, and not tree
 nodes.
 
 The computational complexity of locating the value of a key in a dictionary, of adding a key-value
 entry, and of removing a key-value entry is O(log \a n), where \a n is the number of entries
 already in the dictionary.
 
 The computational complexity of iterating through all the entries in the dictionaries is O(\a n).
 The complexity of iterating to the next entry is O(1) on average, but can be as much as O(log \a n)
 at worst.
 
 Methods that add entries to dictionaries — whether as part of initialization (for all dictionaries)
 or during modification (for mutable dictionaries) — copy each key argument (keys must conform to
 the \c NSCopying protocol) and add the copies to the dictionary. Each corresponding value object
 receives a \a retain message to ensure that it won’t be deallocated before the dictionary is
 through with it.
 */
@interface SortedDictionary : NSObject <NSCopying, NSMutableCopying> {
		AvlTree	*tree;
	}

	// Creating a Sorted Dictionary
	+ (id) dictionary;
	+ (id) dictionaryWithContentsOfFile: (NSString *) path;
	+ (id) dictionaryWithDictionary: (NSDictionary *) otherDictionary;
	+ (id) dictionaryWithSortedDictionary: (SortedDictionary *) otherDictionary;
	+ (id) dictionaryWithObject: (id) anObject forKey: (id) aKey;
	+ (id) dictionaryWithObjects: (NSArray *) objects forKeys: (NSArray *) keys;
	+ (id) dictionaryWithObjects: (id *) objects forKeys: (id *) keys count: (NSUInteger) count;
	+ (id) dictionaryWithObjectsAndKeys: (id) firstObject , ...;

	// Initializing a SortedDictionary Instance
	- (id) init;
	- (id) initWithContentsOfFile: (NSString *) path;
	- (id) initWithDictionary: (NSDictionary *) otherDictionary;
	- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary;
	- (id) initWithDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (id) initWithObjects: (NSArray *) objects forKeys: (NSArray *) keys;
	- (id) initWithObjects: (id *) objects forKeys: (id *) keys count: (NSUInteger) count;
	- (id) initWithObjectsAndKeys: (id) firstObject, ...;

	// Counting Entries
	- (NSUInteger) count;

	// Comparing Dictionaries
	- (BOOL) isEqualToDictionary: (NSDictionary *) otherDictionary;
	- (BOOL) isEqualToSortedDictionary: (SortedDictionary *) otherDictionary;

	// Accessing Keys and Values
	- (BOOL) containsKey: (id) aKey;
	- (id) objectForKey: (id) aKey;

	- (NSArray *) allEntries;
	- (NSArray *) allKeys;
	- (NSArray *) allKeysForObject: (id) anObject;
	- (NSArray *) allValues;
	- (void) getObjects: (id *) objects andKeys: (id *) keys;
	- (NSArray *) keysSortedByValueUsingSelector: (SEL) comparator;
	- (NSArray *) objectsForKeys: (NSArray *) keys notFoundMarker: (id) anObject;
	- (id) valueForKey: (NSString *) key;

	- (NSObject<SortedDictionaryEntry> *) firstEntry;
	- (NSArray *) firstEntries: (NSUInteger) count;

	- (NSObject<SortedDictionaryEntry> *) lastEntry;
	- (NSArray *) lastEntries: (NSUInteger) count;

	// Enumerating Keys, Values and Entries
	- (NSEnumerator *) entryEnumerator;
	- (NSEnumerator *) keyEnumerator;
	- (NSEnumerator *) objectEnumerator;

	- (NSEnumerator *) reverseEntryEnumerator;
	- (NSEnumerator *) reverseKeyEnumerator;
	- (NSEnumerator *) reverseObjectEnumerator;

	// Storing Dictionaries
	- (BOOL) writeToFile: (NSString *) path atomically: (BOOL) flag;
	- (BOOL) writeToURL: (NSURL *) aURL atomically: (BOOL) flag;

	// Creating a Description
	- (NSString *) description;

	// NSCoding protocol
	- (void) encodeWithCoder: (NSCoder *) encoder;
	- (id) initWithCoder: (NSCoder *) decoder;

	// NSCopying protocol
	- (id) copyWithZone: (NSZone *) zone;

	// NSMutableCopying protocol
	- (id) mutableCopyWithZone: (NSZone *) zone;

@end
