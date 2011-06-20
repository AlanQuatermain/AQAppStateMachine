#import "SortedDictionary.h"
#import "SortedDictionary+Private.h"
#import "common.h"
#import "AvlTree.h"
#import "EntryEnumerator.h"
#import "KeyEnumerator.h"
#import "ObjectEnumerator.h"
#import "MutableSortedDictionary.h"
#import "PropertyListReader.h"
#import "PropertyListWriter.h"


@implementation SortedDictionary


// Internal method for initializing a sorted dictionary with value-key pairs from a null-
// terminated argument list
- (id) initWithObject: (id) firstObject andArglist: (va_list) arglist {
	if (self = [self init]) {
		id key, value;
		
		if (value = firstObject) {
			if (key = va_arg(arglist, id)) {
				do {
					if (!key || !value) {
						@throw [NSException exceptionWithName: NSInvalidArgumentException
													   reason: @"nil key or value" userInfo: nil];
					}
					
					[tree setObject: value forKey: key];
				} while ((value = va_arg(arglist, id)) && (key = va_arg(arglist, id)));
			}
		}		
	}
	return self;
}


/// \name Creating a Sorted Dictionary
/// \{

/**
 \brief Creates and returns an empty sorted dictionary.

 \return A new empty sorted dictionary.

 \par Computational Complexity
 O(1)
 */
+ (id) dictionary { return [[[self alloc] init] autorelease]; }


/**
 \brief Creates and returns a dictionary using the keys and values found in a file specified by a
	given path.
 
 \param path A full or relative pathname. The file identified by path must contain a string
	representation of a property list whose root object is a dictionary. The dictionary must contain
	only property list objects (instances of NSData, NSDate, NSNumber, NSString, NSArray, or
	NSDictionary). For more details, see Property List Programming Guide.
 
 \return A new dictionary that contains the dictionary at \a path, or \c nil if there is a file 
 error or if the contents of the file are an invalid representation of a dictionary.
 
 \par Computational Complexity
 O(\a n log \a n), where n is the number of entries in the property list dictionary.
 
 \par
 The execution time of this method is dominated by file access time. Should the property list file
 contain additional dictionaries or arrays, their construction time is included as well.
 
 \see initWithContentsOfFile:
 */
+ (id) dictionaryWithContentsOfFile: (NSString *) path {
	return [[[self alloc] initWithContentsOfFile: path] autorelease];
}


/**
 \brief Creates and returns a sorted dictionary containing the keys and values from a given \c
 NSDictionary.

 \param otherDictionary An \c NSDictionary containing keys and values for the new sorted
 dictionary.
 
 \return A new sorted dictionary containing keys and values found in \a otherDictionary.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see dictionaryWithSortedDictionary:
 \see initWithDictionary:
 */
+ (id) dictionaryWithDictionary: (NSDictionary *) otherDictionary {
	return [[[self alloc] initWithDictionary: otherDictionary] autorelease];
}


/**
 \brief Creates and returns a sorted dictionary containing the keys and values from another given
 sorted dictionary.
 
 \param otherDictionary A sorted dictionary containing keys and values for the new sorted
	dictionary.
 \return A new sorted dictionary containing keys and values found in \a otherDictionary.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see dictionaryWithDictionary:
 \see initWithSortedDictionary:
 */
+ (id) dictionaryWithSortedDictionary: (SortedDictionary *) otherDictionary {
	return [[[self alloc] initWithSortedDictionary: otherDictionary] autorelease];
}


/**
 \brief Creates and returns a sorted dictionary containing a given key and value.
 
 \param anObject The value corresponding to \a aKey.
 \param aKey The key for \a anObject.
 
 \return A new sorted dictionary containing a single object, \a anObject, for a single key,
	\a aKey.

 \par Computational Complexity
 O(1)

 \see dictionaryWithObjects:forKeys:
 \see dictionaryWithObjects:forKeys:count:
 \see dictionaryWithObjectsAndKeys:
 */
+ (id) dictionaryWithObject: (id) anObject forKey: (id) aKey {
	return [self dictionaryWithObjects: [NSArray arrayWithObject: anObject] forKeys: [NSArray arrayWithObject: aKey]];
}


/**
 \brief Creates and returns a sorted dictionary containing entries constructed from the contents
 of an array of keys and an array of values.

 \param objects An array containing the values for the new dictionary.
 \param keys An array containing the keys for the new dictionary. Each key is copied (using
	\c copyWithZone:; keys must conform to the \c NSCopying protocol) and the copy is added to the
	dictionary.
 \return A new sorted dictionary containing entries constructed from the contents of \a objects and
	\a keys.

 \par Discussion
 This method steps through the \a objects and \a keys arrays, creating entries in the new dictionary
 as it goes. An \c NSInvalidArgumentException is raised if objects and keys don’t have the same
 number of elements.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in the \a objects and \a keys
 arrays.

 \see initWithObjects:forKeys:
 \see dictionaryWithObject:forKey:
 \see dictionaryWithObjects:forKeys:count:
 \see dictionaryWithObjectsAndKeys:
 */
+ (id) dictionaryWithObjects: (NSArray *) objects forKeys: (NSArray *) keys {
	if ([objects count] != [keys count]) {
		@throw [NSException exceptionWithName: NSInvalidArgumentException
									   reason: @"key count differs from value count" userInfo: nil];
	}
	
	return [[[self alloc] initWithObjects: objects forKeys: keys] autorelease];
}


/**
 \brief Creates and returns a sorted dictionary containing \a count objects from the \a objects
	array.
 
 \param objects A C array of values for the new sorted dictionary.
 \param keys A C array of keys for the new sorted dictionary. Each key is copied (using
	\c copyWithZone:; keys must conform to the \c NSCopying protocol), and the copy is added to the
	new  dictionary.
 \param objectCount The number of elements to use from the \a keys and \a objects arrays.
	\a objectCount must not exceed the number of elements in \a objects or \a keys.
 \return A new sorted dictionary containing entries constructed from the contents of \a objects and
	\a keys.

 \par Discussion
 This method steps through the \a objects and \a keys arrays, creating entries in the new dictionary
 as it goes. An \c NSInvalidArgumentException is raised if a key or value object is \c nil.

 \par Computational Complexity
 O(\a objectCount * log \a objectCount)

 \see initWithObjects:forKeys:count:
 \see dictionaryWithObject:forKey:
 \see dictionaryWithObjects:forKeys:
 \see dictionaryWithObjectsAndKeys:
 */
+ (id) dictionaryWithObjects: (id *) objects forKeys: (id *) keys count: (NSUInteger) objectCount {
	return [[[self alloc] initWithObjects: objects forKeys: keys count: objectCount] autorelease];
}


/**
 \brief Creates and returns a sorted dictionary containing entries constructed from the specified
 set of values and keys.
 
 \param firstObject The first value to add to the new dictionary.
 \param ... First the key for \a firstObject, then a null-terminated list of alternating values and
	keys. If any key is \c nil, an \c NSInvalidArgumentException is raised.
 \return A new sorted dictionary containing entries from value-key pairs in the null-terminated
	argument list.

 \par Discussion
 This method is similar to SortedDictionary::dictionaryWithObjects:forKeys:, differing only in the
 way key-value pairs are specified.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in the argument list.

 \see initWithObjectsAndKeys:
 \see dictionaryWithObject:forKey:
 \see dictionaryWithObjects:forKeys:
 \see dictionaryWithObjects:forKeys:count:
 */
+ (id) dictionaryWithObjectsAndKeys: (id) firstObject, ... {
	SortedDictionary	*dictionary = nil;
	va_list				arglist;
	
	va_start(arglist, firstObject);
	dictionary = [[[self alloc] initWithObject: firstObject andArglist: arglist] autorelease];
	va_end(arglist);
	
	return dictionary;
}

/// \}


/// \name Initializing a SortedDictionary Instance
/// \{

/**
 \brief Initializes a newly allocated sorted dictionary.

 \return An initialized empty sorted dictionary -- which might be different than the original receiver.

 \par Computational Complexity
 O(1)

 \see dictionary
 */
- (id) init {
	if (self = [super init]) {
		tree = [[AvlTree alloc] init];
	}
	return self;
}


/**
 \brief Initializes a newly allocated dictionary using the keys and values found in a file at a
 given path.
 
 \param path A full or relative pathname. The file identified by path must contain a string
	representation of a property list whose root object is a dictionary. The dictionary must contain
	only property list objects (instances of NSData, NSDate, NSNumber, NSString, NSArray, or
	NSDictionary). For more details, see Property List Programming Guide.
 
 \return An initialized object—which might be different than the original receiver—that contains the
	dictionary at path, or nil if there is a file error or if the contents of the file are an
	invalid representation of a dictionary.

 \par Computational Complexity
 O(\a n log \a n), where n is the number of entries in the property list dictionary.
 
 \par
 The execution time of this method is dominated by file access time. Should the property list file
 contain additional dictionaries or arrays, their construction time is included as well.

 \see dictionaryWithContentsOfFile:
 */
- (id) initWithContentsOfFile: (NSString *) path {
	// read the file
	NSData *data = [NSData dataWithContentsOfFile: path];
	if (!data) { return nil; }
	
	// parse the file data as a plist
	id plist = [[[[PropertyListReader alloc] initWithData: data] autorelease] read];

	// check that the parsed plist object is indeed a dictionary
	if (!plist || ![plist isKindOfClass: [self class]]) { return nil; }

	self = plist;
	return self;
}


/**
 \brief Initializes a newly allocated sorted dictionary by placing in it the keys and values
 contained in a given \c NSDictionary.
 
 \param otherDictionary An \c NSDictionary containing keys and values for the new dictionary.
 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing the keys and values contained in \a otherDictionary

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see dictionaryWithDictionary:
 \see initWithSortedDictionary:
 */
- (id) initWithDictionary: (NSDictionary *) otherDictionary {
	return [self initWithDictionary: otherDictionary copyItems: NO];
}


/**
 \brief Initializes a newly allocated sorted dictionary by placing in it the keys and values
 contained in another given sorted dictionary.
 
 \param otherDictionary A sorted dictionary containing keys and values for the new dictionary.
 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing the keys and values contained in \a otherDictionary

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see dictionaryWithSortedDictionary:
 \see initWithDictionary:
 */
- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary {
	return [self initWithSortedDictionary: otherDictionary copyItems: NO];
}


/**
 \brief Initializes a newly allocated sorted dictionary by placing in it the keys and values
 contained in a given \c NSDictionary.
 
 \param otherDictionary An \c NSDictionary containing keys and values for the new dictionary.
 \param flag A flag that specified whether values in \a otherDictionary should be copied.
	If \c YES, the members of \a otherDictionary are copied, and the copies are added to the
	received. If \c NO, the values of \a otherDictionary are retained by the new dictionary.

 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing the keys and values contained in \a otherDictionary

 \par Discussion
 Note that \c copyWithZone: is used to make copies. Thus, the receiver's new member objects
 may be immutable, even though their counterparts in \a otherDictionary were mutable. Also,
 members must conform to the \c NSCopying protocol.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see initWithDictionary:
 \see initWithSortedDictionary:copyItems:
 */
- (id) initWithDictionary: (NSDictionary *) otherDictionary copyItems: (BOOL) flag {
	if (self = [self init]) {
		[self addEntriesFromDictionary: otherDictionary copyItems: flag];
	}
	return self;
}


/**
 \brief Initializes a newly allocated sorted dictionary by placing in it the keys and values
 contained in another given sorted dictionary.

 \param otherDictionary A sorted dictionary containing keys and values for the new dictionary.
 \param flag A flag that specified whether values in \a otherDictionary should be copied.
 If \c YES, the members of \a otherDictionary are copied, and the copies are added to the
 received. If \c NO, the values of \a otherDictionary are retained by the new dictionary.

 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing the keys and values contained in \a otherDictionary

 \par Discussion
 Note that \c copyWithZone: is used to make copies. Thus, the receiver's new member objects
 may be immutable, even though their counterparts in \a otherDictionary were mutable. Also,
 members must conform to the \c NSCopying protocol.

 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.

 \see initWithSortedDictionary:
 \see initWithDictionary:copyItems:
 */
- (id) initWithSortedDictionary: (SortedDictionary *) otherDictionary copyItems: (BOOL) flag {
	if (self = [self init]) {
		[self addEntriesFromSortedDictionary: otherDictionary copyItems: flag];
	}
	return self;
}


/**
 \brief Initializes a newly allocated sorted dictionary with entries constructed from the contents
 of the \a objects and \a keys arrays.

 \param objects An array containing the values for the new sorted dictionary.
 \param keys An array containing the keys for the new sorted dictionary.
 Each key is copied (using \c copyWithZone:; keys must conform to the \c NSCopying protocol),
 and the copy is added to the new dictionary.

 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing entries constructed from the contents of \a objects and \a keys.

 \par Discussion
 This method steps through the \a objects and \a keys arrays, creating entries in the new dictionary
 as it goes. An \c NSInvalidArgumentException is raised if the \a objects and \a keys arrays do not
 have the same number of elements.
 
 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in \a otherDictionary.
 
 \see dictionaryWithObjects:forKeys:
 \see initWithObjects:forKeys:
 \see initWithObjectsAndKeys:
 */
- (id) initWithObjects: (NSArray *) objects forKeys: (NSArray *) keys {
	if ([objects count] != [keys count]) {
		@throw [NSException exceptionWithName: NSInvalidArgumentException
									   reason: @"key count differs from value count" userInfo: nil];
	}
	
	if (self = [self init]) {
		for (NSUInteger i = 0, objectCount = [keys count]; i < objectCount; ++i) {
			id key		= [keys objectAtIndex: i];
			id value	= [objects objectAtIndex: i];
			
			if (!key || !value) {
				@throw [NSException exceptionWithName: NSInvalidArgumentException
											   reason: @"nil key or value" userInfo: nil];
			}
			
			[tree setObject: value forKey: key];
		}
	}
	return self;
}


/**
 \brief Initializes a newly allocated sorted dictionary containing \a objectCount objects from the
 \a objects array.
 
 \param objects A C array of values for the new sorted dictionary.
 \param keys A C array of keys for the new sorted dictionary. Each key is copied (using
	\c copyWithZone:; keys must conform to the \c NSCopying protocol), and the copy is added to the
	new  dictionary.
 \param objectCount The number of elements to use from the \a keys and \a objects arrays.
	\a objectCount must not exceed the number of elements in \a objects or \a keys.
 
 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing entries constructed from the contents of \a objects and \a keys.
 
 \par Discussion
 This method steps through the \a objects and \a keys arrays, creating entries in the new dictionary
	as it goes. An \c NSInvalidArgumentException is raised if a key or value object is \c nil.
 
 \par Computational Complexity
 O(\a objectCount * log \a objectCount)
 
 \see dictionaryWithObjects:forKeys:count:
 \see initWithObjects:forKeys:
 \see initWithObjectsAndKeys:
 */
- (id) initWithObjects: (id *) objects forKeys: (id *) keys count: (NSUInteger) objectCount {
	if (self = [self init]) {
		for (NSUInteger i = 0; i < objectCount; ++i) {
			id key		= keys[i];
			id value	= objects[i];
			
			if (!key || !value) {
				@throw [NSException exceptionWithName: NSInvalidArgumentException
											   reason: @"nil key or value" userInfo: nil];
			}
			
			[tree setObject: value forKey: key];
		}
	}
	return self;
}


/**
 \brief Initializes a newly allocated sorted dictionary with entries constructed from the
 specified set of values and keys.
 
 \param firstObject The first value to add to the dictionary.
 \param ... First the key for \a firstObject, then a null-terminated list of alternating values and
	keys. If any key is \c nil, an \c NSInvalidArgumentException is raised.
 
 \return An initialized sorted dictionary -- which might be different from the original receiver --
	containing entries from value-key pairs in the null-terminated argument list.
 
 \par Discussion
 This method is similar to SortedDictionary::initWithObjects:forKeys:, differing only in the way
 key-value pairs are specified.
 
 \par Computational Complexity
 O(\a n * log \a n), where \a n is the number of key-value pairs in the argument list.
 
 \see dictionaryWithObjectsAndKeys:
 \see initWithObjects:forKeys:
 \see initWithObjects:forKeys:count:
 */
- (id) initWithObjectsAndKeys: (id) firstObject, ... {
	if (!firstObject) { return [self init]; }
	
	va_list arglist;
	
	va_start(arglist, firstObject);
	self = [self initWithObject: firstObject andArglist: arglist];
	va_end(arglist);

	return self;
}

/// \}


/// \name Counting Entries
/// \{

/**
 \brief Returns the number of entries in the receiver.

 \return The number of entries in the receiver.

 \par Computational Complexity
 O(1)
 */
- (NSUInteger) count { return [tree count]; }

/// \}


/// \name Comparing Dictionaries
/// \{

/**
 \brief Returns a Boolean value that indicates whether the contents of the receiver are equal to the
 content of a given \c NSDictionary.

 \param otherDictionary The dictionary with which to compare the receiver.
 \return \c YES if the contents of \a otherDictionary are equal to the contents of the receiver,
	otherwise \c NO.

 \par Discussion
 Two dictionaries have equal contents if the each hold the same number of entries and, for a given
 key, the corresponding value objects in each dictionary satisfy the \a isEqual: test.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see isEqualToSortedDictionary:
 */
- (BOOL) isEqualToDictionary: (NSDictionary *) otherDictionary {
	if ([self count] != [otherDictionary count]) { return NO; }
	
	for (NSObject<SortedDictionaryEntry> *entry in [tree entryEnumerator]) {
		if (![[entry value] isEqual: [otherDictionary valueForKey: [entry key]]]) {
			return NO;
		}
	}
	
	return YES;
}


/**
 \brief Returns a Boolean value that indicates whether the contents of the receiver are equal to the
 content of another given sorted dictionary.

 \param otherDictionary The sorted dictionary with which to compare the receiver.
 \return \c YES if the contents of \a otherDictionary are equal to the contents of the receiver,
	otherwise \c NO.
 
 \par Discussion
 Two dictionaries have equal contents if the each hold the same number of entries and, for a given
 key, the corresponding value objects in each dictionary satisfy the \a isEqual: test.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see isEqualToDictionary:
 */
- (BOOL) isEqualToSortedDictionary: (SortedDictionary *) otherDictionary {
	if ([self count] != [otherDictionary count]) { return NO; }
	
	for (NSObject<SortedDictionaryEntry> *entry in [tree entryEnumerator]) {
		if (![[entry value] isEqual: [otherDictionary objectForKey: [entry key]]]) {
			return NO;
		}
	}
	
	return YES;
}

/// \}


/// \name Accessing Keys and Values
/// \{

/**
 \brief Checks if the dictionary has an entry for a given key.

 \param aKey The key to check for.
 \return \c YES if the dictionary contains a value for the key specified by \a aKey, \c NO
	otherwise.
 
 \par Computational Complexity
 O(log \a n), where \a n is the number of entries in the dictionary.
 
 \see objectForKey:
 */
- (BOOL) containsKey: (id) aKey { return [tree containsKey: aKey]; }


/**
 \brief Returns the value associated with a given key.

 \param aKey The key for which to return the corresponding value.
 \return The value associated with \a aKey, or \c nil if no value is associated with \a aKey.
 
 \par Computational Complexity
 O(log \a n), where \a n is the number of entries in the dictionary.

 \see allKeys
 \see allValues
 \see getObjects:andKeys:
 */
- (id) objectForKey: (id) aKey { return [tree objectForKey: aKey]; }


/**
 \brief Returns a new array containing all the entries in the receiver.
 
 \return A new array containing the receiver's entries, or an empty array if the receiver
 has no entries
 
 \par Discussion
 The elements in the array are sorted by the order of their keys in the dictionary. Each entry in
 the returned array implements the SortedDictionaryEntry protocol, allowing access to the entry's
 key and value.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see allKeys
 \see allValues
 \see getObjects:andKeys:
 \see objectEnumerator
 */
- (NSArray *) allEntries { return [[tree entryEnumerator] allObjects]; }


/**
 \brief Returns a new array containing the receiver's keys.

 \return A new array containing the receiver's keys, or an empty array if the receiver has no
	entries.
 
 \par Discussion
 The elements in the array are sorted by their order in the dictionary.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see allEntries
 \see allValues
 \see allKeysForObject:
 \see getObjects:andKeys:
 \see keyEnumerator
 */
- (NSArray *) allKeys { return [[self keyEnumerator] allObjects]; }


/**
 \brief Returns a new array containing the keys corresponding to all occurences of a given object in
 the receiver.
 
 \param anObject The value to look for in the receiver.
 \return A new array containing the keys corresponding to all occurences of \a anObject in the
 receiver. If no object matching \a anObject is found, returns an empty array.
 
 \par Discussion
 Each object in the receiver(!) is sent an \a isEqual: message to determine if it's equal to
 \a anObject.
 
 \par
 If you find yourself using this method, you are most likely doing it all wrong.  Dictionaries are
 optimized for accessing values via keys, not the other way around.  Instead, consider reversing
 keys and values, or adding a second dictionary with the keys and values reversed.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see allKeys
 \see keyEnumerator
 */
- (NSArray *) allKeysForObject: (id) anObject {
	NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSObject<SortedDictionaryEntry> *entry in [tree entryEnumerator]) {
		if ([[entry value] isEqual: anObject]) { [keys addObject: [entry key]]; }
	}
	
	return keys;
}


/**
 \brief Returns a new array containing the receiver's values.

 \return A new array containing the receiver's values, or an empty array if the receiver has no
	entries.
 
 \par Discussion
 The elements in the array are sorted by the order of their keys in the dictionary.
  
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 
 \see allKeys
 \see allEntries
 \see getObjects:andKeys:
 \see objectEnumerator
 */
- (NSArray *) allValues { return [[self objectEnumerator] allObjects]; }


/**
 \brief Returns by reference C arrays of the keys and values in the receiver.

 \param objects Upon return, contains a C array of the values in the receiver.
 \param keys Upon return, contains a C array of the keys in the receiver.
 
 \par Discussion
 The elements in the returned arrays are sorted such that the first element in \a objects is the
 value for the first key in \a keys, and so on.  The elements in \a keys are sorted by their order
 in the dictionary.
 
 \par
 The caller has to allocate the \a objects and \a keys arrays before the call, and is responsible
 for releasing them.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.

 \see allKeys
 \see allValues
 \see objectForKey:
 \see objectsForKeys:notFoundMarker:
 */
- (void) getObjects: (id *) objects andKeys: (id *) keys {
	NSUInteger i = 0;
	for (NSObject<SortedDictionaryEntry> *entry in [tree entryEnumerator]) {
		keys[i]			= [entry key];
		objects[i++]	= [entry value];
	}
}


/**
 \brief Returns an array of the receiver's keys, in the order they would be in if the receiver were
 sorted by its values.
 
 \param comparator A selector that specifies the method to use to compare the values in the
	receiver. The \a comparator method should return \c NSOrderedAscending if the receiver is
	smaller than the argument, \c NSOrderedDescending if the receiver is larger than the argument,
	and \c NSOrderedSame if they are equal. See \a compare:
 
 \return An array of the receiver's keys, in the order they would be in if the receiver were sorted
	by its values.
 
 \par Discussion
 Pairs of dictionary values are compared using the comparison method specified by comparator; the
 comparator message is sent to one of the values and has as its single argument the other value from
 the dictionary.
 
 \see allKeys
 \see sortedArrayUsingSelector: (NSArray)
 */
- (NSArray *) keysSortedByValueUsingSelector: (SEL) comparator {
	NSArray				*entries		= [self allEntries];
	NSSortDescriptor	*sort			= [[[NSSortDescriptor alloc] initWithKey: @"value"
																	   ascending: YES
																		selector: comparator] autorelease];
	NSArray				*sortedEntries	= [entries sortedArrayUsingDescriptors:[NSArray arrayWithObject: sort]];
	NSArray				*sortedKeys		= [sortedEntries valueForKey: @"key"];
	
	return sortedKeys;
}


/**
 \brief Returns the set of objects from the receiver that corresponds to the specified \a keys as an
 NSArray.
 
 \param keys The keys for which to return corresponding values.
 \param anObject The marker object to place in the corresponding element of the returned array if an
	object isn't found in the receiver to correspond to a given key.
 
 \par Discussion
 The objects in the returned array and the \a keys array have a one-for-one correspondence, so that
 the \a n-th object in the returned array corresponds with the \a n-th key in \a keys.
 
 \par Computational Complexity
 O(\a c * log \a n), where \a n is the number of entries in the dictionary and \a c is the number of
 keys in \a keys.
 
 \see allKeys
 \see allValues
 \see getObjects:andKeys:
 */
- (NSArray *) objectsForKeys: (NSArray *) keys notFoundMarker: (id) anObject {
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity: [keys count]];
	
	for (int i = 0; i < [keys count]; ++i) {
		id value = [self objectForKey: [keys objectAtIndex: i]];
		[objects addObject: value ? value : anObject];
	}
	
	return objects;
}


/**
 \brief Returns the value associated with a given key.
 
 \param key The key for which to return the corresponding value. Note that when using key-value
 coding, the key must be a string (see Key-Value Coding Fundamentals).
 
 \return The value associated with key.
 
 \par Discussion
 If \a key does not start with “@”, invokes objectForKey:. If \a key does start with “@”, strips the
 “@” and invokes [super valueForKey:] with the rest of the key.
 
 \see MutableSortedDictionary::setValue:forKey:
 \see getObjects:andKeys:
 */
- (id) valueForKey: (NSString *) key {
	if (([key length] > 0) && ([key characterAtIndex: 0] == '@')) {
		return [super valueForKey: [key substringFromIndex: 1]];
	}
	
	return [self objectForKey: key];
}


/**
 \brief Gets the first entry in the dictionary.
 
 \return The first entry in the dictionary.
 
 \par Discussion
 The entry for the key with the lowest sort value in the dictionary is returned. The returned object
 implements the SortedDictionaryEntry protocol, allowing you to obtain the entry's key and value.
 
 \par Computational Complexity
 O(log \a n), where \a n is the number of entries in the dictionary.
 
 \see firstEntries:
 \see lastEntry
 */
- (NSObject<SortedDictionaryEntry> *) firstEntry {
	return [[tree entryEnumerator] nextObject];
}


/**
 \brief Gets the first \a count entries in the dictionary.
 
 \return An array containing the first \a count entries in the dictionary, sorted by their key.
 
 \par Discussion
 The \a count entries with the lowest keys in the sort order are returned, sorted with the lowest
 key first. Each array entry implements the SortedDictionaryEntry protocol, allowing you to obtain
 the entry's key and value. If there are fewer than \a count entries in the dictionary, all the
 entries in the dictionary are returned.
 
 \par Computational Complexity
 O(log \a n + \a count), where \a n is the number of entries in the dictionary.
 
 \see firstEntry
 \see lastEntries:
 */
- (NSArray *) firstEntries: (NSUInteger) count {
	int				limitedCount	= min(count, [self count]);
	NSMutableArray	*entries		= [NSMutableArray arrayWithCapacity: limitedCount];
	NSEnumerator	*entryEnum		= [tree entryEnumerator];
	
	for (int i = 0; i < limitedCount; ++i) {
		[entries addObject: [entryEnum nextObject]];
	}
	
	return entries;
}




/**
 \brief Gets the last entry in the dictionary.
 
 \return The last entry in the dictionary.
 
 \par Discussion
 The entry for the key with the highest sort value in the dictionary is returned. The returned
 object implements the SortedDictionaryEntry protocol, allowing you to obtain the entry's key and
 value.
 
 \par Computational Complexity
 O(log \a n), where \a n is the number of entries in the dictionary.
 
 \see lastEntries:
 \see firstEntry
 */
- (NSObject<SortedDictionaryEntry> *) lastEntry {
	return [[tree reverseEntryEnumerator] nextObject];
}


/**
 \brief Gets the last \a count entries in the dictionary.
 
 \return An array containing the last \a count entries in the dictionary, sorted by their key.
 
 \par Discussion
 The \a count entries with the highest keys in the sort order are returned, sorted with the lowest
 key first. Each array entry implements the SortedDictionaryEntry protocol, allowing you to obtain
 the entry's key and value. If there are fewer than \a count entries in the dictionary, all the
 entries in the dictionary are returned.
 
 \par Computational Complexity
 O(log \a n + \a count), where \a n is the number of entries in the dictionary.
 
 \see lastEntry
 \see firstEntries:
 */
- (NSArray *) lastEntries: (NSUInteger) count {
	int				limitedCount	= min(count, [self count]);
	NSMutableArray	*entries		= [NSMutableArray arrayWithCapacity: limitedCount];
	NSEnumerator	*entryEnum		= [tree reverseEntryEnumerator];
	
	for (int i = 0; i < limitedCount; ++i) { [entries addObject: self]; }
	for (int i = limitedCount - 1; i >= 0; --i) {
		[entries replaceObjectAtIndex: i withObject: [entryEnum nextObject]];
	}
	
	return entries;
}

/// \}


/// \name Enumerating Keys, Values and Entries
/// \{

/**
 \brief Returns an enumerator object that lets you access each entry in the receiver.
 
 \return An enumerator object that lets you access each entry in the receiver.
 
 \par Discussion
 The enumerator retrieves each entry according to the order of its key in the sorted dictionary.
 Each entry implements the SortedDictionaryEntry protocol, allowing access to the entry's key and
 value.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allValues method to create a "snapshot"
 of the dictionary's values.  Work from this snapshot to modify the values.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next entry.
 
 \see keyEnumerator
 \see objectEnumerator
 \see allKeys
 \see allEntries
 \see allValues
 */
- (NSEnumerator *) entryEnumerator { return [tree entryEnumerator]; }


/**
 \brief Returns an enumerator object that lets you access each key in the receiver.
 
 \return An enumerator object that lets you access each key in the receiver.
 
 \par Discussion
 The enumerator retrieves each key according to its order in the sorted dictionary.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allKeys method to create a "snapshot"
 of the dictionary's keys.  Then use this snapshot to traverse the entries, modifying
 them along the way.
 
 \par
 Note that the SortedDictionary::objectEnumerator method provides a convenient way to access each
 value in the dictionary.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next key.
 
 \see allKeys
 \see allKeysForObject:
 \see getObjects:andKeys:
 \see objectEnumerator
 \see entryEnumerator
 */
- (NSEnumerator *) keyEnumerator { return [[[KeyEnumerator alloc] initWithEnumerator: [tree entryEnumerator]] autorelease]; }


/**
 \brief Returns an enumerator object that lets you access each value in the receiver.
 
 \return An enumerator object that lets you access each value in the receiver.
 
 \par Discussion
 The enumerator retrieves each value according to the order of the key it is associated
 with in the sorted dictionary.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allValues method to create a "snapshot"
 of the dictionary's values.  Work from this snapshot to modify the values.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next value.
 
 \see keyEnumerator
 \see entryEnumerator
 \see allValues
 */
- (NSEnumerator *) objectEnumerator	{ return [[[ObjectEnumerator alloc]	initWithEnumerator: [tree entryEnumerator]] autorelease]; }


/**
 \brief Returns an enumerator object that lets you access each entry in the receiver in reverse
	order.
 
 \return An enumerator object that lets you access each entry in the receiver in reverse order.
 
 \par Discussion
 The enumerator retrieves each entry according to the reverse order of its key in the sorted
 dictionary.  The entry with the last key is retrieved first, followed by the preceding entry for
 the second to last key, and so on. Each entry implements the SortedDictionaryEntry protocol,
 allowing access to the entry's key and value.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allValues method to create a "snapshot"
 of the dictionary's values.  Work from this snapshot to modify the values.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next entry.

 \see entryEnumerator
 \see reverseKeyEnumerator
 \see reverseObjectEnumerator
 \see allKeys
 \see allEntries
 \see allValues
 */
- (NSEnumerator *) reverseEntryEnumerator { return [tree reverseEntryEnumerator]; }


/**
 \brief Returns an enumerator object that lets you access each key in the receiver in reverse order.
 
 \return An enumerator object that lets you access each key in the receiver in reverse order.
 
 \par Discussion
 The enumerator retrieves each key according to its reverse order in the sorted dictionary. The last
 key is retrieved first, followed by the second to last key, and so on.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allKeys method to create a "snapshot"
 of the dictionary's keys.  Then use this snapshot to traverse the entries, modifying
 them along the way.
 
 \par
 Note that the SortedDictionary::reverseObjectEnumerator method provides a convenient way to access
 each value in the dictionary in reverse key order.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next key.
 
 \see allKeys
 \see allKeysForObject:
 \see getObjects:andKeys:
 \see keyEnumerator
 \see reverseObjectEnumerator
 \see reverseEntryEnumerator
 */
- (NSEnumerator *) reverseKeyEnumerator { return [[[KeyEnumerator alloc] initWithEnumerator: [tree reverseEntryEnumerator]] autorelease]; }


/**
 \brief Returns an enumerator object that lets you access each value in the receiver in reverse key
	order.
 
 \return An enumerator object that lets you access each value in the receiver in reverse key order.
 
 \par Discussion
 The enumerator retrieves each value according to the reverse order of the key it is associated
 with in the sorted dictionary. The value for the last key is returned first, followed by the value
 for the second to last key, and so on.
 
 \par
 If you use this method with instance of mutable subclasses of SortedDictionary,
 your code should not modify the entries during enumeration. If you intend to
 modify the entries, use the SortedDictionary::allValues method to create a "snapshot"
 of the dictionary's values.  Work from this snapshot to modify the values.
 
 \par Computational Complexity
 O(1) to obtain an enumerator.
 
 \par
 O(1) on average, and O(log \a n) at worst, where \a n is the number of entries in the dictionary,
 to iterate over to the next value.
 
 \see objectEnumerator
 \see reverseKeyEnumerator
 \see reverseEntryEnumerator
 \see allValues
 */
- (NSEnumerator *) reverseObjectEnumerator { return [[[ObjectEnumerator alloc] initWithEnumerator: [tree reverseEntryEnumerator]] autorelease]; }

/// \}


/// \name Storing Dictionaries
/// \{

- (BOOL) writeToFile: (NSString *) path atomically: (BOOL) flag {
	PropertyListWriter *writer = [[[PropertyListWriter alloc] init] autorelease];
	NSData *data = [writer writePropertyList: self];
	return [data writeToFile: path atomically: flag];
}


- (BOOL) writeToURL: (NSURL *) aURL atomically: (BOOL) flag {
	PropertyListWriter *writer = [[[PropertyListWriter alloc] init] autorelease];
	NSData *data = [writer writePropertyList: self];
	return [data writeToURL: aURL atomically: flag];
}

/// \}


/// \name Creating a Description
/// \{

/**
 \brief Returns a string that represents the contents of the receiver, formatted as a tree.
 
 \return A string that represents the contents of the receiver, formatted as a tree.
 
 \par Discussion
 Each node in the binary tree is presented in a single line, indented according to its location in
 the tree. This method is intended to produce readable output for debugging purposes.
 */
- (NSString *) description { return [tree description]; }

/// \}


// destructor
- (void) dealloc {
	[tree release];
	[super dealloc];
}


/// \name NSCoding protocol
/// \{

/**
 \brief Encodes the receiver using a given archiver.
 
 \param encoder An archiver object.
 
 \par Computational Complexity
 O(\a n), where n is the number of entries in the dictionary.
 */
- (void) encodeWithCoder: (NSCoder *) encoder {
	[encoder encodeObject: tree forKey: @"Tree"];
}


/**
 \brief Returns an object initialized from data in a given unarchiver.
 
 \param decoder An unarchiver object.
 
 \return \c self, initialized using the data in \a decoder.
 
 \par Computational Complexity
 O(\a n), where n is the number of encoded dictionary entries in the archive.
 */
- (id) initWithCoder: (NSCoder *) decoder {
	if (self = [super init]) {
		tree = [[decoder decodeObjectForKey:	@"Tree"] retain];
	}
	return self;
}

/// \}


/// \name NSCopying protocol
/// \{

/**
 \brief Returns a new instance that's a copy of the receiver.
 
 \param zone The zone identifies an area of memory from which to allocate for the new instance. If
	\a zone is \c NULL, the new instance is allocated from the default zone, which is returned from
	the function \c NSDefaultMallocZone.
 
 \return a new instance of SortedDictionary that's a copy of the receiver.
 
 \par Discussion
 The returned object is implicitly retained by the sender, who is responsible for releasing it. The
 copy returned is immutable. Keys in the returned dictionary are copies of the keys in the receiver.
 Values in the returned dictionary are not copies, and refer to the exact same objects as in the
 receiver.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 */
- (id) copyWithZone: (NSZone *) zone {
	return [[SortedDictionary alloc] initWithTree: [[tree copyWithZone: zone] autorelease]];
}

/// \}


/// \name NSMutableCopying protocol
/// \{

/**
 \brief Returns a new instance that's a mutable copy of the receiver.
 
 \param zone The zone identifies an area of memory from which to allocate for the new instance. If
 \a zone is \c NULL, the new instance is allocated from the default zone, which is returned from
 the function \c NSDefaultMallocZone.
 
 \return a new instance of MutableSortedDictionary that's a copy of the receiver.
 
 \par Discussion
 The returned object is implicitly retained by the sender, who is responsible for releasing it. The
 copy returned is mutable whether the original is mutable or not. Keys in the returned dictionary
 are copies of the keys in the receiver. Values in the returned dictionary are not copies, and refer
 to the exact same objects as in the
 receiver.
 
 \par Computational Complexity
 O(\a n), where \a n is the number of entries in the dictionary.
 */
- (id) mutableCopyWithZone: (NSZone *) zone {
	return [[MutableSortedDictionary alloc] initWithTree: [[tree copyWithZone: zone] autorelease]];
}

/// \}


@end
