#import "PropertyListReader.h"
#import "NSString+Base64.h"
#import "MutableSortedDictionary.h"


// state of the reader while parsing the property list XML content
typedef enum { waitingForPlist, waitingForKey, waitingForValue, waitingForElement, done } State;


/**
 Context objects are pushed into the reader stack as the parser descends into embedded collections,
 such as array and dictionary values.
 */
@interface Context : NSObject { State state; id container; NSString *key; }
	@property(assign, nonatomic) State		state;		///< the current reader state
	@property(retain, nonatomic) id			container;	///< the current container being read into; NSArray or SortedDictionary
	@property(retain, nonatomic) NSString	*key;		///< most recent dictionary key read; for use with the next dictionary value
	+ (id) contextWithContainer: (id) aContainer andState: (State) aState;
	- (id) initWithContainer: (id) aContainer andState: (State) aState;
@end

@implementation Context
	@synthesize state, container, key;
	+ (id) contextWithContainer: (id) aContainer andState: (State) aState {
#if USING_ARC
		return [[Context alloc] initWithContainer: aContainer andState: aState];
#else
		return [[[Context alloc] initWithContainer: aContainer andState: aState] autorelease];
#endif
	}
	- (id) initWithContainer: (id) aContainer andState: (State) aState {
		if (self = [super init]) { 
#if USING_ARC
			container = aContainer;
#else
			container = [aContainer retain];
#endif
			state = aState;
			key = nil;
		}
		return self;
	}
#if !USING_ARC
- (void) dealloc { [container release]; [key release]; [super dealloc]; }
#endif
@end


@implementation PropertyListReader


/**
 \brief Initializes a new PropertyListReader object to read from the specified data object.
 
 \param data A data object containing the encoded property list to read.
 
 \return An initialized instance of PropertyListReader
 */
- (id) initWithData: (NSData *) data {
	if (self = [super init]) {
		parser			= [[NSXMLParser alloc] initWithData: data];
		[parser setDelegate: self];
		
		stack			= [[NSMutableArray alloc] init];
		[stack addObject: [Context contextWithContainer: nil andState: waitingForPlist]];
		
		dateFormatter	= [[NSDateFormatter alloc] init];	
		[dateFormatter setDateFormat: @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
		
	}
	return self;
}


/**
 \brief Parses the data object supplied to initWithData: and returns an object representing the
	parsed property list
 
 \return An object representing the parsed property list. This can be a SortedDictionary,
 \c NSArray, \c NSString, \c NSNumber, \c NSDate or \c NSData, according to the content of the
 property list. \c nil is returned if an error occurs during reading.
 */
- (id) read {
	[parser parse];
	return plist;
}


/**
 \brief Creates a strongly typed object representing the string in \a content, according to the type
	represented by the property list XML element name in \a elementName.
 
 \param elementName The name of the property list XML element that contained the string to convert.
 \param content A string to convert.
 
 \return An object containing the strongly typed value converted from \a content.
 
 \par Discussion
 The returned object can be of type NSString, NSDate, NSNumber (with either an \c intValue, a \c
 floatValue, or a \c boolValue), or NSData.
 */
- (id) typedValueOfElement: (NSString *) elementName withContent: (NSString *) content {
#if USING_ARC
		 if ([elementName isEqualToString: @"string"])	{ return [content copy]; }
	else if ([elementName isEqualToString: @"key"])		{ return [content copy]; }
#else
		 if ([elementName isEqualToString: @"string"])	{ return [[content copy] autorelease]; }
	else if ([elementName isEqualToString: @"key"])		{ return [[content copy] autorelease]; }
#endif
	else if ([elementName isEqualToString: @"date"])	{ return [dateFormatter dateFromString: content]; }
	else if ([elementName isEqualToString: @"integer"])	{ return [NSNumber numberWithInt: [content intValue]]; }
	else if ([elementName isEqualToString: @"real"])	{ return [NSNumber numberWithFloat: [content floatValue]]; }
	else if ([elementName isEqualToString: @"true"])	{ return [NSNumber numberWithBool: YES]; }
	else if ([elementName isEqualToString: @"false"])	{ return [NSNumber numberWithBool: NO]; }
	else if ([elementName isEqualToString: @"data"])	{ return [[content stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] decodeBase64]; }
	else												{ return nil; }
}


/**
 \brief Called when the XML parser encounters the opening tag of an XML element.
 */
- (void)		parser: (NSXMLParser *) aParser
	   didStartElement: (NSString *) elementName
		  namespaceURI: (NSString *) namespaceURI
		 qualifiedName: (NSString *) qualifiedName
			attributes: (NSDictionary *) attributeDict {

	// reset the tracked element content, to track the content of the new element
#if !USING_ARC
	[elementContent release];
#endif
	elementContent = [[NSMutableString alloc] init];
	
	// if the new element represents a collection, push a new context into the reader stack to track
	// subsequent elements for the collection contents.
	State state = (State)[[stack lastObject] state];
	if ([elementName isEqualToString: @"dict"]) {
		switch (state) { case waitingForKey: case done: plist = nil; [aParser abortParsing]; return; default: break; }
		[stack addObject: [Context contextWithContainer: [MutableSortedDictionary dictionary]
											   andState: waitingForKey]];
	}
	else if ([elementName isEqualToString: @"array"]) {
		switch (state) { case waitingForKey: case done: plist = nil; [aParser abortParsing]; return; default: break; }
		[stack addObject: [Context contextWithContainer: [NSMutableArray array]
											   andState: waitingForElement]];
	}
}


/**
 \brief Called when the XML parser encounters character content. Accumulates the character for use
	when the end of current XML element is encountered.
 */
- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string {
	[elementContent appendString: string];
}


/**
 \brief Called when the XML parser encounters the closing tag of an XML element. Finishes parsing
	the content of the element, puts the parsed value into the appropriate property list container,
	and if the element was a container itself -- pops if off the reader stack.
 */
- (void)		parser: (NSXMLParser *) aParser 
		 didEndElement: (NSString *) elementName
		  namespaceURI: (NSString *) namespaceURI
		 qualifiedName: (NSString *) qName {
	
	// finish parsing the element's content...
	
	// ...if the element is a dictionary or an array then parsing is done. pop it off the stack...
	id readObject;
	if ([elementName isEqualToString: @"dict"]) {
		readObject = [[stack lastObject] container];
		[stack removeLastObject];
	}
	else if ([elementName isEqualToString: @"array"]) {
		readObject = [[stack lastObject] container];
		[stack removeLastObject];
	}
	// ...otherwise, just parse the element's content as an atomic value.
	else {
		readObject = [self typedValueOfElement: elementName withContent: elementContent];
	}
	
	// ...and check that a valid value was read.
	Context *context = [stack lastObject];
	if (!readObject && ([context state] != done)) { plist = nil; [parser abortParsing]; return; }	
	
	// put the parsed value into the appropriate property list container
	switch ([context state]) {
		case waitingForPlist:	// reached final </plist> tag
#if USING_ARC
			plist = readObject;			// we'll return this from the read method
#else
			plist = [readObject retain];
#endif
			[context setState: done];				// don't try to parse anything else
			break;
			
		case waitingForKey:		// finished reading a dictionary key name
			NSAssert([[context container] isKindOfClass: [SortedDictionary class]], @"Should be parsing a <dictionary>");
			if (![elementName isEqualToString: @"key"]) { plist = nil; [parser abortParsing]; return; }
			[context setKey: readObject];			// keep the key until we read its associated value
			[context setState: waitingForValue];	// the next element will be the value
			break;
			
		case waitingForValue:	// finished reading a dictionary value
			NSAssert([[context container] isKindOfClass: [SortedDictionary class]], @"Should be parsing a <dictionary>");
			NSAssert([context key], @"Should have seen a <key> first");
			[[context container] setObject: readObject forKey: [context key]];
			[context setState: waitingForKey];		// the next element will be the next key
			[context setKey: nil];
			break;
			
		case waitingForElement:	// finished reading an array element
			NSAssert([[context container] isKindOfClass: [NSArray class]], @"Should be parsing an <array>");
			[[context container] addObject: readObject];
			break;
			
		default:
			break;
	}
}

- (void) dealloc {
	[parser setDelegate: nil];
#if !USING_ARC
	[elementContent release];
	[dateFormatter release];
	[stack release];
	[parser release];
	[super dealloc];
#endif
}


@end
