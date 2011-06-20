#import "Node.h"
#import "common.h"
#import "NSString+Indent.h"


@implementation Node


@synthesize key, value, balance, parent;


// initializer
- (id) initWithKey: (id) aKey value: (id) aValue andParent: (Node *) aParent {
	if (self = [super init]) {
		self.key			= aKey;
		self.value			= aValue;
		balance				= 0;
		parent				= aParent;
		children[odLeft]	= nil;
		children[odRight]	= nil;
	}
	return self;
}

/*
// destructor
- (void) dealloc {
	[children[odRight] release];
	[children[odLeft] release];
	[value release];
	[key release];
	[super dealloc];
}
*/

// explicit property accessors

- (Node *) left { return children[odLeft]; }
- (void) setLeft: (Node *) aNode { [self setChild: aNode atSide: odLeft]; }

- (Node *) right { return children[odRight]; }
- (void) setRight: (Node *) aNode { [self setChild: aNode atSide: odRight]; }


// public methods

- (void) copyContentFromNode: (Node *) aNode { [self setKey: [aNode key]]; [self setValue: [aNode value]]; }

- (Node *) childAtSide: (ODSide) aSide { return children[aSide]; }
- (void) setChild: (Node *) aNode atSide: (ODSide) aSide {
	children[aSide] = aNode;
	[aNode setParent: self];
}

- (Node *) liveChild { return children[odLeft] ? children[odLeft] : children[odRight]; }
- (ODSide) sideOfChild: (Node *) aNode { return (children[odLeft] == aNode) ? odLeft : odRight; }


- (int) height { return 1 + max([children[odLeft] height], [children[odRight] height]); }
- (int) count { return 1 + [children[odLeft] count] + [children[odRight] count]; }


- (NSString *) description {
	int expectedBalance = [[self right] height] - [[self left] height];
	return [NSString stringWithFormat: @"<%@>=<%@> H=%d B=%d/%d CNT=%d%@",
		[key description], [value description],
		[self height], balance, expectedBalance, [self count],
			(balance == expectedBalance) ? @"" : @" *** BUG: balance mismatch"];
}


- (NSString *) descriptionWithChildrenAndIndent: (NSInteger) indent {
	NSString		*indentString	= @"  ";
	NSMutableString	*description	= [NSMutableString stringWithFormat: @"%@", [self description]];
	
	if (children[odLeft]) { [description appendFormat: @"\n%@left:  %@",
		[NSString stringWith: indent + 1 copiesOfString: indentString],
		[children[odLeft] descriptionWithChildrenAndIndent: indent + 1]]; }
	
	if (children[odRight]) { [description appendFormat: @"\n%@right: %@",
		[NSString stringWith: indent + 1 copiesOfString: indentString],
		[children[odRight] descriptionWithChildrenAndIndent: indent + 1]]; }
	
	return description;
}


// NSCoding protocol implementation

- (void) encodeWithCoder: (NSCoder *) encoder {
	[encoder encodeObject:	key					forKey: @"Key"];
	[encoder encodeObject:	value				forKey: @"Value"];
	[encoder encodeInteger:	balance				forKey: @"Balance"];
	[encoder encodeObject:	children[odLeft]	forKey: @"Left"];
	[encoder encodeObject:	children[odRight]	forKey: @"Right"];
}


- (id) initWithCoder: (NSCoder *) decoder {
	if (self = [super init]) {
		self.key	= [decoder decodeObjectForKey:	@"Key"];
		self.value	= [decoder decodeObjectForKey:	@"Value"];
		balance		= [decoder decodeIntegerForKey:	@"Balance"];
		parent		= nil;
		self.left	= [decoder decodeObjectForKey:	@"Left"];
		self.right	= [decoder decodeObjectForKey:	@"Right"];
	}
	return self;
}


// NSCopying protocol implementation

- (id) copyWithZone: (NSZone *) zone {
	Node *copy = [[Node alloc] initWithKey: key value: value andParent: parent];
	copy.balance	= balance;
	copy.left		= children[odLeft];
	copy.right		= children[odRight];
	
	return copy;
}


@end
