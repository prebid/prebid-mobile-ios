//
//  MPXMLParser.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Parses XML data into a JSON dictionary.
 */
@interface MPXMLParser : NSObject

/**
 Parses data containing XML into its JSON equivalent.
 @param data XML data to parse.
 @return Parsed XML as JSON if successful; otherwise @c nil.
 */
- (NSDictionary * _Nullable)dictionaryWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
