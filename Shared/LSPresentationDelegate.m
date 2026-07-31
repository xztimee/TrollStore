#import "LSPresentationDelegate.h"
#import <objc/runtime.h>

@implementation LSPresentationDelegate

static UIViewController* g_presentationViewController;
static UIViewController* g_activityController;

+ (UIViewController*)presentationViewController
{
	return g_presentationViewController;
}

+ (void)setPresentationViewController:(UIViewController*)vc
{
	g_presentationViewController = vc;
}

+ (UIViewController*)activityController
{
	return g_activityController;
}

+ (void)setActivityController:(UIViewController*)ac
{
	g_activityController = ac;
}

+ (void)startActivity:(NSString*)activity withCancelHandler:(void (^)(void))cancelHandler
{
	if (!self.presentationViewController) return;
	if(self.activityController)
	{
		UILabel *titleLabel = [self.activityController.view viewWithTag:1001];
		if ([titleLabel isKindOfClass:UILabel.class]) {
			titleLabel.text = activity;
		}
	}
	else
	{
		UIViewController *activityController = [[UIViewController alloc] init];
		activityController.modalPresentationStyle = UIModalPresentationOverFullScreen;
		activityController.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.18];

		UIVisualEffectView *card = [[UIVisualEffectView alloc] initWithEffect:
			UIAccessibilityIsReduceTransparencyEnabled() ? nil :
			[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
		card.translatesAutoresizingMaskIntoConstraints = NO;
		card.backgroundColor = UIAccessibilityIsReduceTransparencyEnabled() ? UIColor.secondarySystemBackgroundColor : UIColor.clearColor;
		card.layer.cornerRadius = 20.0;
		card.layer.cornerCurve = kCACornerCurveContinuous;
		card.clipsToBounds = YES;
		card.layer.borderWidth = 0.5;
		card.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.35].CGColor;
		[activityController.view addSubview:card];

		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
		activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
		activityIndicator.color = UIColor.systemIndigoColor;
		[activityIndicator startAnimating];
		[card.contentView addSubview:activityIndicator];

		UILabel *titleLabel = [[UILabel alloc] init];
		titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		titleLabel.tag = 1001;
		titleLabel.text = activity;
		titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
		titleLabel.textColor = UIColor.labelColor;
		titleLabel.adjustsFontForContentSizeCategory = YES;
		titleLabel.numberOfLines = 2;
		[card.contentView addSubview:titleLabel];

		[NSLayoutConstraint activateConstraints:@[
			[card.centerXAnchor constraintEqualToAnchor:activityController.view.centerXAnchor],
			[card.centerYAnchor constraintEqualToAnchor:activityController.view.centerYAnchor],
			[card.widthAnchor constraintGreaterThanOrEqualToConstant:190.0],
			[card.leadingAnchor constraintGreaterThanOrEqualToAnchor:activityController.view.leadingAnchor constant:30.0],
			[card.trailingAnchor constraintLessThanOrEqualToAnchor:activityController.view.trailingAnchor constant:-30.0],
			[card.heightAnchor constraintGreaterThanOrEqualToConstant:78.0],
			[activityIndicator.leadingAnchor constraintEqualToAnchor:card.contentView.leadingAnchor constant:20.0],
			[activityIndicator.centerYAnchor constraintEqualToAnchor:card.contentView.centerYAnchor],
			[titleLabel.leadingAnchor constraintEqualToAnchor:activityIndicator.trailingAnchor constant:13.0],
			[titleLabel.trailingAnchor constraintEqualToAnchor:card.contentView.trailingAnchor constant:-20.0],
			[titleLabel.topAnchor constraintEqualToAnchor:card.contentView.topAnchor constant:16.0],
			[titleLabel.bottomAnchor constraintEqualToAnchor:card.contentView.bottomAnchor constant:-16.0]
		]];

		self.activityController = activityController;

		if(cancelHandler)
		{
			UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
			cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
			[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
			cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
			[cancelButton setTitleColor:UIColor.systemIndigoColor forState:UIControlStateNormal];
			[cancelButton addTarget:self action:@selector(cancelActivityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			objc_setAssociatedObject(cancelButton, @selector(cancelActivityButtonPressed:), cancelHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
			[activityController.view addSubview:cancelButton];
			[NSLayoutConstraint activateConstraints:@[
				[cancelButton.centerXAnchor constraintEqualToAnchor:activityController.view.centerXAnchor],
				[cancelButton.topAnchor constraintEqualToAnchor:card.bottomAnchor constant:16.0],
				[cancelButton.heightAnchor constraintGreaterThanOrEqualToConstant:44.0]
			]];
		}

		[self presentViewController:activityController animated:YES completion:nil];
	}
}

+ (void)cancelActivityButtonPressed:(UIButton *)button
{
	void (^cancelHandler)(void) = objc_getAssociatedObject(button, @selector(cancelActivityButtonPressed:));
	UIViewController *activityController = self.activityController;
	self.activityController = nil;
	[activityController dismissViewControllerAnimated:YES completion:nil];
	if (cancelHandler) cancelHandler();
}

+ (void)startActivity:(NSString*)activity
{
	[self startActivity:activity withCancelHandler:nil];
}

+ (void)stopActivityWithCompletion:(void (^)(void))completionBlock
{
	if(!self.activityController) return;

	[self.activityController dismissViewControllerAnimated:YES completion:^
	{
		self.activityController = nil;
		if(completionBlock) completionBlock();
	}];
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completionBlock
{
	UIViewController *presenter = self.presentationViewController;
	while (presenter.presentedViewController && !presenter.presentedViewController.isBeingDismissed) {
		presenter = presenter.presentedViewController;
	}
	[presenter presentViewController:viewControllerToPresent animated:flag completion:completionBlock];
}

@end