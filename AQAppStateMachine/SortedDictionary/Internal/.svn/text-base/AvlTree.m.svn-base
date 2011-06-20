#import "AvlTree.h"
#import "AvlTree+Private.h"
#import "common.h"
#import "Node.h"
#import "EntryEnumerator.h"
#import "EntryEnumerator+Private.h"
#import "KeyEnumerator.h"
#import "ObjectEnumerator.h"


#define DIR(side)	(((side) == odLeft) ? -1 : 1)


@implementation AvlTree


@synthesize root, count;


// initializer
- (id) init {
	if (self = [super init]) {
		root	= nil;
		count	= 0;
	}
	return self;
}


// destructor
- (void) dealloc {
	[root release];
	[super dealloc];
}


// private methods

// finds a node with the specified key in the tree, or a node with a nearby key that a new node
// with the specified key could be added to.
- (Node *) findNodeWithKey: (id) aKey orNearest: (BOOL) findNearest {
	Node *node, *child;
	
	for (node = root; node && ![aKey isEqual: [node key]]; node = child) {
		if (!(child = [node childAtSide: [aKey isLessThan: [node key]] ? odLeft : odRight])) {
			return findNearest ? node : nil;
		}
	}
	
	return node;
}


- (Node *) lastNodeFrom: (Node *) first usingSelector: (SEL) next {
	Node *node = first, *nextNode;
	while (nextNode = [node performSelector: next]) { node = nextNode; } 
	return node;
}


- (Node *) leftmostDescendantOf:	(Node *) node	{ return [self lastNodeFrom: node usingSelector: @selector(left)]; }
- (Node *) rightmostDescendantOf:	(Node *) node	{ return [self lastNodeFrom: node usingSelector: @selector(right)]; }
- (Node *) nearestLowerDescendantOf:	(Node *) node { return [self rightmostDescendantOf: [node left]] ; }
- (Node *) nearestHigherDescendantOf:	(Node *) node { return [self leftmostDescendantOf:  [node right]]; }


- (Node *) nearDescendantOf: (Node *) node {
	return [node left] ?
		[self nearestLowerDescendantOf: node] :
		[self nearestHigherDescendantOf: node];
}


// rolls the node once to the specified side. returns the node that was rolled into place instead
// of the original node.
- (Node *) rollNode: (Node *) node onceToSide: (ODSide) aSide {
	ODSide	otherSide	= 1 - aSide;
	int		dir			= DIR(aSide);
	Node	*parent		= [node parent];
	
	NSAssert([node childAtSide: otherSide], @"Did not find a node to roll");
	
	// newTop will come up on top after the roll
	Node *newTop		= [node childAtSide: otherSide];
	
	if (parent)	{ [parent setChild: newTop atSide: [parent sideOfChild: node]]; }
	else		{ root = newTop; [newTop setParent: nil]; }
	
	[node setChild: [newTop childAtSide: aSide] atSide: otherSide];
	[newTop setChild: node atSide: aSide];
	
	// update the node balances
	node.balance	+= dir * (1 + max(0, -dir * newTop.balance));
	newTop.balance	+= dir * (1 + max(0, dir * node.balance));
	
	return newTop;
}


// rolls the node to the specified side. also rolls the rolled child if needed to minimize the
// height of the tree.
- (Node *) rollNode: (Node *) node toSide: (ODSide) aSide {
	ODSide otherSide	= 1 - aSide;
	Node *newTop		= [node childAtSide: otherSide];

	// if needed, roll the rolled child node to minimize the height of the tree
	if (DIR(aSide) * [newTop balance] > 0) {
		[self rollNode: newTop onceToSide: otherSide];
	}
	
	// roll the specified node and return the node that was rolled in to replace it
	return [self rollNode: node onceToSide: aSide];
}


// recursively updates the ancestor chain of the specified node to a change in the height of one
// of its children. O(log n)
- (void) updateNode: (Node *) node toHeightChange: (int) heightChange atSide: (ODSide) aSide {
	int		dir					= DIR(aSide);
	Node	*rolledNode			= node;
	Node	*originalParent		= [node parent];
	int		parentHeightChange	= 0;
	
	// update the node's balance. the tree underneath the node should now be correctly balanced.
	node.balance	+= dir * heightChange;
	int balance		= node.balance;

	// if the node is out of balance, roll it
	if (abs(balance) > 1) {
		ODSide rollSide		= (balance > 0) ? odLeft : odRight;
		rolledNode			= [self rollNode: node toSide: rollSide];
		parentHeightChange	= DIR(rollSide) * [[rolledNode childAtSide: rollSide] balance] >= 0 ?
								min(heightChange, 0) :
								0;
	}
	// figure out if the node's height has changed
	else if ((dir * balance >  0) && (heightChange > 0)) { parentHeightChange =  1; }
	else if ((dir * balance >= 0) && (heightChange < 0)) { parentHeightChange = -1; }
	
	// if the node's height has changed, recursively update the node's parent
	if (originalParent && (parentHeightChange != 0)) {
		[self updateNode: originalParent
		  toHeightChange: parentHeightChange
				  atSide: [originalParent sideOfChild: rolledNode]];
	}
}


// public methods

- (BOOL) containsKey: (id) aKey { return [self findNodeWithKey: aKey orNearest: NO] != nil; }
- (id) objectForKey: (id) aKey { return [[self findNodeWithKey: aKey orNearest: NO] value]; }

// enumerators
- (NSEnumerator *) entryEnumerator			{ return [[[EntryEnumerator alloc] initGoingForwardFromNode: [self leftmostDescendantOf: root]] autorelease]; }
- (NSEnumerator *) reverseEntryEnumerator	{ return [[[EntryEnumerator alloc] initGoingBackFromNode:	 [self rightmostDescendantOf: root]] autorelease]; }


- (void) setObject: (id) anObject forKey: (id) aKey {
	// tree empty? -- create first node and return -- O(1)
	if (!root) {
		NSAssert(count == 0, @"Expected a zero count when there is no root node");
		root = [[Node alloc] initWithKey: aKey value: anObject andParent: nil];
		count = 1;
		return;
	}
	
	// node with key already in tree? -- update its value and return -- O(log n)
	Node *node = [self findNodeWithKey: aKey orNearest: YES];
	if ([aKey isEqual: [node key]]) {
		[node setValue: anObject];
		return;
	}
	
	// create a new node and add it as a child of the nearest node
	ODSide side		= [aKey isLessThan: [node key]] ? odLeft : odRight;
	Node *newNode	= [[Node alloc] initWithKey: aKey value: anObject andParent: node];
	
	[node setChild: newNode atSide: side];
	node.balance += DIR(side);
	
	// update the chain of ancestors about the height change
	Node *parent = [node parent];
	if (parent && ![node childAtSide: 1 - side]) {
		[self updateNode: parent toHeightChange: 1 atSide: [parent sideOfChild: node]];
	}
	
	// update the cached entry count
	++count;
}


- (void) removeAllObjects {
	[root release];
	root	= nil;
	count	= 0;
}


- (void) removeObjectForKey: (id) aKey {
	if (!root) { return; }

	// find the node to remove; exit if not found -- O(log n)
	Node *nodeToRemove = [self findNodeWithKey: aKey orNearest: NO];
	if (!nodeToRemove) { return; }
	
	// replace the key/value content of the node with that of its nearest descendant -- O(1)
	Node *nearestDescendant = [self nearDescendantOf: nodeToRemove];
	if (nearestDescendant) {
		[nodeToRemove copyContentFromNode: nearestDescendant];
		nodeToRemove = nearestDescendant;
	}
	
	// find the node's one child -- O(1)
	Node *replacement = [nodeToRemove liveChild];
	
	// remove the node from the tree -- O(log n)
	if (![nodeToRemove parent]) {
		root = replacement;
	}
	else {
		// remove the node -- O(1)
		Node *parent		= [nodeToRemove parent];
		ODSide sideAtParent	= [parent sideOfChild: nodeToRemove];
		[parent setChild: replacement atSide: sideAtParent];
		
		// update the chain of anscesors about the change in height -- O(log n)
		[self updateNode: parent toHeightChange: -1 atSide: sideAtParent];
	}
	
	// release the node -- O(1)
	[nodeToRemove setChild: nil atSide: odLeft];
	[nodeToRemove setChild: nil atSide: odRight];
	[nodeToRemove release];	
	
	// update the cached entry count
	--count;
}


- (NSString *) description {
	return [NSString stringWithFormat: @"{%@ count=%d\n  root=%@\n}",
		[super description],
		count,
		[root descriptionWithChildrenAndIndent: 1]];
}


// NSCoding protocol implementation

- (void) encodeWithCoder: (NSCoder *) encoder {
	[encoder encodeObject:	root	forKey: @"Root"];
	[encoder encodeInteger:	count	forKey: @"Count"];
}


- (id) initWithCoder: (NSCoder *) decoder {
	if (self = [super init]) {
		root	= [[decoder decodeObjectForKey:	@"Root"] retain];
		count	= [decoder decodeIntegerForKey:	@"Count"];
	}
	return self;
}


// NSCopying protocol implementation

- (id) copyWithZone: (NSZone *) zone {
	return [[AvlTree alloc] initWithNode: [[root copyWithZone: zone] autorelease] andCount: count];
}


@end
