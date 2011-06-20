#import "MutableSortedDictionaryContentTests.h"
#import "MutableSortedDictionary.h"
#import "SortedDictionary+Test.h"


@implementation MutableSortedDictionaryContentTests


- (void) checkDict: (id) d {
	// check for the expected number of entries in the dictionary
	STAssertEquals(1000U, [d count], @"Expected 1000 entries, found %d", [d count]);
	
	// get all keys and values, ensure we get the correct number of each
	NSArray *keys = [d allKeys];
	NSArray *values = [d allValues];
	STAssertEquals(1000U, [keys count], @"Expected 1000 keys, found %d", [keys count]);
	STAssertEquals(1000U, [values count], @"Expected 1000 values, found %d", [values count]);
	
	// check that keys are in ascending order
	NSString *prevKey = [keys objectAtIndex: 0];
	for (int i = 1; i < 1000; ++i) {
		NSString *key = [keys objectAtIndex: i];
		STAssertTrue([prevKey compare: key] == NSOrderedAscending, @"Expected keys in ascending order, but found %@ before %@", prevKey, key);
		
		prevKey = key;
	}
	
	// check that the values match the keys
	for (int i = 0; i < 1000; ++i) {
		NSString *key			= [keys objectAtIndex: i];
		NSString *expectedValue	= [key substringFromIndex: [key length] - 1];
		
		STAssertEqualObjects(
			expectedValue,
			[values objectAtIndex: i],
			@"Value %@ for key %@ does not match the expected %@",
			[values objectAtIndex: i], key, expectedValue);
	}
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
}


- (void) testSetObjectForKey {
	// create a test dictionary, fill it with values
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	for (int i = 0; i < 200; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 7];
		[d setObject: value forKey: key];
	}
	
	// overwrite some of the values with different values
	for (int i = 100; i < 200; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 9];
		[d setObject: value forKey: key];
	}

	// overwrite all with the final values
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testSetValueForKey {
	// create a both a cocoa and a sorted dictionaries
	MutableSortedDictionary	*d1 = [MutableSortedDictionary dictionary];
	NSMutableDictionary		*d2 = [NSMutableDictionary dictionary];
	
	// add test values to the dictionaries
	[d1 setValue: @"test value" forKey: @"testKey"];
	[d2 setValue: @"test value" forKey: @"testKey"];
	
	// compare the valueForKey and objectForKey results for both dictionaries
	STAssertEqualObjects(@"test value", [d1 valueForKey: @"testKey"], @"expected test value");
	STAssertEqualObjects(@"test value", [d1 objectForKey: @"testKey"], @"expected test value");
	STAssertEqualObjects(@"test value", [d2 valueForKey: @"testKey"], @"expected test value");
	STAssertEqualObjects(@"test value", [d2 objectForKey: @"testKey"], @"expected test value");
}


- (void) testAddEntriesFromDictionary {
	// create a test dictionary, fill it with some values
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	for (int i = 0; i < 200; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 7];
		[d setObject: value forKey: key];
	}
	
	// create a secondary dictionary, fill it with the test values
	NSMutableDictionary *d2 = [[NSMutableDictionary alloc] init];	
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d2 setObject: value forKey: key];
	}
	
	// overwrite test dictionary with secondary dictionary values
	[d addEntriesFromDictionary: d2 copyItems: YES];
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testAddEntriesFromSortedDictionary {
	// create a test dictionary, fill it with some values
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	for (int i = 0; i < 200; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 7];
		[d setObject: value forKey: key];
	}
	
	// create a secondary dictionary, fill it with the test values
	MutableSortedDictionary *d2 = [[MutableSortedDictionary alloc] init];	
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d2 setObject: value forKey: key];
	}
	
	// overwrite test dictionary with secondary dictionary values
	[d addEntriesFromSortedDictionary: d2 copyItems: YES];
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testSetDictionary {
	// create test dictionary, fill it with some values that will not be overwritten
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	for (int i = 1001; i < 1100; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// create secondary dictionary, fill it with the test values
	NSMutableDictionary *d2 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d2 setObject: value forKey: key];
	}
	
	// set the test dictionary from the secondary dictionary
	[d setDictionary: d2];
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testSetSortedDictionary {
	// create test dictionary, fill it with some values that will not be overwritten
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	for (int i = 1001; i < 1100; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// create secondary dictionary, fill it with the test values
	MutableSortedDictionary *d2 = [[MutableSortedDictionary alloc] init];
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d2 setObject: value forKey: key];
	}
	
	// set the test dictionary from the secondary dictionary
	[d setSortedDictionary: d2];
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testRemoveAllObjects {
	// create a test dictionary, fill it with values
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];	
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// now remove all objects
	[d removeAllObjects];
	
	// check for the expected number of entries in the dictionary
	STAssertEquals(0U, [d count], @"Expected 0 entries, found %d", [d count]);
	
	// get all keys and values, ensure we get the correct number of each
	NSArray *keys = [d allKeys];
	NSArray *values = [d allValues];
	STAssertEquals(0U, [keys count], @"Expected 0 keys, found %d", [keys count]);
	STAssertEquals(0U, [values count], @"Expected 0 values, found %d", [values count]);

	// now add some values again, to check that we didn't break anything
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// check that the dictionary content meets expectations
	[self checkDict: d];
}


- (void) testRemoveObjectForKeySmallRemoveTest {
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];
	
	for (int i = 0; i < 200; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	for (int i = 0; i < 21; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		[d removeObjectForKey: key];
	}

	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
}


- (void) testRemoveObjectForKey {
	// create a test dictionary, fill it with values to remove
	MutableSortedDictionary *d = [[MutableSortedDictionary alloc] init];	
	for (int i = 1001; i < 1100; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// now add values to retain
	for (int i = 0; i < 1000; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// add more values to remove
	for (int i = 999000; i < 999999; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		NSString *value = [NSString stringWithFormat: @"%d", i % 10];
		[d setObject: value forKey: key];
	}
	
	// remove values
	for (int i = 1001; i < 1100; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		[d removeObjectForKey: key];
	}
	for (int i = 999000; i < 999999; ++i) {
		NSString *key	= [NSString stringWithFormat: @"%d", i];
		[d removeObjectForKey: key];
	}

	// check that the dictionary content meets expectations
	[self checkDict: d];
}


@end
