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

	[self _setupFloatingGlassTabBar];
	[self _setupGlassNavigationBars];
}

#pragma mark - Glassmorphism Tab Bar

- (void)_setupFloatingGlassTabBar
{
	UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
	[appearance configureWithTransparentBackground];
	appearance.shadowColor = nil;
	appearance.backgroundColor = [UIColor clearColor];

	self.tabBar.standardAppearance = appearance;
	if (@available(iOS 15.0, *)) {
		self.tabBar.scrollEdgeAppearance = appearance;
	}

	self.tabBar.tintColor = [UIColor whiteColor];
	self.tabBar.unselectedItemTintColor = [UIColor colorWithWhite:1.0 alpha:0.4];
	self.tabBar.backgroundImage = [UIImage new];
	self.tabBar.shadowImage = [UIImage new];
	self.tabBar.clipsToBounds = NO;

	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	blurView.tag = 9999;
	blurView.clipsToBounds = YES;
	blurView.layer.cornerCurve = kCACornerCurveContinuous;
	blurView.layer.borderWidth = 0.5;
	blurView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;

	[self.tabBar insertSubview:blurView atIndex:0];
}

#pragma mark - Glassmorphism Navigation Bars

- (void)_setupGlassNavigationBars
{
	UINavigationBarAppearance *navAppearance = [[UINavigationBarAppearance alloc] init];
	[navAppearance configureWithDefaultBackground];
	navAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
	navAppearance.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
	navAppearance.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.05];
	navAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	navAppearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

	for (UINavigationController *navController in self.viewControllers) {
		navController.navigationBar.standardAppearance = navAppearance;
		navController.navigationBar.scrollEdgeAppearance = navAppearance;
		navController.navigationBar.tintColor = [UIColor whiteColor];
		navController.navigationBar.prefersLargeTitles = YES;
	}
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	CGFloat sideMargin = 40.0;
	CGFloat bottomMargin = 25.0;
	CGFloat tabBarHeight = 64.0;
	CGFloat cornerRadius = tabBarHeight / 2.0;

	self.tabBar.frame = CGRectMake(
		sideMargin,
		self.view.bounds.size.height - tabBarHeight - bottomMargin,
		self.view.bounds.size.width - (sideMargin * 2),
		tabBarHeight
	);

	UIVisualEffectView *blurView = (UIVisualEffectView *)[self.tabBar viewWithTag:9999];
	blurView.frame = self.tabBar.bounds;
	blurView.layer.cornerRadius = cornerRadius;

	self.tabBar.layer.cornerRadius = cornerRadius;
	self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
	self.tabBar.layer.shadowOffset = CGSizeMake(0, 8);
	self.tabBar.layer.shadowRadius = 24;
	self.tabBar.layer.shadowOpacity = 0.4;
	self.tabBar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.tabBar.bounds cornerRadius:cornerRadius].CGPath;
}

@end
