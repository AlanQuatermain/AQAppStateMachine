#import <Foundation/Foundation.h>
#import "SortedDictionaryEntry.h"


typedef enum { odLeft = 0, odRight = 1 } ODSide;


@interface Node : NSObject <NSCoding, NSCopying, SortedDictionaryEntry> {
		id		key;
		id		value;
		int		balance;
		Node	*parent __unsafe_unretained;
		Node	*children[2];
	}

	@property (copy, nonatomic)		id		key;
	@property (retain, nonatomic)	id		value;
	@property (assign, nonatomic)	int		balance;
	@property (assign, nonatomic)	Node	__unsafe_unretained *parent;
	@property (copy, nonatomic)		Node	*left;
	@property (copy, nonatomic)		Node	*right;

	- (id) initWithKey: (id) aKey value: (id) aValue andParent: (Node *) aParent;
	- (void) copyContentFromNode: (Node *) aNode;

	- (Node *) childAtSide: (ODSide) aSide;
	- (void) setChild: (Node *) aNode atSide: (ODSide) aSide;

	- (Node *) liveChild;
	- (ODSide) sideOfChild: (Node *) aNode;

	- (int) height;
	- (int) count;

	- (NSString *) description;
	- (NSString *) descriptionWithChildrenAndIndent: (NSInteger) indent;

	// NSCoding
	- (void) encodeWithCoder: (NSCoder *) encoder;
	- (id) initWithCoder: (NSCoder *) decoder;

	// NSCopying
	- (id) copyWithZone: (NSZone *) zone;

@end
