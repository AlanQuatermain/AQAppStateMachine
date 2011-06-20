#import <Foundation/Foundation.h>


/**
 Extends the NSString class to simplify the indentation of strings written to some output.
 */
@interface NSString (Indent)

+ (NSString *) stringWith: (NSInteger) count copiesOfString: (NSString *) copyMe;

@end
