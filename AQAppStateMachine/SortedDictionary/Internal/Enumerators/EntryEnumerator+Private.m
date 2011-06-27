#import "EntryEnumerator+Private.h"
#import "Node.h"

@implementation EntryEnumerator (Private)


- (id) initGoingForwardFromNode: (Node *) aNode {
	if (self = [super init]) {
		node	= aNode;
		first	= @selector(left);
		second	= @selector(right);
	}
	return self;
}


- (id) initGoingBackFromNode: (Node *) aNode {
	if (self = [super init]) {
		node	= aNode;
		first	= @selector(right);
		second	= @selector(left);
	}
	return self;
}

@end
