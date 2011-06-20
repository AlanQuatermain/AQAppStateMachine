#import "NSString+Indent.h"


@implementation NSString (Indent)


/**
 \brief Returns a string containing \a count copies of the \a copyMe string.
 
 \return A string containing \a count concatenated copies of the \a copyMe string.
 
 \param count The number of times to copy \a copyMe.
 \param copyMe The string to copy and concatenate. For indentation, this is often a string of
	one or more whitespaces or tab characters.
 */
+ (NSString *) stringWith: (NSInteger) count copiesOfString: (NSString *) copyMe {
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity: count * [copyMe length]];
	
	for (int i = 0; i < count; ++i) {
		[result appendString: copyMe];
	}
	
	return result;
}


@end
