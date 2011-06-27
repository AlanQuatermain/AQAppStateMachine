#import "AvlTree+Private.h"


@implementation AvlTree (Private)


- (id) initWithNode: (Node *) newRoot andCount: (NSUInteger) newCount {
	if (self = [super init]) {
#if USING_ARC
		root	= newRoot;
#else
		root	= [newRoot retain];
#endif
		count	= newCount;
	}
	return self;
}


@end
