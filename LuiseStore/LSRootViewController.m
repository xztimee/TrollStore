#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>

@implementation LSRootViewController {
	UIView *_glassBackground;
}

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
	[self setupGlassmorphismTabBar];
}

- (void)setupGlassmorphismTabBar {
	// Make default tab bar background fully transparent
	if (@available(iOS 13.0, *)) {
		UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
		[appearance configureWithTransparentBackground];
		appearance.stackedLayoutAppearance.normal.iconColor = [UIColor colorWithWhite:1.0 alpha:0.45];
		appearance.stackedLayoutAppearance.selected.iconColor = [UIColor whiteColor];
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.45]};
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
		self.tabBar.standardAppearance = appearance;
		if (@available(iOS 15.0, *)) {
			self.tabBar.scrollEdgeAppearance = appearance;
		}
	}

	self.tabBar.tintColor = [UIColor whiteColor];
	self.tabBar.clipsToBounds = NO;

	// Glass container with rounded corners
	_glassBackground = [[UIView alloc] init];
	_glassBackground.layer.cornerRadius = 22;
	_glassBackground.clipsToBounds = YES;

	// Blur effect for glassmorphism
	UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
	blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_glassBackground addSubview:blurView];

	// Subtle border for the glass edge
	_glassBackground.layer.borderWidth = 0.5;
	_glassBackground.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;

	// Shadow for depth
	self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
	self.tabBar.layer.shadowOffset = CGSizeMake(0, 4);
	self.tabBar.layer.shadowRadius = 12;
	self.tabBar.layer.shadowOpacity = 0.3;

	[self.tabBar insertSubview:_glassBackground atIndex:0];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGFloat floatMargin = 20;
	CGFloat sideMargin = 16;
	CGFloat safeBottom = self.view.safeAreaInsets.bottom;
	CGFloat tabBarHeight = 50;

	// Reposition the tab bar to float above the bottom
	CGRect tabFrame = self.tabBar.frame;
	tabFrame.size.height = tabBarHeight;
	tabFrame.origin.y = self.view.frame.size.height - tabBarHeight - floatMargin - safeBottom;
	self.tabBar.frame = tabFrame;

	// Position glass background with side margins, filling the entire tab bar
	_glassBackground.frame = CGRectMake(sideMargin, 0, tabFrame.size.width - sideMargin * 2, tabBarHeight);
	UIVisualEffectView *blurView = _glassBackground.subviews.firstObject;
	blurView.frame = _glassBackground.bounds;
}

@end
