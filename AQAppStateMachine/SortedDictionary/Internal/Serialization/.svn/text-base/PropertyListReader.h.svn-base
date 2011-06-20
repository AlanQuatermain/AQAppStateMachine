#import <Cocoa/Cocoa.h>


/**
 Use the PropertyListReader class to read XML-encoded property list files into a SortedDictionary.
 This class supports the implementation of the dictionaryWithContentsOfFile: and
 initWithContentsOfFile: methods of the SortedDictionary class.
 
 \see SortedDictionary::dictionaryWithContentsOfFile:
 \see SortedDictionary::dictionaryWithContentsOfUrl:
 \see SortedDictionary::writeToFile:atomically:
 \see SortedDictionary::writeToUrl:atomically:
 \see PropertyListWriter 
 */
@interface PropertyListReader : NSObject {
		NSXMLParser		*parser;			///< XML parser
		NSMutableArray	*stack;				///< a stack of reader contexts, used when descending into embedded collections (arrays, dictionaries)
		NSMutableString	*elementContent;	///< the character content of the currently parsed XML element
		id				plist;				///< the property list object to return from \a read
		NSDateFormatter	*dateFormatter;		///< used for parsing RFC822 dates in the input
	}

	- (id) initWithData: (NSData *) data;
	- (id) read;

@end
