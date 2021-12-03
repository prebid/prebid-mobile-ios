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

import Foundation
import XCTest

extension JSONDecoding {
    typealias Tester<T> = Decoding.Tester<NSMutableDictionary, T>
}

extension Decoding {
    class Tester<RawType, BoxedType> {
        let templateFactory: ()->RawType
        let generator: (RawType) throws -> BoxedType
        let requiredPropertyChecks: [(PropertyCheck<RawType, BoxedType>, Error)]
        let optionalPropertyChecks: [BaseOptionalCheck<RawType, BoxedType>]
        
        init(templateFactory: @escaping ()->RawType,
             generator: @escaping (RawType) throws -> BoxedType,
             requiredPropertyChecks: [(PropertyCheck<RawType, BoxedType>, Error)],
             optionalPropertyChecks: [BaseOptionalCheck<RawType, BoxedType>])
        {
            self.templateFactory = templateFactory
            self.generator = generator
            self.requiredPropertyChecks = requiredPropertyChecks
            self.optionalPropertyChecks = optionalPropertyChecks
        }
        
        convenience init(template: @escaping @autoclosure ()->RawType,
                         generator: @escaping (RawType) throws -> BoxedType,
                         requiredPropertyChecks: [(PropertyCheck<RawType, BoxedType>, Error)],
                         optionalPropertyChecks: [BaseOptionalCheck<RawType, BoxedType>])
        {
            self.init(templateFactory: template,
                      generator: generator,
                      requiredPropertyChecks: requiredPropertyChecks,
                      optionalPropertyChecks: optionalPropertyChecks)
        }
        
        convenience init(template: @escaping @autoclosure ()->RawType = RawType(),
                         generator: @escaping ([String: Any]) throws -> BoxedType,
                         requiredPropertyChecks: [(PropertyCheck<RawType, BoxedType>, Error)],
                         optionalPropertyChecks: [BaseOptionalCheck<RawType, BoxedType>]) where RawType == NSMutableDictionary
        {
            self.init(templateFactory: template,
                      generator: { try generator($0 as! [String:Any]) },
                      requiredPropertyChecks: requiredPropertyChecks,
                      optionalPropertyChecks: optionalPropertyChecks)
        }
        
        func run(file: StaticString = #file, line: UInt = #line) {
            // catch errors on missing any required property
            for i in 0..<requiredPropertyChecks.count {
                let checks = requiredPropertyChecks.enumerated().filter { $0.offset != i }.map { $0.element.0.saver }
                runFailTest(savers: checks, expectedError: requiredPropertyChecks[i].1)
            }
            
            let allRequiredProperties = requiredPropertyChecks.map { $0.0 }
            let enumeratedOptionals = optionalPropertyChecks.enumerated()
            
            if (optionalPropertyChecks.count > 1) {
                // check all required + single optional
                for i in 0..<optionalPropertyChecks.count {
                    let selectedOptionals = enumeratedOptionals.map{ $0.element.toPropertyCheck(included: $0.offset == i) }
                    runPropertiesCheck(propertyChecks: allRequiredProperties + selectedOptionals)
                }
                
                // check all required + (all - 1) optional
                for i in 0..<optionalPropertyChecks.count {
                    let selectedOptionals = enumeratedOptionals.map{ $0.element.toPropertyCheck(included: $0.offset != i) }
                    runPropertiesCheck(propertyChecks: allRequiredProperties + selectedOptionals)
                }
            }
            
            // check all properties
            let allOptionals = optionalPropertyChecks.map { $0.toPropertyCheck(included: true)}
            runPropertiesCheck(propertyChecks: allRequiredProperties + allOptionals)
        }
        
        func runFailTest(savers: [(RawType)->()],
                         expectedError: Error,
                         file: StaticString = #file,
                         line: UInt = #line)
        {
            let dic = templateFactory()
            savers.forEach { $0(dic) }
            do {
                _ = try generator(dic)
                XCTFail("no error was thrown", file: file, line: line)
            } catch {
                XCTAssertEqual(error as NSError, expectedError as NSError)
            }
        }
        
        func runPropertiesCheck(propertyChecks: [PropertyCheck<RawType, BoxedType>],
                                file: StaticString = #file, line: UInt = #line) {
            let dic = templateFactory()
            propertyChecks.forEach { $0.saver(dic) }
            let entity: BoxedType
            do {
                entity = try generator(dic)
            } catch {
                XCTFail(error.localizedDescription, file: file, line: line)
                return
            }
            propertyChecks.forEach { $0.checker(entity) }
        }
    }
}
