/*!
 \mainpage SortedDictionary
 
 \section intro_sec Introduction
 
 Writing for OS/X or the iPhone? Using \c NSDictionary to store and access key-value pairs? Ever
 tried to enumerate them all only to find they come back in some random order? As \c NSDictionary
 uses a hash table to map keys to values, it maintains no sort order whatsoever across its entries.
 
 The SortedDictionary class and its mutable companion, MutableSortedDictionary implement
 dictionaries that maintain a strong sort order across their keys. SortedDictionary and
 MutableSortedDictionary deliver high performance using an implementation of a self-balancing binary
 tree.
 
 \section capabilities_sec Capabilities
 
 The SortedDictionary and MutableSortedDictionary classes implement the interfaces of
 \c NSDictionary and \c NSMutableDictionary, respectively, and can serve as drop-in replacements.
 They support the \c NSCoding, \c NSCopying and \c NSMutableCopying protocols.
 
 Additionally, the sorted dictionary classes add methods allowing you to enumerate entries in both
 their forward and reverse key order, without having to sort and without any additional
 computational cost.
 
 \section usage_sec How to use SortedDictionary in your code
 
 \subsection usage_source Option 1: Using the source code
 
 Add the SortedDictionary folder to your project. Add all the files in the \a SortedDictionary
 folder, including its \a Internal and \a External folders, into your project. When you build your
 project, the sorted dictionaries classes will be compiled into your application.
 
 To create a sorted dictionary in code, include the appropriate header file:
 \code
 #import "SortedDictionary.h"
 
 - (void) someMethod {
 SortedDictionary *dict = [MutableSortedDictionary dictionary];
 
 [dict setValue: @"red" forKey: @"apple"];
 [dict setValue: @"yellow" forKey: @"banana"];
 [dict setValue: @"orange" forKey: @"orange"];
 
 NSString *color = [dict objectForKey: @"apple"];
 }
 \endcode
 
 \subsection usage_bin Option 2: Using the compiled frameworks
 
 Add the compiled frameworks to your project:
 -# In XCode, open \a Targets, then right-click (or ctrl-click) your target, and select Add>Existing
 Frameworks...
 -# The \a Target \a Info window opens. Click the + button below the \a Linked \a Libraries list.
 Select Add Other...
 -# Navigate to the folder that contains the compiled framework, and select
 SortedDictionary.Framework.
 -# Click \a Add, and close the \a Target \a Info window.
 
 \section license LICENSE
 
 MIT License
 
 Copyright (c) 2009 Oren Trutner
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
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
	+ (id) dictionaryWithObjects: (const id []) objects forKeys: (const id []) keys count: (NSUInteger) count;
	+ (id) dictionaryWithObjectsAndKeys: (id) firstObject , ...;

	// Initializing a SortedDictionary Instance
	- (id) init;
	- (id) initWithContentsOfFile: (NSString *) path;
	- (id) initWithDictionary: (NSDictionary *) otherDictionary;
	- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary;
	- (id) initWithDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag;
	- (id) initWithObjects: (NSArray *) objects forKeys: (NSArray *) keys;
	- (id) initWithObjects: (const id []) objects forKeys: (const id []) keys count: (NSUInteger) count;
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
	- (void) getObjects: (id __unsafe_unretained []) objects andKeys: (id __unsafe_unretained []) keys;
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

@interface SortedDictionary (AQAdditions)

#if NS_BLOCKS_AVAILABLE
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
#endif

@end
