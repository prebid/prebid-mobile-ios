#import <UIKit/UIKit.h>

@interface IDInputViewController: UIViewController
- (instancetype) initWithTitle: (NSString *) title andCompletionBlock: (void (^) (NSString *)) completionBlock;
@end
