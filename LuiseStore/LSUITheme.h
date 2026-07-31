#import <UIKit/UIKit.h>

@interface LSUITheme : NSObject

+ (UIColor *)backgroundColor;
+ (UIColor *)surfaceColor;
+ (UIColor *)elevatedSurfaceColor;
+ (UIColor *)accentColor;
+ (UIColor *)secondaryAccentColor;
+ (UIColor *)primaryTextColor;
+ (UIColor *)secondaryTextColor;
+ (UIColor *)tertiaryTextColor;
+ (UIFont *)displayFontWithSize:(CGFloat)size weight:(UIFontWeight)weight;
+ (UIFont *)bodyFontWithSize:(CGFloat)size weight:(UIFontWeight)weight;
+ (UIFont *)monoFontWithSize:(CGFloat)size weight:(UIFontWeight)weight;
+ (void)applyNavigationAppearance:(UINavigationController *)navigationController;
+ (void)styleTableView:(UITableView *)tableView;
+ (void)sizeHeaderForTableView:(UITableView *)tableView;
+ (CAGradientLayer *)auroraLayerForBounds:(CGRect)bounds;

@end
