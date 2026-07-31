#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSVarCleanViewController.h"
#import "LSSettingsListController.h"
#import "LSUITheme.h"
#import <LSPresentationDelegate.h>

@implementation LSRootViewController {
	UIView *_glassBackground;
	CAGradientLayer *_auroraLayer;
}

- (void)loadView {
	[super loadView];

	LSAppTableViewController* appTableVC = [[LSAppTableViewController alloc] init];
	appTableVC.title = @"Apps";

	LSVarCleanViewController* varCleanVC = [[LSVarCleanViewController alloc] init];
	varCleanVC.title = @"varClean";

	LSSettingsListController* settingsListVC = [[LSSettingsListController alloc] init];
	settingsListVC.title = @"Settings";

	UINavigationController* appNavigationController = [[UINavigationController alloc] initWithRootViewController:appTableVC];
	UINavigationController* varCleanNavigationController = [[UINavigationController alloc] initWithRootViewController:varCleanVC];
	UINavigationController* settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsListVC];
	[LSUITheme applyNavigationAppearance:appNavigationController];
	[LSUITheme applyNavigationAppearance:varCleanNavigationController];
	[LSUITheme applyNavigationAppearance:settingsNavigationController];

	appNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Apps"
		image:[UIImage systemImageNamed:@"square.grid.2x2"] selectedImage:[UIImage systemImageNamed:@"square.grid.2x2.fill"]];
	varCleanNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"varClean"
		image:[UIImage systemImageNamed:@"sparkles"] selectedImage:nil];
	settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
		image:[UIImage systemImageNamed:@"slider.horizontal.3"] selectedImage:nil];
	for (UITabBarItem *item in @[appNavigationController.tabBarItem, varCleanNavigationController.tabBarItem,
		settingsNavigationController.tabBarItem]) {
		item.titlePositionAdjustment = UIOffsetMake(0.0, 4.0);
		item.imageInsets = UIEdgeInsetsMake(4.0, 0.0, -4.0, 0.0);
	}

	self.title = @"LuiseStore";
	self.viewControllers = @[appNavigationController, varCleanNavigationController, settingsNavigationController];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	LSPresentationDelegate.presentationViewController = self;
	[self setupGlassmorphismTabBar];
}

- (void)setupGlassmorphismTabBar {
	if (@available(iOS 13.0, *)) {
		UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
		[appearance configureWithTransparentBackground];
		appearance.shadowColor = UIColor.clearColor;
		appearance.stackedLayoutAppearance.normal.iconColor = LSUITheme.secondaryTextColor;
		appearance.stackedLayoutAppearance.selected.iconColor = LSUITheme.accentColor;
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
			NSForegroundColorAttributeName: LSUITheme.secondaryTextColor,
			NSFontAttributeName: [LSUITheme bodyFontWithSize:10.0 weight:UIFontWeightMedium]
		};
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
			NSForegroundColorAttributeName: LSUITheme.accentColor,
			NSFontAttributeName: [LSUITheme bodyFontWithSize:10.0 weight:UIFontWeightSemibold]
		};
		appearance.inlineLayoutAppearance.normal.iconColor = LSUITheme.secondaryTextColor;
		appearance.inlineLayoutAppearance.selected.iconColor = LSUITheme.accentColor;
		appearance.inlineLayoutAppearance.normal.titleTextAttributes =
			appearance.stackedLayoutAppearance.normal.titleTextAttributes;
		appearance.inlineLayoutAppearance.selected.titleTextAttributes =
			appearance.stackedLayoutAppearance.selected.titleTextAttributes;
		appearance.compactInlineLayoutAppearance.normal.iconColor = LSUITheme.secondaryTextColor;
		appearance.compactInlineLayoutAppearance.selected.iconColor = LSUITheme.accentColor;
		appearance.compactInlineLayoutAppearance.normal.titleTextAttributes =
			appearance.stackedLayoutAppearance.normal.titleTextAttributes;
		appearance.compactInlineLayoutAppearance.selected.titleTextAttributes =
			appearance.stackedLayoutAppearance.selected.titleTextAttributes;
		self.tabBar.standardAppearance = appearance;
		if (@available(iOS 15.0, *)) {
			self.tabBar.scrollEdgeAppearance = appearance;
		}
	}

	self.tabBar.tintColor = LSUITheme.accentColor;
	self.tabBar.unselectedItemTintColor = LSUITheme.secondaryTextColor;
	self.tabBar.backgroundImage = [UIImage new];
	self.tabBar.shadowImage = [UIImage new];
	self.tabBar.clipsToBounds = NO;
	self.tabBar.itemPositioning = UITabBarItemPositioningCentered;

	_glassBackground = [[UIView alloc] init];
	_glassBackground.userInteractionEnabled = NO;
	_glassBackground.accessibilityElementsHidden = YES;
	_glassBackground.layer.cornerRadius = 25.0;
	_glassBackground.layer.cornerCurve = kCACornerCurveContinuous;
	_glassBackground.clipsToBounds = YES;

	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:
		UIAccessibilityIsReduceTransparencyEnabled() ? nil :
		[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]];
	blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_glassBackground addSubview:blurView];

	_glassBackground.layer.borderWidth = 0.5;
	_glassBackground.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.35].CGColor;
	_auroraLayer = [LSUITheme auroraLayerForBounds:CGRectZero];
	[blurView.contentView.layer addSublayer:_auroraLayer];

	self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
	self.tabBar.layer.shadowOffset = CGSizeMake(0, 8);
	self.tabBar.layer.shadowRadius = 18;
	self.tabBar.layer.shadowOpacity = 0.16;

	[self.tabBar insertSubview:_glassBackground atIndex:0];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGFloat sideMargin = 16.0;
	CGFloat itemAreaHeight = CGRectGetHeight(self.tabBar.bounds) - self.view.safeAreaInsets.bottom;
	CGFloat tabBarHeight = MIN(58.0, MAX(49.0, itemAreaHeight));
	CGFloat availableWidth = MAX(0.0, CGRectGetWidth(self.tabBar.bounds) - (sideMargin * 2.0));
	CGFloat glassWidth = MIN(availableWidth, 420.0);
	self.tabBar.itemWidth = floor(glassWidth / MAX(self.tabBar.items.count, 1));
	self.tabBar.itemSpacing = 0.0;
	CGFloat glassY = floor((itemAreaHeight - tabBarHeight) / 2.0) + 4.0;
	_glassBackground.frame = CGRectMake(floor((CGRectGetWidth(self.tabBar.bounds) - glassWidth) / 2.0),
		glassY, glassWidth, tabBarHeight);
	UIVisualEffectView *blurView = _glassBackground.subviews.firstObject;
	blurView.frame = _glassBackground.bounds;
	_glassBackground.backgroundColor = LSUITheme.surfaceColor;
	_auroraLayer.frame = blurView.bounds;
	self.tabBar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_glassBackground.frame cornerRadius:25.0].CGPath;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	_glassBackground.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.35].CGColor;
	_glassBackground.backgroundColor = LSUITheme.surfaceColor;
	[_auroraLayer removeFromSuperlayer];
	_auroraLayer = [LSUITheme auroraLayerForBounds:_glassBackground.bounds];
	UIVisualEffectView *blurView = _glassBackground.subviews.firstObject;
	[blurView.contentView.layer addSublayer:_auroraLayer];
}

@end
