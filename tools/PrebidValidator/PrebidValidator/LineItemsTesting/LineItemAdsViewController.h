//
//  LineItemAdsViewController.h
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 24/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBVLineItemsSetupValidator.h"

@interface LineItemAdsViewController : UIViewController

-(instancetype)initWithValidator: (PBVLineItemsSetupValidator *) validator;

@end
