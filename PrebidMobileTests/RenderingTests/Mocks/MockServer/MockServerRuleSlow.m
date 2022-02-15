/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

#import <Foundation/Foundation.h>
#import "MockServerRuleSlow.h"

@interface MockServerRuleSlow()
@property (nonatomic, strong) NSArray<NSData*>* chunks;
@end


@implementation MockServerRuleSlow

- (instancetype)initWithURLNeedle:(NSString *)needle connectionID:(NSUUID *)connectionID data:(NSData *)data responseHeaderFields:(NSDictionary *)responseHeaderFields {
    self = [super initWithURLNeedle:needle connectionID:connectionID data:data responseHeaderFields:responseHeaderFields];
    if (self) {
        self.numChunks = 10;
        self.timeBetweenChunks = 1.0;
    }
    return self;
}

- (void) load:(nonnull NSURLProtocol*)nsURLProtocol {
    
    if (!self.willRespond) {
        return;
    }
    
    NSURLRequest* request = nsURLProtocol.request;
    
    //Send response
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:self.statusCode HTTPVersion:self.httpVersion headerFields:self.responseHeaderFields];
    [nsURLProtocol.client URLProtocol:nsURLProtocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    if ([request.HTTPMethod isEqualToString:@"HEAD"]) {
        [nsURLProtocol.client URLProtocolDidFinishLoading:nsURLProtocol];
        return;
    }
    
    //Split data into chunks
    self.chunks = [self splitDataIntoChunks:self.data numChunks:self.numChunks];
    
    //Start sending response data
    [self sendChunk:nsURLProtocol index:0];
}

- (NSArray<NSData*>*) splitDataIntoChunks:(NSData*)data numChunks:(int)numChunks {
    
    NSMutableArray<NSData*>* ret = [[NSMutableArray<NSData*> alloc] init];
    
    NSUInteger length = [data length];
    NSUInteger chunkSize = (length / numChunks) + 1;
    NSUInteger offset = 0;
    
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        [ret addObject:chunk];
        offset += thisChunkSize;
    } while (offset < length);
    
    return ret;
}

//Recursive function:
//Sends a specified chunk to the client, then calls itself to send the next
//When the last chunk is sent, calls urlProtocolDidFinishLoading.
-(void) sendChunk:(NSURLProtocol*)nsURLProtocol index:(int)index {
    if (!self.chunks) {
        NSError* error = [NSError  errorWithDomain:@"PrebidMobile MockServer Error Domain"
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to find chunks for MockServerRuleSlow", nil) }
        ];
        
        [nsURLProtocol.client URLProtocol:nsURLProtocol didFailWithError:error];
    }
    
    //Have we sent all the chunks
    if (index >= [self.chunks count]) {
        [nsURLProtocol.client URLProtocolDidFinishLoading:nsURLProtocol];
        return;
    }
    
    //Get the next chunk and send it
    NSLog(@"MockServerRuleSlow Sending Chunk #%i of %lu", index+1, (unsigned long)[self.chunks count]);
    NSData* chunk = [self.chunks objectAtIndex:index];
    [nsURLProtocol.client URLProtocol:nsURLProtocol didLoadData:chunk];
    
    //In .25 seconds, send the next chunk
    dispatch_time_t dispatchAfter = [MockServerRuleSlow dispatchTimeAfterTimeInterval:self.timeBetweenChunks];
    dispatch_after(dispatchAfter, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendChunk:nsURLProtocol index:index + 1];
    });
}

#pragma mark - dispatch_time
+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval {
    return [MockServerRuleSlow dispatchTimeAfterTimeInterval:timeInterval startTime:DISPATCH_TIME_NOW];
}

+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval startTime:(dispatch_time_t)startTime {
    NSInteger delta = timeInterval * NSEC_PER_SEC;
    return dispatch_time(startTime, delta);
}

@end
