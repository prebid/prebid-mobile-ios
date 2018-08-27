#import "AdServerValidationMockInterstitial.h"

@interface AdServerValidationMockInterstitial()
@end
@implementation AdServerValidationMockInterstitial

- (void)viewDidLoad
{
    self.title = @"Test Creative";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDonePressed:)];
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320)/2, (self.view.frame.size.height -480)/2, 320, 480 )];
    imageView.image = [UIImage imageNamed:@"320x480"];
    [self.view addSubview:imageView];
}

- (void) btnDonePressed: (id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
@end
