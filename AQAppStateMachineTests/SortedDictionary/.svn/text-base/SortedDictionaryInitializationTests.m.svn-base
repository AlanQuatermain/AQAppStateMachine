#import "SortedDictionaryInitializationTests.h"
#import "SortedDictionary+Test.h"


static NSString *cities[] = { @"New York", @"Los Angeles", @"Chicago", @"Houston", @"Philadelphia", @"Phoenix", @"San Antonio", @"San Diego", @"Dallas", @"San Jose" };
static NSString *states[] = { @"New York", @"California", @"Illinois", @"Texas", @"Pennsylvania", @"Arizona", @"Texas", @"California", @"Texas", @"California" };


@implementation SortedDictionaryInitializationTests


- (void) testInit {
	SortedDictionary *d = [[SortedDictionary alloc] autorelease];
	
	// initialize SortedDictionary, check count and class
	STAssertNoThrow	(d = [d init],									@"Failed to initialize dictionary");
	STAssertEquals	(0U, [d count],									@"Was expecting zero items when initializing a dictionary");
	STAssertTrue	([d isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
}


- (void) testInitWithDictionary {
	// create a secondary dictionary to initialize with
	NSDictionary *d1 = [NSDictionary dictionaryWithObjects: states forKeys: cities count: 10];
	STAssertEquals(10U, [d1 count], @"10 items were expected");
	
	// initialize a SortedDictionary, check count and class
	SortedDictionary *d2 = [[SortedDictionary alloc] autorelease];
	STAssertNoThrow(d2 = [d2 initWithDictionary: d1],				@"Failed to initialize dictionary");
	STAssertEquals(10U, [d2 count],									@"10 items were expected");
	STAssertTrue([d2 isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d2 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// check content
	for (int i = 0; i < 10; ++i) {
		STAssertEquals(states[i], [d2 objectForKey: cities[i]],		@"Expected %@ for key %@", states[i], cities[i]);
	}
}


- (void) testInitWithSortedDictionary {
	// create a secondary dictionary to initialize with
	SortedDictionary *d1 = [SortedDictionary dictionaryWithObjects: states forKeys: cities count: 10];
	STAssertEquals(10U, [d1 count], @"10 items were expected");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d1 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// initialize a SortedDictionary, check count and class
	SortedDictionary *d2 = [[SortedDictionary alloc] autorelease];
	STAssertNoThrow(d2 = [d2 initWithSortedDictionary: d1],			@"Failed to initialize dictionary");
	STAssertEquals(10U, [d2 count],									@"10 items were expected");
	STAssertTrue([d2 isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d2 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// check content
	for (int i = 0; i < 10; ++i) {
		STAssertEquals(states[i], [d2 objectForKey: cities[i]],		@"Expected %@ for key %@", states[i], cities[i]);
	}
}


- (void) testInitWithDictionaryCopyItems {
	// create a secondary dictionary to initialize with
	NSMutableString	*newYork	= [NSMutableString stringWithString: @"New York"];
	NSMutableString *california	= [NSMutableString stringWithString: @"California"];
	NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys: newYork, @"New York", california, @"San Diego", nil];
	STAssertEquals(2U, [d1 count], @"2 items were expected");
	
	// initialize a SortedDictionary, check count and class
	SortedDictionary *d2 = [[SortedDictionary alloc] autorelease];
	STAssertNoThrow(d2 = [d2 initWithDictionary: d1 copyItems: YES],		@"Failed to initialize dictionary");
	STAssertEquals(2U, [d2 count],											@"2 items were expected");
	STAssertTrue([d2 isMemberOfClass: [SortedDictionary class]],			@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d2 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// check content
	STAssertEqualObjects(@"New York", [d2 objectForKey: @"New York"],		@"Expected New York");
	STAssertEqualObjects(@"California", [d2 objectForKey: @"San Diego"],	@"Expected San Diego");
	
	// check for copies
	STAssertFalse(newYork == [d2 objectForKey: @"New York"],				@"Expected different objects");
	STAssertFalse(california == [d2 objectForKey: @"San Diego"],			@"Expected different objects");
}


- (void) testInitWithSortedDictionaryCopyItems {
	// create a secondary dictionary to initialize with
	NSMutableString	*newYork	= [NSMutableString stringWithString: @"New York"];
	NSMutableString *california	= [NSMutableString stringWithString: @"California"];
	SortedDictionary *d1 = [SortedDictionary dictionaryWithObjectsAndKeys: newYork, @"New York", california, @"San Diego", nil];
	STAssertEquals(2U, [d1 count], @"2 items were expected");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d1 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// initialize a SortedDictionary, check count and class
	SortedDictionary *d2 = [[SortedDictionary alloc] autorelease];
	STAssertNoThrow(d2 = [d2 initWithSortedDictionary: d1 copyItems: YES],	@"Failed to initialize dictionary");
	STAssertEquals(2U, [d2 count],											@"2 items were expected");
	STAssertTrue([d2 isMemberOfClass: [SortedDictionary class]],			@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d2 balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// check content
	STAssertEqualObjects(@"New York", [d2 objectForKey: @"New York"],		@"Expected New York");
	STAssertEqualObjects(@"California", [d2 objectForKey: @"San Diego"],	@"Expected San Diego");
	
	// check for copies
	STAssertFalse(newYork == [d2 objectForKey: @"New York"],				@"Expected different objects");
	STAssertFalse(california == [d2 objectForKey: @"San Diego"],			@"Expected different objects");
}


- (void) testInitWithObjectsForKeys {
	SortedDictionary *d = [[SortedDictionary alloc] autorelease];
	
	// initialize a SortedDictionary, check count, content and class
	STAssertNoThrow	(
					 (d = [d initWithObjects: [NSArray arrayWithObjects: @"New York", @"Broadway", nil]
									 forKeys: [NSArray arrayWithObjects: @"City", @"Street", nil]]),
																	@"Failed to create dictionary");
	STAssertEquals	(2U, [d count],									@"2 items were expected");
	STAssertEquals	(@"New York", [d objectForKey: @"City"],		@"Was expecting \"New York\"");
	STAssertEquals	(@"Broadway", [d objectForKey: @"Street"],		@"Was expecting \"Broadway\"");
	STAssertTrue	([d isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
}


- (void) testInitWithObjectsForKeysCount {
	SortedDictionary *d = [[SortedDictionary alloc] autorelease];
	
	// initialize a SortedDictionary, check count and class
	STAssertNoThrow	(
					 (d = [d initWithObjects: states forKeys: cities count: 10]),
																	@"Failed to create dictionary");
	STAssertEquals	(10U, [d count],								@"10 items were expected");
	STAssertTrue	([d isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
	
	// check content
	for (int i = 0; i < 10; ++i) {
		STAssertEquals(states[i], [d objectForKey: cities[i]],			@"Expected %@ for key %@", states[i], cities[i]);
	}
}


- (void) testInitWithObjectsAndKeys {
	SortedDictionary *d = [[SortedDictionary alloc] autorelease];
	
	// initialize a SortedDictionary, check count, content and class
	STAssertNoThrow	((d = [d initWithObjectsAndKeys: @"New York", @"New York", @"California", @"San Jose", nil]),
																	@"Failed to create dictionary");
	STAssertEquals	(2U, [d count],									@"2 items were expected");
	STAssertEquals	(@"New York", [d objectForKey: @"New York"],	@"Was expecting \"New York\"");
	STAssertEquals	(@"California", [d objectForKey: @"San Jose"],	@"Was expecting \"California\"");
	STAssertTrue	([d isMemberOfClass: [SortedDictionary class]],	@"Was expecting a SortedDictionary");
	
	// check that the binary tree the dictionary uses is correctly balanced
	STAssertTrue([d balancesAreCorrect], @"The dictionary is not balanced correctly");
}


@end
