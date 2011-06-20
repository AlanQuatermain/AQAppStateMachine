#import "AvlTree+Private.h"


@implementation AvlTree (Private)


- (id) initWithNode: (Node *) newRoot andCount: (NSUInteger) newCount {
	if (self = [super init]) {
		root	= newRoot;//[newRoot retain];
		count	= newCount;
	}
	return self;
}


@end
