/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

#import <UIKit/UIKit.h>
#import "IntegrationKind.h"
#import "AdFormat.h"

typedef UIViewController* (^ConfigurationClosure)(void);

@interface IntegrationCase : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) IntegrationKind integrationKind;
@property (nonatomic) AdFormat adFormat;
@property (nonatomic) ConfigurationClosure configurationClosure;

-(id)initWithTitle:(NSString *)title integrationKind:(IntegrationKind)integrationKind adFormat: (AdFormat)adFormat configurationClosure:(ConfigurationClosure)configurationClosure;

@end
