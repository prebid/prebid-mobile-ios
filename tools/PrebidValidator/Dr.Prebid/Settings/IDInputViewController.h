#import <UIKit/UIKit.h>

@protocol IdProtocol <NSObject>

-(void) sendSelectedId:(NSString *)idString forID:(NSString *) idLabel;

@end

@interface IDInputViewController: UIViewController

@property (weak, nonatomic) IBOutlet UITextField *idInputText;
@property (weak, nonatomic) IBOutlet UIImageView *imgScanQRCode;

@property (nonatomic,readwrite,weak) id<IdProtocol> delegate;

- (IBAction)btnScanQRCode:(id)sender;

@end
