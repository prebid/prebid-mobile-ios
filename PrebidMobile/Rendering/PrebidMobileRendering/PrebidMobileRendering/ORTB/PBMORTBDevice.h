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

#import "PBMORTBAbstract.h"

@class PBMORTBDeviceExtAtts;
@class PBMORTBDeviceExtPrebid;
@class PBMORTBGeo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.18: Device

//This object provides information pertaining to the device through which the user is interacting. Device
//information includes its hardware, platform, location, and carrier data. The device can refer to a mobile
//handset, a desktop computer, set top box, or other digital device.
@interface PBMORTBDevice : PBMORTBAbstract
    
//Browsers user agent string
@property (nonatomic, copy, nullable) NSString *ua;

//Location of the device, assumed to be the user's location
@property (nonatomic, strong) PBMORTBGeo *geo;

//Do Not Track flag, set in the header by the browser: 0 = unrestricted, 1 = do no track
//Note: dnt is not supported as it's for browsers

//Limit Ad Tracking flag: 0 = unrestricted, 1 = tracking must be limited per commercial guidelines
@property (nonatomic, strong, nullable) NSNumber *lmt;

//IPv4 address closest to the device
//Note: ip not supported

//IPv6 address closest to the device
//Note: ipv6 not supported

//Int. General type of the device. See 5.17:
//Value Description Notes
//1 Mobile/Tablet Version 2.0
//2 Personal Computer Version 2.0
//3 Connected TV Version 2.0
//4 Phone New for Version 2.2
//5 Tablet New for Version 2.2
//6 Connected Device New for Version 2.2
//7 Set Top Box New for Version 2.2
@property (nonatomic, strong, nullable) NSNumber *devicetype;

//Device Make
@property (nonatomic, copy, nullable) NSString *make;

//Device Model
@property (nonatomic, copy, nullable) NSString *model;

//Device operating system
@property (nonatomic, copy, nullable) NSString *os;

//Device operating system version
@property (nonatomic, copy, nullable) NSString *osv;

//Hardware version of the device
@property (nonatomic, copy, nullable) NSString *hwv;

//Physical height of the screen in pixels
@property (nonatomic, strong, nullable) NSNumber *h;

//Physical width of the screen in pixels
@property (nonatomic, strong, nullable) NSNumber *w;

//Screen size as pixels per linear inch
@property (nonatomic, strong, nullable) NSNumber *ppi;

//Ratio of physical pixels to device independent pixels
@property (nonatomic, strong, nullable) NSNumber *pxratio;

//Support for javascript: 0 = no, 1 = yes
@property (nonatomic, strong, nullable) NSNumber *js;

//Indicates if the geolocation API will be available to JavaScript
//code running in the banner, where 0 = no, 1 = yes.
@property (nonatomic, strong, nullable) NSNumber *geofetch;

//Version of flash supported by the browser
@property (nonatomic, copy, nullable) NSString *flashver;

//Browser language using ISO-639-1-alpha-2
@property (nonatomic, copy, nullable) NSString *language;

//Carrier or ISP
@property (nonatomic, copy, nullable) NSString *carrier;

//Mobile carrier as the concatenated MCC-MNC code (e.g.,
//“310-005” identifies Verizon Wireless CDMA in the USA).
//Refer to https://en.wikipedia.org/wiki/Mobile_country_code
//for further examples. Note that the dash between the MCC
//and MNC parts is required to remove parsing ambiguity.
@property (nonatomic, copy, nullable) NSString *mccmnc;

//Network connection type. See table 5.18:
//0 Unknown
//1 Ethernet
//2 WIFI
//3 Cellular Network – Unknown Generation
//4 Cellular Network – 2G
//5 Cellular Network – 3G
//6 Cellular Network – 4G
@property (nonatomic, strong, nullable) NSNumber *connectiontype;

//ID sanctioned for adverstiser use
@property (nonatomic, copy, nullable) NSString *ifa;

//Hardware device ID, hashed via SHA1
@property (nonatomic, copy, nullable) NSString *didsha1;

//Hardware device ID, hashed via MD5
@property (nonatomic, copy, nullable) NSString *didmd5;

//Platform device ID, hashed via SHA1
@property (nonatomic, copy, nullable) NSString *dpidsha1;

//Platform device ID, hashed via MD5
@property (nonatomic, copy, nullable) NSString *dpidmd5;

//MAC of the device hashed via SHA1
@property (nonatomic, copy, nullable) NSString *macsha1;

//MAC of the device hashed via MD5
@property (nonatomic, copy, nullable) NSString *macmd5;

//Placeholder for exchange-specific extensions to OpenRTB.

@property (nonatomic, readonly) PBMORTBDeviceExtPrebid *extPrebid;
@property (nonatomic, readonly) PBMORTBDeviceExtAtts *extAtts;

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
