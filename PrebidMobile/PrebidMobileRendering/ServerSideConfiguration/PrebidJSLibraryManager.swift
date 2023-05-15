/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

fileprivate let PBMJSLibraryFileDirectory = "PBMJSLibraries"

fileprivate let mraidLibraryURL = "https://cdn.jsdelivr.net/gh/prebid/prebid-mobile-ios@master/js/mraid.js"
fileprivate let omsdkLibraryURL = "https://cdn.jsdelivr.net/gh/prebid/prebid-mobile-ios@master/js/omsdk.js"

public typealias PrebidJSLibraryContentsCallback = (String?) -> ()

@objcMembers
public class PrebidJSLibraryManager: NSObject {
    
    public static let shared = PrebidJSLibraryManager()
    
    var mraidLibrary: PrebidJSLibrary = {
        PrebidJSLibrary(name: "mraid", downloadURLString: mraidLibraryURL)
    }()
    
    var omsdkLibrary: PrebidJSLibrary = {
        PrebidJSLibrary(name: "omsdk", downloadURLString: omsdkLibraryURL)
    }()
    
    private var connection: PrebidServerConnection
    
    init(connection: PrebidServerConnection = .shared) {
        self.connection = connection
        super.init()
    }
    
    public func downloadLibraries() {
        for library in [mraidLibrary, omsdkLibrary] {
            if checkIfCached(library.name) == false {
                downloadJSLibrary(
                    libraryName: library.name,
                    downloadURLString: library.downloadURLString,
                    with: connection
                )
            }
        }
    }
    
    public func getMRAIDLibrary() -> String? {
        fetchLibrary(mraidLibrary)
    }
    
    public func getOMSDKLibrary() -> String? {
        fetchLibrary(omsdkLibrary)
    }
    
    func fetchLibrary(_ jsLibrary: PrebidJSLibrary) -> String? {
        // search for cached library
        if let cachedLibraryContents = getLibraryFromDisk(with: jsLibrary.name) {
            return cachedLibraryContents
        }
        // no stored libraries - try download
        else {
            downloadLibraries()
        }
        
        return nil
    }
    
    func downloadJSLibrary(
        libraryName: String,
        downloadURLString: String?,
        with connection: PrebidServerConnectionProtocol,
        completion: PrebidJSLibraryContentsCallback? = nil
    ) {
        guard let urlString = downloadURLString, !urlString.isEmpty else {
            completion?(nil)
            Log.error("Could not load remote library - download URL is empty")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            connection.download(urlString) { [weak self] response in
                guard let data = response.rawData, response.error == nil else {
                    completion?(nil)
                    Log.error("Error occured during fetching remote library")
                    return
                }
                
                // updating contents string
                let contentsString = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    completion?(contentsString)
                }
                
                // saving library into disk memory
                self?.saveLibrary(with: libraryName, contents: contentsString)
            }
        }
    }
    
    func saveLibrary(with name: String, contents: String?) {
        guard let libContentsURL = getPath(with: "\(name).js") else {
            return
        }
        
        guard let data = contents?.data(using: .utf8) else {
            return
        }
        
        do {
            try data.write(to: libContentsURL)
        } catch {
            Log.error("Error occurred while saving js lib: \(error.localizedDescription)")
        }
    }
    
    func getLibraryFromDisk(with name: String) -> String? {
        guard let path = getPath(with: "\(name).js") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: path)
            return String(data: data, encoding: .utf8)
        } catch {
            Log.info("Error occured while reading library from disk: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func checkIfCached(_ filename: String) -> Bool {
        getLibraryFromDisk(with: filename) != nil
    }
    
    /**
     For debug use only!
     */
    func clearData() {
        let fileManager = FileManager.default
        
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            Log.error("Cache directory does not exist")
            return
        }
        
        let directoryURL = cacheDirectory.appendingPathComponent(PBMJSLibraryFileDirectory)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    Log.error("Ooops! Something went wrong: \(error)")
                }
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func getPath() -> URL? {
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            Log.error("Cache directory does not exist")
            return nil
        }
        
        let directoryURL = cacheDirectory.appendingPathComponent(PBMJSLibraryFileDirectory)
        
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Log.error("Error creating directory: \(error.localizedDescription)")
                return nil
            }
        }
        
        return directoryURL
    }
    
    func getPath(with fileName: String) -> URL? {
        guard let path = getPath() else { return nil }
        return path.appendingPathComponent(fileName)
    }
}
