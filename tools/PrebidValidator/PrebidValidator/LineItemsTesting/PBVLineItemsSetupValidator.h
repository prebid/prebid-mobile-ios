
@protocol PBVLineItemsSetupValidatorDelegate

- (void) lineItemsWereSetupProperly;
- (void) lineItemsWereNotSetupProperly;
@end


@interface PBVLineItemsSetupValidator: NSObject
@property id <PBVLineItemsSetupValidatorDelegate> delegate;

- (void) startTest;

- (NSDictionary *) getDisplayables;

- (NSString *) getEmailContent;

@end
