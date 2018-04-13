//
//  PBVPBSRequestResponseValidator.h
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/13/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#ifndef PBVPBSRequestResponseValidator_h
#define PBVPBSRequestResponseValidator_h
@interface PBVPBSRequestResponseValidator:NSObject
@property NSString *request;
@property NSString *response;

- (void)startTest;
@end

#endif /* PBVPBSRequestResponseValidator_h */
