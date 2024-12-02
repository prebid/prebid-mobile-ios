/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

/// This protocol is used to load and display the ad content in a view.
@protocol PrebidMobileDisplayViewProtocol <NSObject>

/// Loads the ad content into the display view.
/// - Important: This method is expected to call the `loadingDelegate` once the
/// ad is successfully loaded or if any error occurred.
- (void)loadAd;

@end
