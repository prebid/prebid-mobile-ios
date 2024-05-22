//
//  CMPDataStorageUserDefaults.m
//  CMPConsentTool
//




#import "CMPStorage.h"

NSString *const IABConsent_SubjectToGDPRKey = @"IABConsent_SubjectToGDPR";
NSString *const IABConsent_ConsentStringKey = @"IABConsent_ConsentString";
NSString *const IABConsent_CMPPresentKey = @"IABConsent_CMPPresent";
NSString *const IABConsent_CMPURLPresentKey = @"IABConsent_CMPURLPresent";

@implementation CMPStorage

@synthesize consentString;
@synthesize subjectToGDPR;
@synthesize cmpPresent;
@synthesize cmpURL;


-(NSString *)cmpURL {
    return [self.userDefaults objectForKey:IABConsent_CMPURLPresentKey];
}

-(void)setCmpURL:(NSString *)consentString{
    [self.userDefaults setObject:consentString forKey:IABConsent_CMPURLPresentKey];
    [self.userDefaults synchronize];
}

-(NSString *)consentString {
    return [self.userDefaults objectForKey:IABConsent_ConsentStringKey];
}

-(void)setConsentString:(NSString *)consentString{
    [self.userDefaults setObject:consentString forKey:IABConsent_ConsentStringKey];
    [self.userDefaults synchronize];
}

-(NSString *)subjectToGDPR {
    NSString *subjectToGDPRAsString = [self.userDefaults objectForKey:IABConsent_SubjectToGDPRKey];
    
    if (subjectToGDPRAsString != nil) {
        if ([subjectToGDPRAsString isEqualToString:@"0"]) {
            return @"0";
        } else if ([subjectToGDPRAsString isEqualToString:@"1"]) {
            return @"1";
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

-(void)setSubjectToGDPR:(NSString *)subjectToGDPR {
    NSString *subjectToGDPRAsString = nil;

    if ([subjectToGDPR isEqualToString:@"0"] || [subjectToGDPR isEqualToString:@"1"]) {
        subjectToGDPRAsString = [NSString stringWithFormat:@"%@", subjectToGDPR];
    }
    
    [self.userDefaults setObject:subjectToGDPRAsString forKey:IABConsent_SubjectToGDPRKey];
    [self.userDefaults synchronize];
}

-(BOOL)cmpPresent {
    return [[self.userDefaults objectForKey:IABConsent_CMPPresentKey] boolValue];
}

-(void)setCmpPresent:(BOOL)cmpPresent {
    [self.userDefaults setBool:cmpPresent forKey:IABConsent_CMPPresentKey];
    [self.userDefaults synchronize];
}

- (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dataStorageDefaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"", IABConsent_ConsentStringKey,
                                                  [NSNumber numberWithBool:NO], IABConsent_CMPPresentKey,
                                                  nil];
        [_userDefaults registerDefaults:dataStorageDefaultValues];
    }
    return _userDefaults;
}

@end
