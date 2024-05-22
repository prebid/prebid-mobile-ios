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

struct Constants {

    // MARK: - AppNexus
    static let PBS_APPNEXUS_HOST_URL = "https://ib.adnxs.com/openrtb2/prebid"
    static let PBS_ACCOUNT_ID_APPNEXUS = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
    static let PBS_CONFIG_ID_300x250_APPNEXUS = "6ace8c7d-88c0-4623-8117-75bc3f0a2e45"
    static let PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS = "625c6125-f19e-4d5b-95c5-55501526b2a4"
    static let PBS_CONFIG_ID_NATIVE_APPNEXUS = "1f85e687-b45f-4649-a4d5-65f74f2ede8e"
    static let DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS = "/19968336/PrebidMobileValidator_Banner_All_Sizes"
    static let DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS = "/19968336/PrebidMobileValidator_Interstitial"
    static let DFP_NATIVE_ADUNIT_ID_APPNEXUS = "/19968336/Wei_Prebid_Native_Test"
    static let PBS_INVALID_ACCOUNT_ID_APPNEXUS = "bfa84af2-bd16-4d35-96ad-ffffffffffff"
    static let PBS_INVALID_CONFIG_ID_APPNEXUS = "6ace8c7d-88c0-4623-8117-ffffffffffff"
    
    // MARK: - Rubicon
    static let PBS_RUBICON_ACCOUNT_ID = "1001"
    static let PBS_CONFIG_ID_300x250_RUBICON = "1001-1"
    static let PBS_CONFIG_ID_INTERSTITIAL_RUBICON = "1001-1"
    static let PBS_CONFIG_ID_NATIVE_RUBICON = ""
    static let DFP_BANNER_ADUNIT_ID_300x250_RUBICON = "/5300653/test_adunit_pavliuchyk_300x250_prebid-server.rubiconproject.com_puc"
    static let DFP_INTERSTITIAL_ADUNIT_ID_RUBICON = ""
    static let DFP_NATIVE_ADUNIT_ID_RUBICON = ""
    static let PBS_INVALID_ACCOUNT_ID_RUBICON = "1001_ERROR"
    static let PBS_INVALID_CONFIG_ID_RUBICON = "1001-1_ERROR"

    // MARK: - Common
    static let PBS_EMPTY_ACCOUNT_ID = ""
    static let PBS_EMPTY_CONFIG_ID = ""
}
