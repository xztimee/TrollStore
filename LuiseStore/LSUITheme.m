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
		[appearance configureWithDefaultBackground];
		appearance.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.82];
		appearance.backgroundEffect = UIAccessibilityIsReduceTransparencyEnabled()
			? nil : [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		appearance.shadowColor = UIColor.clearColor;
		appearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: self.primaryTextColor};
		appearance.titleTextAttributes = @{NSForegroundColorAttributeName: self.primaryTextColor};
		navigationController.navigationBar.standardAppearance = appearance;
		navigationController.navigationBar.scrollEdgeAppearance = appearance;
		navigationController.navigationBar.compactAppearance = appearance;
	}
}

+ (void)styleTableView:(UITableView *)tableView
{
	tableView.backgroundColor = self.backgroundColor;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.contentInset = UIEdgeInsetsMake(8.0, 0.0, 12.0, 0.0);
	tableView.verticalScrollIndicatorInsets = UIEdgeInsetsZero;
	if (@available(iOS 11.0, *)) {
		tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
	}
}

+ (void)sizeHeaderForTableView:(UITableView *)tableView
{
	UIView *header = tableView.tableHeaderView;
	if (!header) return;

	CGFloat width = CGRectGetWidth(tableView.bounds);
	if (width <= 0.0) return;
	header.frame = CGRectMake(0.0, 0.0, width, header.frame.size.height);
	[header setNeedsLayout];
	[header layoutIfNeeded];
	CGFloat height = [header systemLayoutSizeFittingSize:CGSizeMake(width, UILayoutFittingCompressedSize.height)
		withHorizontalFittingPriority:UILayoutPriorityRequired
		verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height;
	if (height <= 0.0 || (fabs(header.frame.size.height - height) < 0.5 &&
		fabs(header.frame.size.width - width) < 0.5)) return;
	header.frame = CGRectMake(0.0, 0.0, width, height);
	tableView.tableHeaderView = header;
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
