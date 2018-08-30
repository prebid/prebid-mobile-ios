
#import "KVViewController.h"
#import "ColorTool.h"

@interface KVViewController ()

@end

@implementation KVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Key-Value Targeting";
    self.view.backgroundColor = [ColorTool prebidGrey];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 40)];
    titleLabel.text = @"Prebid Key-Value Pairs";
    [self.view addSubview:titleLabel];
    
    if(self.keyWordsDictionary != nil){
        
        NSString *dictString = [NSString stringWithFormat:@"%@", self.keyWordsDictionary];
        
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
        NSString *requiredString = [[dictString componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
        UITextView *contentLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, 400)];
        contentLabel.text = requiredString;
        contentLabel.editable = NO;
        [self.view addSubview:contentLabel];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
