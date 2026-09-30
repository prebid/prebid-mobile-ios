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

public class ImageHelper {
    public static func downloadImageSync(_ urlString: String) -> Result<UIImage, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(PBMError.init(message: "Image URL is invalid"))
        }
        
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return .success(image)
            } else {
                return .failure(PBMError.init(message: "Error while creating UIImage from received data"))
            }
        } else {
            return .failure(PBMError.init(message: "Error while receiving data by url"))
        }
    }

    public static func downloadImageAsync(_ urlString: String, completion: @escaping(Result<UIImage, Error>) -> Void) {
        downloadImageAsync(urlString, session: .shared, completion: completion)
    }

    static func downloadImageAsync(
        _ urlString: String,
        session: URLSession,
        completion: @escaping(Result<UIImage, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completeOnMain(
                with: .failure(PBMError.init(message: "Image URL is invalid")),
                completion: completion
            )
            return
        }

        session.dataTask(with: url) { data, response, error in
            let result: Result<UIImage, Error>
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200

            if error != nil || statusCode >= 400 {
                result = .failure(PBMError.init(message: "Error while receiving data by url"))
            } else if let data, let image = UIImage(data: data) {
                result = .success(image)
            } else if data == nil {
                result = .failure(PBMError.init(message: "Error while receiving data by url"))
            } else {
                result = .failure(PBMError.init(message: "Error while creating UIImage from received data"))
            }

            completeOnMain(with: result, completion: completion)
        }.resume()
    }

    private static func completeOnMain(
        with result: Result<UIImage, Error>,
        completion: @escaping(Result<UIImage, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
