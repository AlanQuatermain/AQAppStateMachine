#import "PropertyListWriter.h"
#import "NSString+Base64.h"
#import "NSString+Indent.h"
#import "SortedDictionary.h"


// forward declarations
@interface PropertyListWriter (Private)
	- (NSString *) propertyListXmlFromObject: (id) plist withIndent: (int) indentLevel;
@end


@implementation PropertyListWriter


/**
 \brief Initializes a new instance of the PropertyListWriter class.
 
 \return An initialized instance of the PropertyListWriter class.
 */
- (id) init {
	if (self = [super init]) {
		dateFormatter	= [[NSDateFormatter alloc] init];	
		[dateFormatter setDateFormat: @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
	}
	return self;
}


/**
 \brief Serializes an instance of NSDictionary, NSMutableDictionary, SortedDictionary or
	MutableSortedDictionary into an XML-encoded Property List format.
 
 \param dict The dictionary object to serialize.
 \param indentLevel Specifies the number of TAB characters to insert before the opening tag of the
 XML element.
 
 \return A string containing the XML property list representation of \a dict.
 
 \par Discussion
 The XML-encoded property list representations of the dictionary keys and valus are returned, in
 their dictionary order, enclosed within a \c <dict> XML element. Keys are enclosed withing \c <key>
 elements, and value representations follow.
 */
- (NSString *) propertyListXmlFromDictionary: (id) dict withIndent: (int) indentLevel{
	NSMutableString *xml = [NSMutableString string];
	NSString		*indent = [NSString stringWith: indentLevel copiesOfString: @"\t"];
	
	// serialize the dictionary content, one entry at a time
	[xml appendString: @"<dict>\r\n"];
	for (NSString *key in [dict keyEnumerator]) {
		// serialize key
		[xml appendString: indent];
		[xml appendFormat: @"\t<key>%@</key>\r\n", key];
		
		// serialize value
		[xml appendString: [self propertyListXmlFromObject: [dict valueForKey: key] withIndent: 1 + indentLevel]];
		[xml appendString: @"\r\n"];
	}
	[xml appendString: indent];
	[xml appendString: @"</dict>"];
	
	return xml;
}


/**
 \brief Serializes an NSArray instance into an XML-encoded Property List format.
 
 \param array The NSArray instance to serialize.
 \param indentLevel Specifies the number of TAB characters to insert before the opening tag of the
 XML element.
 
 \return A string containing the XML property list representation of \a array.
 
 \par Discussion
 The XML-encoded property list representations of the array elements are returned, in their array
 order, enclosed within an \c <array> XML element.
 */
- (NSString *) propertyListXmlFromArray: (NSArray *) array withIndent: (int) indentLevel {
	NSMutableString *xml = [NSMutableString string];
	
	[xml appendString: @"<array>\r\n"];
	for (id element in [array objectEnumerator]) {
		[xml appendString: [self propertyListXmlFromObject: element withIndent: 1 + indentLevel]];
		[xml appendString: @"\r\n"];
	}
	[xml appendString: [NSString stringWith: indentLevel copiesOfString: @"\t"]];
	[xml appendString: @"</array>"];
	
	return xml;
}


/**
 \brief Serializes an NSNumber instance into an XML-encoded Property List format.
 
 \param number The NSNumber instance to serialize.
 \param indentLevel Specifies the number of TAB characters to insert before the opening tag of the
 XML element.
 
 \return A string containing the XML property list representation of \a number.
 
 \par Discussion
 Only \c intValue, \c floatValue and \c boolValue NSNumber instances are supported. They are encoded
 as \c <integer>, \c <real> and \c <true>/<false> XML elements, respectively.
 */
- (NSString *) propertyListXmlFromNumber: (NSNumber *) number {
	const char *numberType = [number objCType];
	
	if (!strcmp(numberType, @encode(int)))		{ return [NSString stringWithFormat: @"<integer>%d</integer>", [number intValue]]; }
	if (!strcmp(numberType, @encode(float)))	{ return [NSString stringWithFormat: @"<real>%.16LF</real>", (long double) [number floatValue]]; }
	if (!strcmp(numberType, @encode(BOOL)))		{ return [NSString stringWithFormat: @"<%@/>", [number boolValue] ? @"true" : @"false"]; }

	NSAssert(NO, @"Property list contained an unsupported number type");
	return nil;
}


/**
 \brief Serializes an NSData instance into an XML-encoded Property List format.
 
 \param data The NSData object to serialize.
 \param indentLevel Specifies the number of TAB characters to insert before the opening tag of the
	XML element.
 
 \return A string containing the XML property list representation of \a data.
 
 \par Discussion
 \a data is encoded as the base64 representation of its bits, enclosed within a \c <data> XML
 element.
 */
- (NSString *) stringFromData: (NSData *) data withIndent: (int) indentLevel{
	NSString *indent = [NSString stringWith: indentLevel copiesOfString: @"\t"];

	return [NSString stringWithFormat: @"<data>\r\n%@\t%@\r\n%@</data>",
		indent,
		[NSString encodeBase64: data],
		indent];
}


/**
 \brief Serializes an object into an XML-encoded Property List.
 
 \param plist The object to serialize. Must be an instance of SortedDictionary,
	MutableSortedDictionary, \c NSArray, \c NSString, \c NSNumber, \c NSDate or \c NSData.
 \param indentLevel Specifies the number of TAB characters to insert before the opening tag of the
	XML element.

 \return A string containing the XML property list representation of \a plist.
 
 \par Discussion
 This method encodes \a plist as an XML-based property list and returns the result. The following
 classes are supported: SortedDictionary, MutableSortedDictionary, \c NSArray, \c NSString,
 \c NSNumber, \c NSDate and \c NSData. Dictionary keys must be \c instances of \c NSString.
 */- (NSString *) propertyListXmlFromObject: (id) plist withIndent: (int) indentLevel {
	NSString *result = nil;
	
	// serialize the plist object according to its type
		 if ([plist isKindOfClass: [SortedDictionary class]] ||
			 [plist isKindOfClass: [NSDictionary class]])		{ result = [self propertyListXmlFromDictionary: plist  withIndent: indentLevel]; }
	else if ([plist isKindOfClass: [NSArray class]])			{ result = [self propertyListXmlFromArray: plist  withIndent: indentLevel]; }
	else if ([plist isKindOfClass: [NSString class]])			{ result = [NSString stringWithFormat: @"<string>%@</string>", plist]; }
	else if ([plist isKindOfClass: [NSNumber class]])			{ result = [self propertyListXmlFromNumber: plist]; }
	else if ([plist isKindOfClass: [NSDate class]])				{ result = [NSString stringWithFormat: @"<date>%@</date>", [dateFormatter stringFromDate: plist]]; }
	else if ([plist isKindOfClass: [NSData class]])				{ result = [self stringFromData: plist withIndent: indentLevel]; }
	
	NSAssert(result, @"Property list contained an unsupported type");
	
	// return the correctly indented property list string representation of the object
	return result
		? [NSString stringWithFormat: @"%@%@", [NSString stringWith: indentLevel copiesOfString: @"\t"], result]
		: @"";
}


/**
 \brief Serializes an object into an XML-encoded Property List.
 
 \param plist The object to serialize. Must be an instance of SortedDictionary,
	MutableSortedDictionary, \c NSArray, \c NSString, \c NSNumber, \c NSDate or \c NSData.
 
 \return A data object containing the UTF-8 encoded XML property list representation of \a plist,
	wrapped inside an XML header and a \<plist\> containing element.
 
 \par Discussion
 This method encodes \a plist as an XML-based property list and returns the result. The following
 classes are supported: SortedDictionary, MutableSortedDictionary, \c NSArray, \c NSString,
 \c NSNumber, \c NSDate and \c NSData. Dictionary keys must be \c instances of \c NSString.
 */
- (NSData *) writePropertyList: (id) plist {
	NSMutableString *xml = [NSMutableString string];
	
	[xml appendString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n"];
	[xml appendString: @"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\r\n"];
	[xml appendString: @"<plist version=\"1.0\">\r\n"];
	[xml appendString: [self propertyListXmlFromObject: plist withIndent: 0]];
	[xml appendString: @"</plist>\r\n"];
	
	return [xml dataUsingEncoding: NSUTF8StringEncoding];
}


@end
