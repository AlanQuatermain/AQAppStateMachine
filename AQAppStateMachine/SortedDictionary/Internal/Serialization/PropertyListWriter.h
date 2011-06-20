#import <Foundation/Foundation.h>


/**
 Use the PropertyListWriter class to serialize objects as XML-encoded Property Lists.
 This class supports the implementation of the writeToFile:atomically: and writeToUrl:atomically:
 methods on the SortedDictionary class. The serialized format produced by this class is compatible
 with the PropertyListReader and \c NSPropertyListSerialization classed.
 
 \see SortedDictionary::writeToFile:atomically:
 \see SortedDictionary::writeToUrl:atomically:
 \see SortedDictionary::dictionaryWithContentsOfFile:
 \see SortedDictionary::dictionaryWithContentsOfUrl:
 \see PropertyListReader
 */
@interface PropertyListWriter : NSObject {
		NSDateFormatter	*dateFormatter;		///< used for parsing RFC822 dates in the input
	}

	- (id) init;
	- (NSData *) writePropertyList: (id) plist;

@end
