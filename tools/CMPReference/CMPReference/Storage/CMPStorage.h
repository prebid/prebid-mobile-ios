//
//  CMPDataStorageUserDefaults.h
//  CMPConsentTool
//





#import <Foundation/Foundation.h>
#import "CMPStorageProtocol.h"

@interface CMPStorage : NSObject<CMPStorageProtocol>
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@end
