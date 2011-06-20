#import "MutableSortedDictionary.h"
#import "SortedDictionary+Private.h"
#import "AvlTree.h"
#import "Node.h"


@implementation MutableSortedDictionary


/**
 \brief Adds a given key-value pair to the receiver.
 
 \param anObject The value for \a key. The object receives a \c retain message before being added to
	the receiver. This value must not be \c nil.
 \param aKey The key for \a value. The key is copied (using \c copyWithZone:; keys must conform to
	the \c NSCopying protocol). The key must not be \a nil.
 
 \par Discussion
 Raises an \c NSInvalidArgumentException is \a aKey or \a anObject is \c nil. If you need to
 represnet a nil value in the dictionary, use \c NSNull.
 
 if \a aKey already exists in the receiver, the receiver's previous value object for that key is
 sent a \c release message and \a anObject takes its place.
 
 \par Computational Complexity
 O(log \a n), where \a n is the number of entries already in the dictionary.
 
 \see removeObjectForKey:
 */
- (void) setObject: (id) anObject forKey: (id) aKey {
	if (!aKey || !anObject) {
		@throw [NSException exceptionWithName: NSInvalidArgumentException
									   reason: @"nil key or value" userInfo: nil];
	}

	[tree setObject: anObject forKey: aKey];
}


/**
 \brief Adds a given key-value pair to the receiver.
 
 \param value The value for \a key.
 \param key The key for \a value. Note that when using key-value coding, the key must be a string
	(see Key-Value Coding Fundamentals).
 
 \par Discussion
 This method adds \a value and \a key to the receiver using setObject:forKey:, unless value is
 \c nil in which case the method instead attempts to remove key using removeObjectForKey:.
 
 \see SortedDictionary::valueForKey:
 */
- (void) setValue: (id) value forKey: (NSString *) key {
	if (value)	{ [self setObject: value forKey: key]; }
	else		{ [self removeObjectForKey: key]; }
}


/**
 \brief Adds to the receiver the entries from another dictionary.
 
 \param otherDictionary The dictionary from which to add entries.
 \param flag A flag that specifies whether values in \a otherDictionary should be copied. If YES,
	the members of otherDictionary are copied, and the copies are added to the receiver. If NO, the
	values of otherDictionary are retained by the receiver.
 
 \par Discussion
 Each value object from \a otherDictionary is sent a \c copyWithZone: message, if \a flag is \c YES,
 or a \c retain message, if \a flag is \c NO, before being added to the receiver. In contrast, each
 key object is copied (using \c copyWithZone:; keys must conform to the \c NSCopying protocol), and
 the copy is added to the receiver.
 
 \par
 Note that \c copyWithZone: is used to make copies. Thus, the receiver’s new member objects may be
 immutable, even though their counterparts in \a otherDictionary were mutable. Also, members must
 conform to the \c NSCopying protocol.
 
 \par
 If both dictionaries contain the same key, the receiver's previous value object for that key is
 sent a \c release message, and the new value takes its place.
 
 \par Computational Complexity
 O(\a n * log \a n), where n is the sum of the numbers of entries in the receiver and
 \a otherDictionary.
 
 \see setObject:forKey:
 \see addEntriesFromSortedDictionary:copyItems:
 */
- (void) addEntriesFromDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag {
	return [super addEntriesFromDictionary: otherDictionary copyItems: flag];
}


/**
 \brief Adds to the receiver the entries from another sorted dictionary.
 
 \param otherDictionary The sorted dictionary from which to add entries.
 \param flag A flag that specifies whether values in \a otherDictionary should be copied. If YES,
 the members of otherDictionary are copied, and the copies are added to the receiver. If NO, the
 values of otherDictionary are retained by the receiver.
 
 \par Discussion
 Each value object from \a otherDictionary is sent a \c copyWithZone: message, if \a flag is \c YES,
 or a \c retain message, if \a flag is \c NO, before being added to the receiver. In contrast, each
 key object is copied (using \c copyWithZone:; keys must conform to the \c NSCopying protocol), and
 the copy is added to the receiver.
 
 \par
 Note that \c copyWithZone: is used to make copies. Thus, the receiver’s new member objects may be
 immutable, even though their counterparts in \a otherDictionary were mutable. Also, members must
 conform to the \c NSCopying protocol.
 
 \par
 If both dictionaries contain the same key, the receiver's previous value object for that key is
 sent a \c release message, and the new value takes its place.
 
 \par Computational Complexity
 O(\a n * log \a n), where n is the sum of the numbers of entries in the receiver and
 \a otherDictionary.
 
 \see setObject:forKey:
 \see addEntriesFromDictionary:copyItems:
 */
- (void) addEntriesFromSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag {
	return [super addEntriesFromSortedDictionary: otherDictionary copyItems: flag];
}


/**
 \brief Sets the contents of the receiver to entries in a given dictionary.
 
 \param otherDictionary A dictionary containing the new entries.
 
 \par Discussion
 All entries are removed from the receiver (with MutableSortedDictionary::removeAllObjects), then
 each entry from \a otherDictionary is added into the receiver.
 
 \par Computational Complexity
 O(\a n * log \a n), where n is the number of entries in \a otherDictionary.
 */
- (void) setDictionary: (NSDictionary *) otherDictionary {
	[self removeAllObjects];
	[self addEntriesFromDictionary: otherDictionary copyItems: NO];
}




/**
 \brief Sets the contents of the receiver to entries in a given sorted dictionary.
 
 \param otherDictionary A sorted dictionary containing the new entries.
 
 \par Discussion
 All entries are removed from the receiver (with MutableSortedDictionary::removeAllObjects), then
 each entry from \a otherDictionary is added into the receiver.
 
 \par Computational Complexity
 O(\a n * log \a n), where n is the number of entries in \a otherDictionary.
 */
- (void) setSortedDictionary: (SortedDictionary *) otherDictionary {
	[self removeAllObjects];
	[self addEntriesFromSortedDictionary: otherDictionary copyItems: NO];
}


/**
 \brief Empties the receiver of its entries
 
 \par Discussion
 Each key and corresponding value object is sent a \c release message.
 
 \par Computational Complexity
 O(\a n), where n is the number of entries in the dictionary.
 
 \see removeObjectForKey:
 \see removeObjectsForKeys:
 */
- (void) removeAllObjects {
	[tree removeAllObjects];
}


/**
 \brief Removes a given key and its associated value from the receiver.
 
 \param aKey The key to remove.
 
 \par Discussion
 Does nothing if \a aKey does not exist.
 */
- (void) removeObjectForKey: (id) aKey {
	[tree removeObjectForKey: aKey];
}


/**
 \brief Removes from the receiver entries specified by elements in a given array.
 
 \param keyArray An array of objects specifying keys to remove.
 
 \par Discussion
 If a key in \a keyArray does not exist, the entry is ignored.
 
 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of entries in the dictionary.
 */
- (void) removeObjectsForKeys: (NSArray *) keyArray {
	int count = [keyArray count];
	for (int i = 0; i < count; ++i) {
		[tree removeObjectForKey: [keyArray objectAtIndex: i]];
	}
}


@end
