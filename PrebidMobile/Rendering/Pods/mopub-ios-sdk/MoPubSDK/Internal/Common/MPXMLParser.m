//
//  MPXMLParser.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPXMLParser.h"

@interface MPXMLParser () <NSXMLParserDelegate>

// Stack of parsed XML elements as `NSMutableDictionary` entries.
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *elementStack;

// Currently parsed text content that exists as content of the XML node.
// For example:
// <Node>Text content</Node>
@property (nonatomic, strong) NSMutableString *currentTextContent;

// Fatal parsing error that may have occurred.
@property (nonatomic, strong, nullable) NSError *parseError;

@end

@implementation MPXMLParser

- (instancetype)init {
    if (self = [super init]) {
        _elementStack = [NSMutableArray array];

        // Create a "root" dictionary.
        [_elementStack addObject:[NSMutableDictionary dictionary]];

        _currentTextContent = [NSMutableString string];
        _parseError = nil;
    }
    return self;
}

- (NSDictionary * _Nullable)dictionaryWithData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];

    return (self.parseError != nil ? nil : self.elementStack.firstObject);
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString * _Nullable)namespaceURI qualifiedName:(NSString * _Nullable)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    // Retrieve the parent element of the currently parsed elemenet.
    NSMutableDictionary *parentElement = self.elementStack.lastObject;

    // Create a new JSON representing the current XML element and add
    // all of the attributes of the XML element as key-value pairs in the
    // current JSON element.
    NSMutableDictionary *currentElement = [NSMutableDictionary dictionary];
    [currentElement addEntriesFromDictionary:attributeDict];

    // Element is part of an array, add it to the existing array.
    // <Nodes>                    nodes: {
    //   <Node/>                    node: [],
    //   <Node/>                  }
    // </Nodes>
    if (parentElement[elementName] != nil && [parentElement[elementName] isKindOfClass:[NSArray class]]) {
        [parentElement[elementName] addObject:currentElement];
    }
    // An element of the same name already exists. Convert the JSON
    // entry from an object to an array of objects.
    else if (parentElement[elementName] != nil) {
        // Retrieve the object.
        NSMutableDictionary *previousElement = parentElement[elementName];

        // Create a new array containing the previous element and the currently
        // parsed element.
        NSMutableArray<NSMutableDictionary *> *elementsArray = [NSMutableArray array];
        [elementsArray addObject:previousElement];
        [elementsArray addObject:currentElement];

        // Replace the previous single object value with the array of elements.
        parentElement[elementName] = elementsArray;
    }
    // Safe to assign the current element since it doesn't exist.
    else {
        parentElement[elementName] = currentElement;
    }

    // Add the current element to the stack.
    [self.elementStack addObject:currentElement];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString * _Nullable)namespaceURI qualifiedName:(NSString * _Nullable)qName {
    // Retrieve the current element from the stack.
    NSMutableDictionary *currentElement = self.elementStack.lastObject;

    // Extract any element text content, and assign it to the "text" key.
    //                                     node: {
    // <Node>Text content</Node>             text: "Text content",
    //                                     }
    NSString *trimmedContent = [self.currentTextContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmedContent.length > 0) {
        currentElement[@"text"] = trimmedContent;
    }

    // Reset the text content for the next run through.
    self.currentTextContent = [NSMutableString string];

    // Remove the current element from the stack since it has finished parsing.
    [self.elementStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // Append whatever text found as the content of the node to `currentTextContent`.
    [self.currentTextContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Fatal parsing error. Parsing will stop at this point.
    self.parseError = parseError;
}

@end
