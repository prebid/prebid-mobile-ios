//
//  CMPSettings.m
//  CMPConsentTool
//





#import "CMPSettings.h"
#import "CMPStorage.h"

@interface CMPSettings()
@end

@implementation CMPSettings
-(id<CMPStorageProtocol>)dataStorage  {
    if (!_dataStorage) {
        _dataStorage = [[CMPStorage alloc] init];
    }
    return _dataStorage;
}

-(NSString *)consentString {
    return self.dataStorage.consentString;
}

-(void)setConsentString:(NSString *)consentString {
    self.dataStorage.consentString = consentString;
}

-(NSString *)subjectToGDPR {
    return self.dataStorage.subjectToGDPR;
}

-(void)setSubjectToGDPR:(NSString *)subjectToGDPR {
    self.dataStorage.subjectToGDPR = subjectToGDPR;
}

-(BOOL)cmpPresent {
    return self.dataStorage.cmpPresent;
}

-(void)setCmpPresent:(BOOL)cmpPresent {
    self.dataStorage.cmpPresent = cmpPresent;
}


-(NSString *)cmpURL {
    return self.dataStorage.cmpURL;

}

-(void)setCmpURL:(NSString *)cmpURL{
    self.dataStorage.cmpURL = cmpURL;

}
@end
