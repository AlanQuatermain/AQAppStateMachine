#import "EntryEnumerator.h"
#import "Node.h"


@implementation EntryEnumerator


- (NSArray *) allObjects {
	NSMutableArray *objects = [NSMutableArray array];//[[[NSMutableArray alloc] init] autorelease];
	
	id object;
	while (object = [self nextObject]) {
		[objects addObject: object];
	}
	
	return objects;
}


- (id) nextObject {
	// always return the node the enumerator is currently pointing at
	if (!node) return nil;
	Node *nodeToReturn = node;
	
	// now move the enumerator's node to the following node...
	
	// ...look for the next larger descendant, if there is one... (or smaller, if going back)
	Node *nextNode = [node performSelector: second];
	if (nextNode) {
		node = nextNode;
		while ((nextNode = [node performSelector: first])) { node = nextNode; }
	}
	
	// ...or scan for the next unenumerated parent otherwise.
	else {
		Node *prevNode = node;
		node = [node parent];
		while (node && (prevNode == [node performSelector: second])) {
			prevNode = node;
			node = [node parent];
		}
	}
	
	return nodeToReturn;
}


@end
