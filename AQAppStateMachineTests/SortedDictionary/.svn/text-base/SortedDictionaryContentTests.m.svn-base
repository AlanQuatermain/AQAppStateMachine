#import "SortedDictionaryContentTests.h"
#import "SortedDictionary+Test.h"
#import "MutableSortedDictionary.h"


@implementation SortedDictionaryContentTests


- (void) setUp {
	NSMutableArray *keys	= [NSMutableArray arrayWithCapacity: 1000];
	NSMutableArray *values	= [NSMutableArray arrayWithCapacity: 1000];
	
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		
		[keys	addObject: key];
		[values	addObject: value];
	}
	
	nsd = [[NSDictionary		alloc] initWithObjects: values forKeys: keys];
	srd = [[SortedDictionary	alloc] initWithObjects: values forKeys: keys];
}


- (void) tearDown {
	[srd release];
	[nsd release];
}


- (void) testSetup {
	STAssertEquals(1000U, [nsd count], @"Expected 1000 elements");
	STAssertEquals(1000U, [srd count], @"Expected 1000 elements");
		
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([srd balancesAreCorrect], @"The dictionary is not balanced correctly");
	
}


- (void) testIsEqualToDictionary {
	// compare the SortedDictionary to the NSDictionary (should be identical)
	STAssertTrue([srd isEqualToDictionary: nsd], @"The dicts should be identical");
	
	// compare a mutable copy of the SortedDictionary to the NSDictionary (should be identical)
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary: nsd];
	STAssertTrue([srd isEqualToDictionary: d], @"The dicts should be identical");
	
	// remove one element from the mutable version, then compare again (should not be identical)
	[d removeObjectForKey: @"725"];
	STAssertFalse([srd isEqualToDictionary: d], @"The dicts should not be identical");
}


- (void) testIsEqualToSortedDictionary {
	// create a copy of the SortedDictionary
	SortedDictionary *d1 =
		[[[SortedDictionary alloc] initWithSortedDictionary: srd
												  copyItems: YES] autorelease];
	
	// compare the SortedDictionary to its copy (should be identical)
	STAssertTrue([srd isEqualToSortedDictionary: d1], @"The dicts should be identical");
	
	// create a mutable copy of the sorted dictionary
	MutableSortedDictionary *d2 =
		[[[MutableSortedDictionary alloc] initWithSortedDictionary: srd
														 copyItems: YES] autorelease];
	
	// compare to the mutable copy (should be identical)
	STAssertTrue([srd isEqualToSortedDictionary: d2], @"The dicts should be identical");
	
	// remove one element from the mutable version, then compare again (should not be identical)
	[d2 removeObjectForKey: @"725"];
	STAssertFalse([srd isEqualToSortedDictionary: d2], @"The dicts should not be identical");
}


- (void) testContainsKey {
	// check for a sample of keys we know should be in the dictionary
	for (int i = 0; i < 200; i += 19) {
		NSString *key = [NSString stringWithFormat: @"%d", i];
		STAssertTrue([srd containsKey: key], @"Should have contained key %@", key);
	}
	
	// check for a sample of keys we know should NOT be in the dictionary
	for (int i = 1000; i < 1200; i += 19) {
		NSString *key = [NSString stringWithFormat: @"%d", i];
		STAssertFalse([srd containsKey: key], @"Should have contained key %@", key);
	}
}


- (void) testObjectForKey {
	// check for a number of keys we know are in the dictionary, and compare to expected values
	for (int i = 0; i < 1000; i += 37) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value	= [NSString stringWithFormat: @"%d", i % 10];
		
		STAssertEqualObjects(value, [srd objectForKey: key], @"%@ != %@", value, [srd objectForKey: key]);
	}
}


- (void) testAllKeys {
	STAssertEqualObjects(
		[srd allKeys],
		[[nsd allKeys] sortedArrayUsingSelector: @selector(isGreaterThan:)],
		@"arrays not equal");
}


- (void) testAllKeysForObject {
	// check all values we know are in the dictionary
	for (int i = 0; i <= 9; ++i) {
		
		// get the list of keys for the value from both the SortedDictionary and the NSDictionary
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		NSArray	*a1 = [srd allKeysForObject: value];
		NSArray *a2 = [[nsd allKeysForObject: value] sortedArrayUsingSelector: @selector(isGreaterThan:)];
		
		// check that all the expected keys for the value were found
		STAssertEquals(100U, [a1 count], @"100 elements expected");
		STAssertEquals(100U, [a2 count], @"100 elements expected");
		
		// check that the keys found were the same on both dictionaries
		STAssertTrue([a1 isEqualToArray: a2], @"Expected equal arrays");
	}
}


- (void) testAllValues {
	// obtain all values from both the SortedDictionary and the NSDictionary; sort both to
	// ensure identical order
	NSArray *a1 = [[srd allValues] sortedArrayUsingSelector: @selector(isGreaterThan:)];
	NSArray *a2 = [[nsd allValues] sortedArrayUsingSelector: @selector(isGreaterThan:)];
	
	// check that both values arrays have identical content
	STAssertTrue([a1 isEqualToArray: a2], @"All values were expected to be equal");
}


- (void) testGetObjectsAndKeys {
	// set up arrays for the keys and values
	id keys[1001];
	id values[1001];
	
	// set up sentinels at the end of the arrays, to ensure the method under test does not write
	// beyond the limit
	keys[1000] = values[1000] = self;
	
	// call method under test
	[srd getObjects: values andKeys: keys];

	// ensure the sentinels were not overwritten
	STAssertEquals(keys[1000],		self, @"getObjects:andKeys: overwrote the keys sentinel");
	STAssertEquals(values[1000],	self, @"getObjects:andKeys: overwrote the values sentinel");
	
	// check a sample of the returned keys for correct value and increasing order
	for (int i = 1; i < 1000; i += 19) {
		
		// check for correct value for the key
		STAssertEqualObjects(
			values[i],
			[nsd objectForKey: keys[i]],
			@"Expected value #%@ for key %@, but found %@",
			values[i], keys[i], [nsd objectForKey: keys[i]]);
		
		// check for increasing key order
		STAssertTrue(
			[keys[i] isGreaterThan: keys[i - 1]],
			@"Expected keys in increasing order, but found keys[%d]=%@, keys[%d]=%@",
			i - 1, keys[i - 1], i, keys[i]);
	}
}


- (void) testKeysSortedByValueUsingSelector {
	// obtain the sorted keys
	NSArray *a = [srd keysSortedByValueUsingSelector: @selector(compare:)];

	// check that we get as many keys as there are dictionary entries
	STAssertEquals(1000U, [a count], @"Expected 1000 keys");
	
	// get the first value, check that it's valid
	NSString *prevValue = [srd objectForKey: [a objectAtIndex: 0]];
	STAssertNotNil(prevValue, @"Expected a non-nil value");
	
	// iterate over all remaining keys
	for (int i = 1; i < 1000; ++i) {
		
		// check that the next key is an NSString
		STAssertTrue([[a objectAtIndex: i] isKindOfClass: [NSString class]], @"Expected a string key");
		
		// get the key's value, check that it's not nil
		NSString *value = [srd objectForKey: [a objectAtIndex: i]];
		STAssertNotNil(value, @"Expected a non-nil value");
		
		// check that the sort order is maintained between this entry and the previous one
		STAssertTrue(
			[prevValue isLessThanOrEqualTo: value],
			@"Expected keys in increasing order. Found %@ followed by %@ for keys %@ then %@",
			prevValue, value, [a objectAtIndex: i - 1], [a objectAtIndex: i]);
		
		prevValue = value;
	}
}


- (void) testObjectsForKeysNotFoundMarker {
	
	// prepare an array of some keys to query for
	NSMutableArray *keys = [NSMutableArray array];
	for (int i = 0; i < 2000; i += 139) {
		NSString *key = [NSString stringWithFormat: @"%d", i];
		[keys addObject: key];
	}
	
	// obtain the values from both dictionaries, and compare the results
	NSArray *a1 = [srd objectsForKeys: keys notFoundMarker: @"not found"];
	NSArray *a2 = [nsd objectsForKeys: keys notFoundMarker: @"not found"];
	
	STAssertTrue([a1 isEqualToArray: a2], @"Expected equal arrays");
}


- (void) testValueForKey {
	// check the valueForKey results for an arbitrary key in the cocoa and sorted dictionaries
	STAssertEqualObjects(@"3", [srd valueForKey: @"123"], @"Expected 3");
	STAssertEqualObjects(@"3", [nsd valueForKey: @"123"], @"Expected 3");

	// check the valueForKey results for an @-prefixed key in both dictionaries
	STAssertEqualObjects([NSNumber numberWithInt: 1000], [srd valueForKey: @"@count"], @"Expected 1000");
	STAssertEqualObjects([NSNumber numberWithInt: 1000], [nsd valueForKey: @"@count"], @"Expected 1000");
}


- (void) testFirstEntry {
	// check that firstEntry returns the lowest key entry
	NSObject<SortedDictionaryEntry> *first = [srd firstEntry];
	
	STAssertEqualObjects([first key], @"0", @"Expected 0");
	STAssertEqualObjects([first value], @"0", @"Expected 0");
}


- (void) testFirstEntries {
	// get the 5 lowest key entries in the sorted dictionary
	NSArray *entries = [srd firstEntries: 5];
	
	// check that exactly 5 entries were returned
	STAssertEquals(5U, [entries count], @"Expected 5 elements");
	
	// check that the lowest key entries were returned, and in the correct order
	STAssertEqualObjects([[entries objectAtIndex: 0] key], @"0", @"Expected 0");
	STAssertEqualObjects([[entries objectAtIndex: 1] key], @"1", @"Expected 1");
	STAssertEqualObjects([[entries objectAtIndex: 2] key], @"10", @"Expected 10");
	STAssertEqualObjects([[entries objectAtIndex: 3] key], @"100", @"Expected 100");
	STAssertEqualObjects([[entries objectAtIndex: 4] key], @"101", @"Expected 101");
}


- (void) testFirstEntriesDoesntDieWhenAskingForMoreThanDictHas {
	NSArray *entries;
	STAssertNoThrow(entries = [srd firstEntries: 2000], @"Crashed -- should have handled gracefully");
	STAssertEquals(1000U, [entries count], @"Expected exactly as many entries as in dict");
}


- (void) testLastEntry {
	// check that lastEntry returns the highest key entry
	NSObject<SortedDictionaryEntry> *last = [srd lastEntry];
	
	STAssertEqualObjects([last key], @"999", @"Expected 999");
	STAssertEqualObjects([last value], @"9", @"Expected 9");
}


- (void) testLastEntries {
	// get the 5 highest key entries in the sorted dictionary
	NSArray *entries = [srd lastEntries: 5];
	
	// check that exactly 5 were returned
	STAssertEquals(5U, [entries count], @"Expected 5 elements");
	
	// check that the highest key entries were returned, and in the correct order
	STAssertEqualObjects([[entries objectAtIndex: 0] key], @"995", @"Expected 995");
	STAssertEqualObjects([[entries objectAtIndex: 1] key], @"996", @"Expected 996");
	STAssertEqualObjects([[entries objectAtIndex: 2] key], @"997", @"Expected 997");
	STAssertEqualObjects([[entries objectAtIndex: 3] key], @"998", @"Expected 998");
	STAssertEqualObjects([[entries objectAtIndex: 4] key], @"999", @"Expected 999");
}


- (void) testLastEntriesDoesntDieWhenAskingForMoreThanDictHas {
	NSArray *entries;
	STAssertNoThrow(entries = [srd lastEntries: 2000], @"Crashed -- should have handled gracefully");
	STAssertEquals(1000U, [entries count], @"Expected exactly as many entries as in dict");
}


- (void) testEntryEnumerator {
	// create a key enumerator and iterate through it
	int i		= 0;
	id	prevKey	= nil;
	for (NSObject<SortedDictionaryEntry> *entry in [srd entryEnumerator]) {
		// count the iteration
		++i;
		
		// check that the entries valid by comparing with the reference NSDictionary
		STAssertNotNil(entry, @"Expected a non-nil entry");
		STAssertNotNil([entry key], @"Expected a non-nil key");
		STAssertNotNil([entry value], @"Expected a non-nil value");
		STAssertEqualObjects(
			[entry value], [nsd valueForKey: [entry key]],
			@"Value mismatch for key %@. Expected %@ found %@",
			[entry key], [nsd valueForKey: [entry key]], [entry value]);
		
		// check that entries are delivered in increasing ey order
		if (prevKey) {
			STAssertTrue(
				[prevKey isLessThan: [entry key]],
				@"Expected keys in increasing order, but found %@ followed by %@",
				prevKey, [entry key]);
		}
		prevKey = [entry key];
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, i, @"Expected 1000 entries, found %d", i);
}


- (void) testKeyEnumerator {
	// create a key enumerator and iterate through it
	int i		= 0;
	id	prevKey	= nil;
	for (id key in [srd keyEnumerator]) {
		// count the iteration
		++i;
		
		// check that the key is valid by comparing with the reference NSDictionary
		STAssertNotNil(key, @"Expected a non-nil key");
		STAssertNotNil([nsd valueForKey: key], @"Unexpected key %@ returned", key);
		
		// check that keys are delivered in increasing order
		if (prevKey) {
			STAssertTrue(
				[prevKey isLessThan: key],
				@"Expected keys in increasing order, but found %@ followed by %@", prevKey, key);
		}
		prevKey = key;
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, i, @"Expected 1000 keys, found %d", i);
	
	// sanity check that missing keys return nil values
	STAssertNil([nsd valueForKey: @"invalid key"], @"Expected nil for an invalid key");
}


- (void) testObjectEnumerator {
	// prepare an array of all values in the reference NSDictionary, sorted by keys
	NSArray			*sortedKeys	= [[nsd allKeys] sortedArrayUsingSelector: @selector(isGreaterThan:)];
	NSMutableArray	*values		= [NSMutableArray arrayWithCapacity: 1000];
	for (int i = 0; i < 1000; ++i) {
		NSString *key = [sortedKeys objectAtIndex: i];
		NSString *value = [key substringFromIndex: [key length] - 1];
		[values	addObject: value];
	}
	
	// iterate using the object enumerator, check that values match expectations
	int index = 0;
	for (id value in [srd objectEnumerator]) {
		id expectedValue = [values objectAtIndex: index++];
		STAssertEqualObjects(value, expectedValue, @"Expected equal objects at index %d", index);
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, index, @"Expected 1000 iterations");
}


- (void) testReverseEntryEnumerator {
	// create a key enumerator and iterate through it
	int i		= 0;
	id	prevKey	= nil;
	for (NSObject<SortedDictionaryEntry> *entry in [srd reverseEntryEnumerator]) {
		// count the iteration
		++i;
		
		// check that the entries valid by comparing with the reference NSDictionary
		STAssertNotNil(entry, @"Expected a non-nil entry");
		STAssertNotNil([entry key], @"Expected a non-nil key");
		STAssertNotNil([entry value], @"Expected a non-nil value");
		STAssertEqualObjects(
			[entry value], [nsd valueForKey: [entry key]],
			@"Value mismatch for key %@. Expected %@ found %@",
			[entry key], [nsd valueForKey: [entry key]], [entry value]);
		
		// check that entries are delivered in decreasing key order
		if (prevKey) {
			STAssertTrue(
				[[entry key] isLessThan: prevKey],
				@"Expected keys in decreasing order, but found %@ followed by %@",
				prevKey, [entry key]);
		}
		prevKey = [entry key];
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, i, @"Expected 1000 entries, found %d", i);
}


- (void) testReverseKeyEnumerator {
	// create a key enumerator and iterate through it
	int i		= 0;
	id	prevKey	= nil;
	for (id key in [srd reverseKeyEnumerator]) {
		// count the iteration
		++i;
		
		// check that the key is valid by comparing with the reference NSDictionary
		STAssertNotNil(key, @"Expected a non-nil key");
		STAssertNotNil([nsd valueForKey: key], @"Unexpected key %@ returned", key);
		
		// check that keys are delivered in decreasing order
		if (prevKey) {
			STAssertTrue(
				[key isLessThan: prevKey],
				@"Expected keys in decreasing order, but found %@ followed by %@", prevKey, key);
		}
		prevKey = key;
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, i, @"Expected 1000 keys, found %d", i);
}


- (void) testReverseObjectEnumerator {
	// prepare an array of all values in the reference NSDictionary, sorted by keys
	NSArray			*sortedKeys	= [[nsd allKeys] sortedArrayUsingSelector: @selector(isGreaterThan:)];
	NSMutableArray	*values		= [NSMutableArray arrayWithCapacity: 1000];
	for (int i = 0; i < 1000; ++i) {
		NSString *key = [sortedKeys objectAtIndex: i];
		NSString *value = [key substringFromIndex: [key length] - 1];
		[values	addObject: value];
	}
	
	// iterate using the reverse enumerator, check that values match expectations
	int index = 1000;
	int iterations = 0;
	for (id value in [srd reverseObjectEnumerator]) {
		id expectedValue = [values objectAtIndex: --index];
		STAssertEqualObjects(value, expectedValue, @"Expected equal objects at index %d", index + 1);
		++iterations;
	}
	
	// check that the number of iterations was as expected
	STAssertEquals(1000, iterations, @"Expected 1000 iterations");
}


@end
