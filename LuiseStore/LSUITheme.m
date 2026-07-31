#import "LSUITheme.h"

@implementation LSUITheme

+ (UIColor *)dynamicColor:(UIColor *)light dark:(UIColor *)dark
{
	return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
		return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light;
	}];
}

+ (UIColor *)backgroundColor
{
	return [self dynamicColor:[UIColor colorWithRed:0.96 green:0.97 blue:1.0 alpha:1.0]
		dark:[UIColor colorWithRed:0.04 green:0.06 blue:0.13 alpha:1.0]];
}

+ (UIColor *)surfaceColor
{
	return [self dynamicColor:[UIColor colorWithWhite:1.0 alpha:0.76]
		dark:[UIColor colorWithWhite:1.0 alpha:0.08]];
}

+ (UIColor *)elevatedSurfaceColor
{
	return [self dynamicColor:[UIColor colorWithWhite:1.0 alpha:0.92]
		dark:[UIColor colorWithWhite:1.0 alpha:0.13]];
}

+ (UIColor *)accentColor
{
	return [UIColor colorWithRed:0.33 green:0.47 blue:1.0 alpha:1.0];
}

+ (UIColor *)secondaryAccentColor
{
	return [UIColor colorWithRed:0.60 green:0.42 blue:1.0 alpha:1.0];
}

+ (UIColor *)primaryTextColor
{
	return [UIColor labelColor];
}

+ (UIColor *)secondaryTextColor
{
	return [UIColor secondaryLabelColor];
}

+ (UIColor *)tertiaryTextColor
{
	return [UIColor tertiaryLabelColor];
}

+ (UIFont *)displayFontWithSize:(CGFloat)size weight:(UIFontWeight)weight
{
	if (@available(iOS 13.0, *)) {
		UIFont *font = [UIFont systemFontOfSize:size weight:weight];
		UIFontDescriptor *roundedDescriptor = [font.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
		return roundedDescriptor ? [UIFont fontWithDescriptor:roundedDescriptor size:size] : font;
	}
	return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)bodyFontWithSize:(CGFloat)size weight:(UIFontWeight)weight
{
	if (@available(iOS 13.0, *)) {
		return [UIFont systemFontOfSize:size weight:weight];
	}
	return weight >= UIFontWeightSemibold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
}

+ (UIFont *)monoFontWithSize:(CGFloat)size weight:(UIFontWeight)weight
{
	if (@available(iOS 13.0, *)) {
		return [UIFont monospacedSystemFontOfSize:size weight:weight];
	}
	return [UIFont systemFontOfSize:size];
}

+ (void)applyNavigationAppearance:(UINavigationController *)navigationController
{
	navigationController.navigationBar.tintColor = self.accentColor;
	navigationController.navigationBar.prefersLargeTitles = YES;

	if (@available(iOS 13.0, *)) {
		UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
		[appearance configureWithTransparentBackground];
		appearance.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.82];
		appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		appearance.shadowColor = UIColor.clearColor;
		appearance.largeTitleTextAttributes = @{
			NSFontAttributeName: [self displayFontWithSize:34.0 weight:UIFontWeightBold],
			NSForegroundColorAttributeName: self.primaryTextColor
		};
		appearance.titleTextAttributes = @{
			NSFontAttributeName: [self bodyFontWithSize:17.0 weight:UIFontWeightSemibold],
			NSForegroundColorAttributeName: self.primaryTextColor
		};
		navigationController.navigationBar.standardAppearance = appearance;
		navigationController.navigationBar.scrollEdgeAppearance = appearance;
		if (@available(iOS 15.0, *)) {
			navigationController.navigationBar.compactAppearance = appearance;
		}
	}
}

+ (void)styleTableView:(UITableView *)tableView
{
	tableView.backgroundColor = self.backgroundColor;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.contentInset = UIEdgeInsetsMake(8.0, 0.0, 96.0, 0.0);
	tableView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 88.0, 0.0);
	if (@available(iOS 11.0, *)) {
		tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
	}
}

+ (CAGradientLayer *)auroraLayerForBounds:(CGRect)bounds
{
	CAGradientLayer *layer = [CAGradientLayer layer];
	layer.frame = bounds;
	layer.colors = @[
		(id)[self.accentColor colorWithAlphaComponent:0.18].CGColor,
		(id)[self.secondaryAccentColor colorWithAlphaComponent:0.12].CGColor,
		(id)[UIColor clearColor].CGColor
	];
	layer.locations = @[@0.0, @0.42, @1.0];
	layer.startPoint = CGPointMake(0.0, 0.0);
	layer.endPoint = CGPointMake(1.0, 1.0);
	return layer;
}

@end
