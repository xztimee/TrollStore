#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>

@implementation LSRootViewController

- (void)loadView {
	[super loadView];

	LSAppTableViewController* appTableVC = [[LSAppTableViewController alloc] init];
	appTableVC.title = @"Apps";

	LSSettingsListController* settingsListVC = [[LSSettingsListController alloc] init];
	settingsListVC.title = @"Settings";

	UINavigationController* appNavigationController = [[UINavigationController alloc] initWithRootViewController:appTableVC];
	UINavigationController* settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsListVC];
	
	appNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"square.stack.3d.up.fill"];
	settingsNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"gear"];

	self.title = @"Root View Controller";
	self.viewControllers = @[appNavigationController, settingsNavigationController];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	LSPresentationDelegate.presentationViewController = self;
}

@end
