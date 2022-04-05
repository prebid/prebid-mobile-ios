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

import UIKit

class TabViewController: UITabBarController {
    
    var testCasesManager = TestCaseManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arguments = ProcessInfo.processInfo.arguments
        if let customOpenRTBIndex = arguments.firstIndex(of: "EXTRA_OPEN_RTB") {
            if customOpenRTBIndex < arguments.count - 1 {
                testCasesManager.parseCustomOpenRTB(openRTBString: arguments[customOpenRTBIndex + 1])
            }
        }

        createTabs()
    }

    // MARK: - Private Methods
    
    private func createTabs() {
        
        let tabBarList = [
            { self.createTab(navBarTitle: "Prebid Examples", iconName: "list.bullet", tag: $0) },
            createTabUtilities,
        ].enumerated().compactMap { $1($0) }
        
        viewControllers = tabBarList
    }
    
    private func createTab(navBarTitle: String, iconName: String, tag: Int) -> UIViewController? {
        let vc = TabNavigationController()
        vc.navigationBar.isTranslucent = false
        vc.navigationBar.barTintColor = UIColor(red: 42.0/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 0.0);
        vc.navigationBar.tintColor = .white
        vc.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        
        vc.tabBarItem = getTabBarItem(title: "Examples", sysName: iconName, tag: tag)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "TestCasesViewController") as? TestCasesViewController else {
            return nil
        }
        
        let allExamples = testCasesManager.testCases
        let filteredExamples: () -> [TestCase] = {
            var result = allExamples
            if !GlobalVars.reactiveGAMInitFlag.sdkInitialized {
                result = result.filter { !$0.tags.contains(.gam) }
            }
            return result
        }
        
        controller.examples = filteredExamples()
        controller.navigationItem.title = navBarTitle
        
        if !GlobalVars.reactiveGAMInitFlag.sdkInitialized {
            GlobalVars.reactiveGAMInitFlag.onSdkInitialized {
                controller.examples = filteredExamples()
                controller.tableView?.reloadData()
            }
        }
         
        vc.pushViewController(controller, animated: false)

        return vc
    }
    
    private func createTabUtilities(tag: Int) -> UIViewController? {
        let controller = UtilitiesViewController()
        
        controller.tabBarItem = getTabBarItem(title: "Utilities", sysName: "info.circle", tag: tag)

        let navigator = UINavigationController(rootViewController: controller)
        
        return navigator
    }
    
    private func getTabBarItem(title: String, sysName: String, tag: Int) -> UITabBarItem {
        if #available(iOS 13.0, *) {
            return UITabBarItem(title: title, image: UIImage(systemName: sysName), tag: tag)
        } else {
            return UITabBarItem(title: title, image: nil, tag: tag)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
