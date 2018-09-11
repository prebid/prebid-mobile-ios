#import "AdServerValidationMockInterstitial.h"

@interface AdServerValidationMockInterstitial()
@property UIColor *originalBarColor;
@end
@implementation AdServerValidationMockInterstitial

- (void)viewDidLoad
{
    self.title = @"Expected Creative";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDonePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    _originalBarColor =  self.navigationController.navigationBar.barTintColor;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320)/2, (self.view.bounds.size.height -480)/2 -50, 320, 480 )];
    imageView.image = [UIImage imageNamed:@"320x480"];
    [self.view addSubview:imageView];
}

- (void) btnDonePressed: (id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = _originalBarColor;
}
@end
