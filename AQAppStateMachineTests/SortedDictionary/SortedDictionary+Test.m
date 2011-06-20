#import "SortedDictionary+Test.h"
#import "AvlTree.h"
#import "Node.h"


@implementation SortedDictionary (Test)


- (BOOL) balancesAreCorrectForNode: (Node *) node {
	if (!node) { return YES; }
	
	BOOL	leftBalanceIsCorrect	= [self balancesAreCorrectForNode: [node left]];
	BOOL	rightBalanceIsCorrect	= [self balancesAreCorrectForNode: [node right]];
	int		leftHeight				= [[node left] height];
	int		rightHeight				= [[node right] height];
	int		expectedBalance			= rightHeight - leftHeight;
	int		foundBalance			= [node balance];
	BOOL	nodeBalanceIsCorrect	= foundBalance == expectedBalance;
	
	return leftBalanceIsCorrect && rightBalanceIsCorrect && nodeBalanceIsCorrect;
}


- (BOOL) balancesAreCorrect {
	return [tree root] ? [self balancesAreCorrectForNode: [tree root]] : YES;
}


@end
