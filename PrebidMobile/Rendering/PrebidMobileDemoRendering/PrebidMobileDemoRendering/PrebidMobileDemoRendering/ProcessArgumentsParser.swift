//
//  ProcessArgumentsParser.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import Foundation

class ProcessArgumentsParser {
    public typealias LaunchOptionHandler = ([String])->()
    public typealias AcceptedParamsRange = (min: Int, max: Int?)
    
    private struct OptionInfo {
        let acceptedParamsRange: AcceptedParamsRange
        let handler: LaunchOptionHandler
    }
    
    private var options: [String: OptionInfo] = [:]
    
    public func addOption(_ option: String,
                          acceptedParamsRange: AcceptedParamsRange = (min: 0, max: nil),
                          fireOnce: Bool = false,
                          handler: @escaping LaunchOptionHandler)
    {
        let theHandler: LaunchOptionHandler
        if fireOnce {
            let flagBox = NSMutableArray(object: NSNumber(false))
            theHandler = { params in
                guard let flag = flagBox[0] as? NSNumber, flag.boolValue == false else {
                    return
                }
                flagBox[0] = NSNumber(true)
                handler(params)
            }
        } else {
            theHandler = handler
        }
        options[option] = OptionInfo(acceptedParamsRange: acceptedParamsRange, handler: theHandler)
    }
    
    public func addOption(_ option: String,
                          paramsCount: Int,
                          fireOnce: Bool = false,
                          handler: @escaping LaunchOptionHandler)
    {
        addOption(option,
                  acceptedParamsRange: (min: paramsCount, max: paramsCount),
                  fireOnce:fireOnce,
                  handler: handler)
    }
    
    public func parseProcessArguments(_ launchOptions: [String]) {
        if launchOptions.count < 2 {
            // the first argument is the executable file itself
            return
        }
        
        var option: OptionInfo? = nil
        var optionParams: [String] = []
        
        func handleLastOption() {
            guard let option = option, option.acceptedParamsRange.min <= optionParams.count else {
                return
            }
            if let maxParams = option.acceptedParamsRange.max, maxParams < optionParams.count {
                let callOptions = optionParams[0..<maxParams]
                option.handler(Array(callOptions))
            } else {
                option.handler(optionParams)
            }
        }
        
        for i in 1..<launchOptions.count {
            let nextFragment = launchOptions[i]
            if let nextOption = options[nextFragment] {
                handleLastOption()
                option = nextOption
                optionParams = []
            } else {
                if option != nil {
                    optionParams.append(nextFragment)
                }
            }
        }
        handleLastOption()
    }
}
