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

#import "PBMWebView.h"
#import "PBMTransaction.h"

@protocol PBMNSThreadProtocol;

@interface PBMWebView ()

@property (nonatomic, assign, readwrite) PBMWebViewState state;

- (void)loadHTML:(nonnull NSString *)html
         baseURL:(nullable NSURL *)baseURL
   injectMraidJs:(BOOL)injectMraidJs
   currentThread:(nonnull id<PBMNSThreadProtocol>)currentThread;

- (void)expand:(nonnull NSURL *)url
 currentThread:(nonnull id<PBMNSThreadProtocol>)currentThread;

@end
