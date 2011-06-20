#import "ObjectEnumerator.h"
#import "EntryEnumerator.h"


@implementation ObjectEnumerator


- (id) initWithEnumerator: (NSEnumerator *) anEnumerator {
	if (self = [super init]) {
		entryEnum = (EntryEnumerator *) anEnumerator;//[anEnumerator retain];
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
	return [[entryEnum nextObject] value];
}

/*
- (void) dealloc {
	[entryEnum release];
	[super dealloc];
}
*/

@end
