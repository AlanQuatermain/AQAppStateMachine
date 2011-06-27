#import "KeyEnumerator.h"
#import "EntryEnumerator.h"


@implementation KeyEnumerator


- (id) initWithEnumerator: (NSEnumerator *) anEnumerator {
	if (self = [super init]) {
#if USING_ARC
		entryEnum = (EntryEnumerator *) anEnumerator;
#else
		entryEnum = (EntryEnumerator *) [anEnumerator retain];
#endif
	}
	return self;
}


- (NSArray *) allObjects {
	NSMutableArray *objects = [NSMutableArray array];//[[[NSMutableArray alloc] init] autorelease];
	
	id object = nil;
	while (object = [self nextObject]) {
		[objects addObject: object];
	}
	
	return objects;
}


- (id) nextObject {
	return [[entryEnum nextObject] key];
}

#if !USING_ARC
- (void) dealloc {
	[entryEnum release];
	[super dealloc];
}
#endif

@end
