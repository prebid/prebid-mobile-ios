/*   Copyright 2018-2019 Prebid.org, Inc.

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

import Foundation

@objcMembers
public class Swizzling: NSObject {
    
    public class func exchangeClass(cls1: AnyClass, sel1: Selector, cls2: AnyClass, sel2: Selector) {
        
        let originalMethod = class_getClassMethod(cls1, sel1)
        let swizzledMethod = class_getClassMethod(cls2, sel2)
        
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }

    public class func exchangeInstance(cls1: AnyClass, sel1: Selector, cls2: AnyClass, sel2: Selector) {
        
        let originalMethod = class_getInstanceMethod(cls1, sel1)
        let swizzledMethod = class_getInstanceMethod(cls2, sel2)
        
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
