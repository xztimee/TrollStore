#import "LSAppTableViewController.h"

#import "LSApplicationsManager.h"
#import <LSPresentationDelegate.h>
#import "LSInstallationController.h"
#import "LSUtil.h"
#import "LSUITheme.h"
@import UniformTypeIdentifiers;

#define ICON_FORMAT_IPAD 8
#define ICON_FORMAT_IPHONE 10

NSInteger iconFormatToUse(void)
{
	if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		return ICON_FORMAT_IPAD;
	}
	else
	{
		return ICON_FORMAT_IPHONE;
	}
}

UIImage* imageWithSize(UIImage* image, CGSize size)
{
	if(CGSizeEqualToSize(image.size, size)) return image;
	UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
	CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
	[image drawInRect:imageRect];
	UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return outImage;
}

@interface UIImage ()
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)id format:(NSInteger)format scale:(double)scale;
@end

@interface LSAppCell : UITableViewCell
@property (nonatomic, readonly) UIImageView *appIconView;
@property (nonatomic, copy) NSString *representedBundleIdentifier;
- (void)configureWithAppInfo:(LSAppInfo *)appInfo icon:(UIImage *)icon;
@end

@implementation LSAppCell {
	UIView *_cardView;
	UILabel *_nameLabel;
	UILabel *_versionLabel;
	UILabel *_bundleLabel;
	UILabel *_registrationLabel;
	UIImageView *_chevronView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (!self) return nil;

	self.backgroundColor = UIColor.clearColor;
	self.selectionStyle = UITableViewCellSelectionStyleNone;

	_cardView = [[UIView alloc] init];
	_cardView.translatesAutoresizingMaskIntoConstraints = NO;
	_cardView.backgroundColor = LSUITheme.surfaceColor;
	_cardView.layer.cornerRadius = 18.0;
	_cardView.layer.cornerCurve = kCACornerCurveContinuous;
	_cardView.layer.borderWidth = 0.5;
	_cardView.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.28].CGColor;
	[self.contentView addSubview:_cardView];

	_appIconView = [[UIImageView alloc] init];
	_appIconView.translatesAutoresizingMaskIntoConstraints = NO;
	_appIconView.contentMode = UIViewContentModeScaleAspectFill;
	[_appIconView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	_appIconView.layer.cornerRadius = 14.0;
	_appIconView.layer.cornerCurve = kCACornerCurveContinuous;
	_appIconView.layer.borderWidth = 0.5;
	_appIconView.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.25].CGColor;
	_appIconView.clipsToBounds = YES;
	[_cardView addSubview:_appIconView];

	_nameLabel = [[UILabel alloc] init];
	_nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_nameLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline]
		scaledFontForFont:[LSUITheme bodyFontWithSize:16.0 weight:UIFontWeightSemibold]];
	_nameLabel.adjustsFontForContentSizeCategory = YES;
	_nameLabel.numberOfLines = 1;
	_nameLabel.textColor = LSUITheme.primaryTextColor;
	_nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	[_cardView addSubview:_nameLabel];

	_versionLabel = [[UILabel alloc] init];
	_versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_versionLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption1]
		scaledFontForFont:[LSUITheme bodyFontWithSize:12.0 weight:UIFontWeightMedium]];
	_versionLabel.adjustsFontForContentSizeCategory = YES;
	_versionLabel.numberOfLines = 1;
	_versionLabel.textColor = LSUITheme.secondaryTextColor;
	[_cardView addSubview:_versionLabel];

	_bundleLabel = [[UILabel alloc] init];
	_bundleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_bundleLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption2]
		scaledFontForFont:[LSUITheme monoFontWithSize:11.0 weight:UIFontWeightRegular]];
	_bundleLabel.adjustsFontForContentSizeCategory = YES;
	_bundleLabel.numberOfLines = 1;
	_bundleLabel.textColor = LSUITheme.tertiaryTextColor;
	_bundleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	[_bundleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	[_cardView addSubview:_bundleLabel];

	_registrationLabel = [[UILabel alloc] init];
	_registrationLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_registrationLabel.font = [LSUITheme monoFontWithSize:10.0 weight:UIFontWeightSemibold];
	_registrationLabel.adjustsFontSizeToFitWidth = YES;
	_registrationLabel.minimumScaleFactor = 0.8;
	_registrationLabel.adjustsFontForContentSizeCategory = NO;
	_registrationLabel.textAlignment = NSTextAlignmentCenter;
	_registrationLabel.layer.cornerRadius = 8.0;
	_registrationLabel.layer.cornerCurve = kCACornerCurveContinuous;
	_registrationLabel.clipsToBounds = YES;
	[_registrationLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	[_registrationLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	[_cardView addSubview:_registrationLabel];

	_chevronView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
	_chevronView.translatesAutoresizingMaskIntoConstraints = NO;
	_chevronView.tintColor = LSUITheme.tertiaryTextColor;
	_chevronView.contentMode = UIViewContentModeScaleAspectFit;
	[_chevronView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	[_cardView addSubview:_chevronView];

	NSLayoutConstraint *preferredCardWidth = [_cardView.widthAnchor
		constraintEqualToAnchor:self.contentView.widthAnchor constant:-32.0];
	preferredCardWidth.priority = UILayoutPriorityDefaultHigh;
	[NSLayoutConstraint activateConstraints:@[
		[_cardView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
		[_cardView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
		[_cardView.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
		[_cardView.widthAnchor constraintLessThanOrEqualToConstant:680.0],
		preferredCardWidth,
		[_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5.0],
		[_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5.0],
		[_appIconView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:14.0],
		[_appIconView.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:14.0],
		[_appIconView.widthAnchor constraintEqualToConstant:54.0],
		[_appIconView.heightAnchor constraintEqualToConstant:54.0],
		[_nameLabel.leadingAnchor constraintEqualToAnchor:_appIconView.trailingAnchor constant:13.0],
		[_nameLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:13.0],
		[_nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_registrationLabel.leadingAnchor constant:-8.0],
		[_registrationLabel.centerYAnchor constraintEqualToAnchor:_nameLabel.centerYAnchor],
		[_registrationLabel.trailingAnchor constraintEqualToAnchor:_chevronView.leadingAnchor constant:-9.0],
		[_registrationLabel.widthAnchor constraintGreaterThanOrEqualToConstant:50.0],
		[_registrationLabel.heightAnchor constraintEqualToConstant:20.0],
		[_chevronView.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-13.0],
		[_chevronView.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
		[_chevronView.widthAnchor constraintEqualToConstant:7.0],
		[_versionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
		[_versionLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:2.0],
		[_bundleLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
		[_bundleLabel.topAnchor constraintEqualToAnchor:_versionLabel.bottomAnchor constant:1.0],
		[_bundleLabel.trailingAnchor constraintEqualToAnchor:_chevronView.leadingAnchor constant:-12.0],
		[_bundleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:_cardView.bottomAnchor constant:-10.0]
	]];

	return self;
}

- (void)configureWithAppInfo:(LSAppInfo *)appInfo icon:(UIImage *)icon
{
	NSString *appName = appInfo.displayName ?: @"Unknown App";
	NSString *version = appInfo.versionString ?: @"Unknown version";
	NSString *bundleIdentifier = appInfo.bundleIdentifier ?: @"Bundle ID unavailable";
	NSString *registration = appInfo.registrationState ?: @"Unknown";

	_nameLabel.text = appName;
	_versionLabel.text = [NSString stringWithFormat:@"Version %@", version];
	_bundleLabel.text = bundleIdentifier;
	_registrationLabel.text = [NSString stringWithFormat:@" %@ ", registration.uppercaseString];
	_appIconView.image = icon;
	self.representedBundleIdentifier = appInfo.bundleIdentifier;

	BOOL isSystem = [registration isEqualToString:@"System"];
	UIColor *statusColor = isSystem ? UIColor.systemGreenColor : UIColor.systemOrangeColor;
	_registrationLabel.textColor = statusColor;
	_registrationLabel.backgroundColor = [statusColor colorWithAlphaComponent:0.13];

	self.isAccessibilityElement = YES;
	self.accessibilityTraits = UIAccessibilityTraitButton;
	self.accessibilityLabel = appName;
	self.accessibilityValue = [NSString stringWithFormat:@"Version %@, %@, %@ registration", version, bundleIdentifier, registration];
	self.accessibilityHint = @"Shows app actions";
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[UIView animateWithDuration:animated ? 0.15 : 0.0 animations:^{
		self->_cardView.transform = highlighted ? CGAffineTransformMakeScale(0.98, 0.98) : CGAffineTransformIdentity;
		self->_cardView.alpha = highlighted ? 0.78 : 1.0;
	}];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	_cardView.backgroundColor = LSUITheme.surfaceColor;
	_cardView.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.28].CGColor;
	_appIconView.layer.borderColor = [UIColor.separatorColor colorWithAlphaComponent:0.25].CGColor;
}

@end

@implementation LSAppTableViewController

- (void)loadAppInfos
{
	NSArray* appPaths = [[LSApplicationsManager sharedInstance] installedAppPaths];
	NSMutableArray<LSAppInfo*>* appInfos = [NSMutableArray new];

	for(NSString* appPath in appPaths)
	{
		LSAppInfo* appInfo = [[LSAppInfo alloc] initWithAppBundlePath:appPath];
		[appInfo sync_loadBasicInfo];
		[appInfos addObject:appInfo];
	}

	if(_searchKey && ![_searchKey isEqualToString:@""])
	{
		[appInfos enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(LSAppInfo* appInfo, NSUInteger idx, BOOL* stop)
		{
			NSString* appName = [appInfo displayName];
			BOOL nameMatch = [appName rangeOfString:_searchKey options:NSCaseInsensitiveSearch range:NSMakeRange(0, [appName length]) locale:[NSLocale currentLocale]].location != NSNotFound;
			if(!nameMatch)
			{
				[appInfos removeObjectAtIndex:idx];
			}
		}];
	}

	[appInfos sortUsingComparator:^(LSAppInfo* appInfoA, LSAppInfo* appInfoB)
	{
		return [[appInfoA displayName] localizedStandardCompare:[appInfoB displayName]];
	}];

	_cachedAppInfos = appInfos.copy;
}

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		[self loadAppInfos];
		_placeholderIcon = [UIImage _applicationIconImageForBundleIdentifier:@"com.apple.WebSheet" format:iconFormatToUse() scale:[UIScreen mainScreen].scale];
		_cachedIcons = [NSMutableDictionary new];
		[[LSApplicationWorkspace defaultWorkspace] addObserver:self];
	}
	return self;
}

- (void)dealloc
{
	[[LSApplicationWorkspace defaultWorkspace] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadTable
{
	[self loadAppInfos];
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.tableView reloadData];
		[self updateLibraryState];
	});
}

- (void)loadView
{
	[super loadView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ApplicationsChanged" object:nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.allowsMultipleSelectionDuringEditing = NO;
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 78.0;
	[LSUITheme styleTableView:self.tableView];
	[self.tableView registerClass:LSAppCell.class forCellReuseIdentifier:@"ApplicationCell"];

	[self _setUpNavigationBar];
	[self _setUpSearchBar];
	[self _setUpLibraryHeader];
	[self _setUpEmptyState];
	[self updateLibraryState];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChange:)
		name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)_setUpLibraryHeader
{
	_libraryHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 1.0)];
	_libraryHeaderView.backgroundColor = UIColor.clearColor;

	UILabel *eyebrowLabel = [[UILabel alloc] init];
	eyebrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
	eyebrowLabel.text = @"PERMASIGNED LIBRARY";
	eyebrowLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption2]
		scaledFontForFont:[LSUITheme monoFontWithSize:11.0 weight:UIFontWeightSemibold]];
	eyebrowLabel.adjustsFontForContentSizeCategory = YES;
	eyebrowLabel.textColor = LSUITheme.accentColor;
	eyebrowLabel.accessibilityElementsHidden = YES;
	[_libraryHeaderView addSubview:eyebrowLabel];

	_libraryCountLabel = [[UILabel alloc] init];
	_libraryCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_libraryCountLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleSubheadline]
		scaledFontForFont:[LSUITheme bodyFontWithSize:14.0 weight:UIFontWeightRegular]];
	_libraryCountLabel.adjustsFontForContentSizeCategory = YES;
	_libraryCountLabel.numberOfLines = 1;
	_libraryCountLabel.textColor = LSUITheme.secondaryTextColor;
	[_libraryHeaderView addSubview:_libraryCountLabel];

	UIView *auroraLine = [[UIView alloc] init];
	auroraLine.translatesAutoresizingMaskIntoConstraints = NO;
	auroraLine.backgroundColor = LSUITheme.accentColor;
	auroraLine.layer.cornerRadius = 1.5;
	[_libraryHeaderView addSubview:auroraLine];

	[NSLayoutConstraint activateConstraints:@[
		[auroraLine.leadingAnchor constraintEqualToAnchor:_libraryHeaderView.readableContentGuide.leadingAnchor],
		[auroraLine.topAnchor constraintEqualToAnchor:_libraryHeaderView.topAnchor constant:12.0],
		[auroraLine.widthAnchor constraintEqualToConstant:28.0],
		[auroraLine.heightAnchor constraintEqualToConstant:3.0],
		[eyebrowLabel.leadingAnchor constraintEqualToAnchor:auroraLine.leadingAnchor],
		[eyebrowLabel.topAnchor constraintEqualToAnchor:auroraLine.bottomAnchor constant:8.0],
		[_libraryCountLabel.leadingAnchor constraintEqualToAnchor:eyebrowLabel.leadingAnchor],
		[_libraryCountLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_libraryHeaderView.readableContentGuide.trailingAnchor],
		[_libraryCountLabel.topAnchor constraintEqualToAnchor:eyebrowLabel.bottomAnchor constant:3.0],
		[_libraryCountLabel.bottomAnchor constraintEqualToAnchor:_libraryHeaderView.bottomAnchor constant:-12.0]
	]];

	self.tableView.tableHeaderView = _libraryHeaderView;
	[LSUITheme sizeHeaderForTableView:self.tableView];
}

- (void)_setUpEmptyState
{
	_emptyStateView = [[UIView alloc] initWithFrame:self.tableView.bounds];
	_emptyStateView.backgroundColor = UIColor.clearColor;

	UIImageView *symbolView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"square.stack.3d.up.slash"]];
	symbolView.translatesAutoresizingMaskIntoConstraints = NO;
	symbolView.tintColor = [LSUITheme.accentColor colorWithAlphaComponent:0.72];
	symbolView.preferredSymbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:44.0 weight:UIImageSymbolWeightLight];
	[_emptyStateView addSubview:symbolView];

	_emptyTitleLabel = [[UILabel alloc] init];
	_emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_emptyTitleLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleTitle2]
		scaledFontForFont:[LSUITheme displayFontWithSize:22.0 weight:UIFontWeightBold]];
	_emptyTitleLabel.adjustsFontForContentSizeCategory = YES;
	_emptyTitleLabel.textColor = LSUITheme.primaryTextColor;
	_emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
	_emptyTitleLabel.numberOfLines = 0;
	[_emptyStateView addSubview:_emptyTitleLabel];

	_emptyMessageLabel = [[UILabel alloc] init];
	_emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_emptyMessageLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
		scaledFontForFont:[LSUITheme bodyFontWithSize:15.0 weight:UIFontWeightRegular]];
	_emptyMessageLabel.adjustsFontForContentSizeCategory = YES;
	_emptyMessageLabel.textColor = LSUITheme.secondaryTextColor;
	_emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
	_emptyMessageLabel.numberOfLines = 0;
	[_emptyStateView addSubview:_emptyMessageLabel];

	[NSLayoutConstraint activateConstraints:@[
		[symbolView.centerXAnchor constraintEqualToAnchor:_emptyStateView.centerXAnchor],
		[symbolView.centerYAnchor constraintEqualToAnchor:_emptyStateView.centerYAnchor constant:-55.0],
		[symbolView.widthAnchor constraintEqualToConstant:56.0],
		[symbolView.heightAnchor constraintEqualToConstant:56.0],
		[_emptyTitleLabel.topAnchor constraintEqualToAnchor:symbolView.bottomAnchor constant:18.0],
		[_emptyTitleLabel.leadingAnchor constraintEqualToAnchor:_emptyStateView.leadingAnchor constant:30.0],
		[_emptyTitleLabel.trailingAnchor constraintEqualToAnchor:_emptyStateView.trailingAnchor constant:-30.0],
		[_emptyMessageLabel.topAnchor constraintEqualToAnchor:_emptyTitleLabel.bottomAnchor constant:8.0],
		[_emptyMessageLabel.leadingAnchor constraintEqualToAnchor:_emptyStateView.leadingAnchor constant:36.0],
		[_emptyMessageLabel.trailingAnchor constraintEqualToAnchor:_emptyStateView.trailingAnchor constant:-36.0]
	]];
}

- (void)updateLibraryState
{
	BOOL isSearching = _searchKey.length > 0;
	NSUInteger count = _cachedAppInfos.count;
	if (!_libraryCountLabel || !_emptyTitleLabel || !_emptyMessageLabel) return;
	_libraryCountLabel.text = isSearching
		? [NSString stringWithFormat:@"%lu match%@", (unsigned long)count, count == 1 ? @"" : @"es"]
		: [NSString stringWithFormat:@"%lu installed app%@", (unsigned long)count, count == 1 ? @"" : @"s"];

	if (count == 0) {
		_emptyTitleLabel.text = isSearching ? @"No matches" : @"Your library is empty";
		_emptyMessageLabel.text = isSearching
			? @"Try another app name."
			: @"Use the plus button to install an IPA file or add one from a URL.";
		self.tableView.backgroundView = _emptyStateView;
	} else {
		self.tableView.backgroundView = nil;
	}
}

- (void)_setUpNavigationBar
{
	UIAction* installFromFileAction = [UIAction actionWithTitle:@"Install IPA File" image:[UIImage systemImageNamed:@"doc.badge.plus"] identifier:@"InstallIPAFile" handler:^(__kindof UIAction *action)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			UTType* ipaType = [UTType typeWithFilenameExtension:@"ipa" conformingToType:UTTypeData];
			UTType* tipaType = [UTType typeWithFilenameExtension:@"tipa" conformingToType:UTTypeData];

			UIDocumentPickerViewController* documentPickerVC = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[ipaType, tipaType]];
			documentPickerVC.allowsMultipleSelection = NO;
			documentPickerVC.delegate = self;

			[LSPresentationDelegate presentViewController:documentPickerVC animated:YES completion:nil];
		});
	}];

	UIAction* installFromURLAction = [UIAction actionWithTitle:@"Install from URL" image:[UIImage systemImageNamed:@"link.badge.plus"] identifier:@"InstallFromURL" handler:^(__kindof UIAction *action)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			UIAlertController* installURLController = [UIAlertController alertControllerWithTitle:@"Install from URL" message:@"" preferredStyle:UIAlertControllerStyleAlert];

			[installURLController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
				textField.placeholder = @"URL";
			}];

			UIAlertAction* installAction = [UIAlertAction actionWithTitle:@"Install" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
			{
				NSString* URLString = installURLController.textFields.firstObject.text;
				NSURL* remoteURL = [NSURL URLWithString:URLString];

				[LSInstallationController handleAppInstallFromRemoteURL:remoteURL completion:nil];
			}];
			[installURLController addAction:installAction];

			UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
			[installURLController addAction:cancelAction];

			[LSPresentationDelegate presentViewController:installURLController animated:YES completion:nil];
		});
	}];

	UIMenu* installMenu = [UIMenu menuWithChildren:@[installFromFileAction, installFromURLAction]];

	UIBarButtonItem* installBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] menu:installMenu];
	
	self.navigationItem.rightBarButtonItems = @[installBarButtonItem];
}

- (void)_setUpSearchBar
{
	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	_searchController.searchResultsUpdater = self;
	_searchController.obscuresBackgroundDuringPresentation = NO;
	_searchController.searchBar.placeholder = @"Search apps";
	_searchController.searchBar.tintColor = LSUITheme.accentColor;
	self.navigationItem.searchController = _searchController;
	self.navigationItem.hidesSearchBarWhenScrolling = YES;
	self.definesPresentationContext = YES;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[LSUITheme sizeHeaderForTableView:self.tableView];
	_emptyStateView.frame = self.tableView.bounds;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	[LSUITheme sizeHeaderForTableView:self.tableView];
	[self.tableView reloadData];
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
	[LSUITheme sizeHeaderForTableView:self.tableView];
	[self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		_searchKey = searchController.searchBar.text;
		[self reloadTable];
	});
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
	NSString* pathToIPA = urls.firstObject.path;
	[LSInstallationController presentInstallationAlertIfEnabledForFile:pathToIPA isRemoteInstall:NO completion:nil];
}

- (void)openAppPressedForRowAtIndexPath:(NSIndexPath*)indexPath enableJIT:(BOOL)enableJIT
{
	LSApplicationsManager* appsManager = [LSApplicationsManager sharedInstance];

	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];
	NSString* appId = [appInfo bundleIdentifier];
	BOOL didOpen = [appsManager openApplicationWithBundleID:appId];

	// if we failed to open the app, show an alert
	if(!didOpen)
	{
		NSString* failMessage = @"";
		if([[appInfo registrationState] isEqualToString:@"User"])
		{
			failMessage = @"This app was not able to launch because it has a \"User\" registration state, register it as \"System\" and try again.";
		}

		NSString* failTitle = [NSString stringWithFormat:@"Failed to open %@", appId];
		UIAlertController* didFailController = [UIAlertController alertControllerWithTitle:failTitle message:failMessage preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

		[didFailController addAction:cancelAction];
		[LSPresentationDelegate presentViewController:didFailController animated:YES completion:nil];
	}
	else if (enableJIT)
	{
		int ret = [appsManager enableJITForBundleID:appId];
		if (ret != 0)
		{
			UIAlertController* errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Error enabling JIT: luisestorehelper returned %d", ret] preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
			[errorAlert addAction:closeAction];
			[LSPresentationDelegate presentViewController:errorAlert animated:YES completion:nil];
		}
	}
}

- (void)showDetailsPressedForRowAtIndexPath:(NSIndexPath*)indexPath
{
	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];

	[appInfo loadInfoWithCompletion:^(NSError* error)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if(!error)
			{
				UIAlertController* detailsAlert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
				detailsAlert.attributedTitle = [appInfo detailedInfoTitle];
				detailsAlert.attributedMessage = [appInfo detailedInfoDescription];

				UIAlertAction* closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
				[detailsAlert addAction:closeAction];

				[LSPresentationDelegate presentViewController:detailsAlert animated:YES completion:nil];
			}
			else
			{
				UIAlertController* errorAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Parse Error %ld", error.code] message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
				[errorAlert addAction:closeAction];

				[LSPresentationDelegate presentViewController:errorAlert animated:YES completion:nil];
			}
		});
	}];
}

- (void)changeAppRegistrationForRowAtIndexPath:(NSIndexPath*)indexPath toState:(NSString*)newState
{
	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];

	if([newState isEqualToString:@"User"])
	{
		NSString* title = [NSString stringWithFormat:@"Switching '%@' to \"User\" Registration", [appInfo displayName]];
		UIAlertController* confirmationAlert = [UIAlertController alertControllerWithTitle:title message:@"Switching this app to a \"User\" registration will make it unlaunchable after the next respring because the bugs exploited in LuiseStore only affect apps registered as \"System\".\nThe purpose of this option is to make the app temporarily show up in settings, so you can adjust the settings and then switch it back to a \"System\" registration (LuiseStore installed apps do not show up in settings otherwise). Additionally, the \"User\" registration state is also useful to temporarily fix iTunes file sharing, which also doesn't work for LuiseStore installed apps otherwise.\nWhen you're done making the changes you need and want the app to become launchable again, you will need to switch it back to \"System\" state in LuiseStore." preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* switchToUserAction = [UIAlertAction actionWithTitle:@"Switch to \"User\"" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action)
		{
			[[LSApplicationsManager sharedInstance] changeAppRegistration:[appInfo bundlePath] toState:newState];
			[appInfo sync_loadBasicInfo];
		}];

		[confirmationAlert addAction:switchToUserAction];

		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

		[confirmationAlert addAction:cancelAction];

		[LSPresentationDelegate presentViewController:confirmationAlert animated:YES completion:nil];
	}
	else
	{
		[[LSApplicationsManager sharedInstance] changeAppRegistration:[appInfo bundlePath] toState:newState];
		[appInfo sync_loadBasicInfo];

		NSString* title = [NSString stringWithFormat:@"Switched '%@' to \"System\" Registration", [appInfo displayName]];

		UIAlertController* infoAlert = [UIAlertController alertControllerWithTitle:title message:@"The app has been switched to the \"System\" registration state and will become launchable again after a respring." preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
		{
			respring();
		}];

		[infoAlert addAction:respringAction];

		UIAlertAction* closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];

		[infoAlert addAction:closeAction];

		[LSPresentationDelegate presentViewController:infoAlert animated:YES completion:nil];
	}
}

- (void)uninstallPressedForRowAtIndexPath:(NSIndexPath*)indexPath
{
	LSApplicationsManager* appsManager = [LSApplicationsManager sharedInstance];

	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];

	NSString* appPath = [appInfo bundlePath];
	NSString* appId = [appInfo bundleIdentifier];
	NSString* appName = [appInfo displayName];

	UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:@"Confirm Uninstallation" message:[NSString stringWithFormat:@"Uninstalling the app '%@' will delete the app and all data associated to it.", appName] preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* uninstallAction = [UIAlertAction actionWithTitle:@"Uninstall" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action)
	{
		if(appId)
		{
			[appsManager uninstallApp:appId];
		}
		else
		{
			[appsManager uninstallAppByPath:appPath];
		}
	}];
	[confirmAlert addAction:uninstallAction];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[confirmAlert addAction:cancelAction];

	[LSPresentationDelegate presentViewController:confirmAlert animated:YES completion:nil];
}

- (void)deselectRow
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _cachedAppInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LSAppCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplicationCell" forIndexPath:indexPath];

	if(!indexPath || indexPath.row > (_cachedAppInfos.count - 1)) return cell;

	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];
	NSString* appId = [appInfo bundleIdentifier];

	if(appId)
	{
		UIImage* cachedIcon = _cachedIcons[appId];
		if(cachedIcon)
		{
			[cell configureWithAppInfo:appInfo icon:cachedIcon];
		}
		else
		{
			[cell configureWithAppInfo:appInfo icon:_placeholderIcon];
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
			{
				UIImage* iconImage = imageWithSize([UIImage _applicationIconImageForBundleIdentifier:appId format:iconFormatToUse() scale:[UIScreen mainScreen].scale], _placeholderIcon.size);
				if (!iconImage) iconImage = self->_placeholderIcon;
				self->_cachedIcons[appId] = iconImage;
				dispatch_async(dispatch_get_main_queue(), ^{
					NSUInteger currentIndex = [self->_cachedAppInfos indexOfObject:appInfo];
					if (currentIndex == NSNotFound) return;
					NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
					UITableViewCell *curCell = [tableView cellForRowAtIndexPath:curIndexPath];
					if([curCell isKindOfClass:LSAppCell.class] &&
						[((LSAppCell *)curCell).representedBundleIdentifier isEqualToString:appId])
					{
						[(LSAppCell *)curCell configureWithAppInfo:appInfo icon:iconImage];
					}
				});
			});
		}
	}
	else
	{
		[cell configureWithAppInfo:appInfo icon:_placeholderIcon];
	}

	cell.separatorInset = UIEdgeInsetsZero;

	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self uninstallPressedForRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LSAppInfo* appInfo = _cachedAppInfos[indexPath.row];

	NSString* appId = [appInfo bundleIdentifier];
	NSString* appName = [appInfo displayName];

	UIAlertController* appSelectAlert = [UIAlertController alertControllerWithTitle:appName?:@"" message:appId?:@"" preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* openAction = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
	{
		[self openAppPressedForRowAtIndexPath:indexPath enableJIT:NO];
		[self deselectRow];
	}];
	[appSelectAlert addAction:openAction];

	if ([appInfo isDebuggable])
	{
		UIAlertAction* openWithJITAction = [UIAlertAction actionWithTitle:@"Open with JIT" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
		{
			[self openAppPressedForRowAtIndexPath:indexPath enableJIT:YES];
			[self deselectRow];
		}];
		[appSelectAlert addAction:openWithJITAction];
	}

	UIAlertAction* showDetailsAction = [UIAlertAction actionWithTitle:@"Show Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
	{
		[self showDetailsPressedForRowAtIndexPath:indexPath];
		[self deselectRow];
	}];
	[appSelectAlert addAction:showDetailsAction];

	NSString* switchState;
	NSString* registrationState = [appInfo registrationState];
	UIAlertActionStyle switchActionStyle = 0;
	if([registrationState isEqualToString:@"System"])
	{
		switchState = @"User";
		switchActionStyle = UIAlertActionStyleDestructive;
	}
	else if([registrationState isEqualToString:@"User"])
	{
		switchState = @"System";
		switchActionStyle = UIAlertActionStyleDefault;
	}

	UIAlertAction* switchRegistrationAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Switch to \"%@\" Registration", switchState] style:switchActionStyle handler:^(UIAlertAction* action)
	{
		[self changeAppRegistrationForRowAtIndexPath:indexPath toState:switchState];
		[self deselectRow];
	}];
	[appSelectAlert addAction:switchRegistrationAction];

	UIAlertAction* uninstallAction = [UIAlertAction actionWithTitle:@"Uninstall App" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action)
	{
		[self uninstallPressedForRowAtIndexPath:indexPath];
		[self deselectRow];
	}];
	[appSelectAlert addAction:uninstallAction];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action)
	{
		[self deselectRow];
	}];
	[appSelectAlert addAction:cancelAction];

	appSelectAlert.popoverPresentationController.sourceView = tableView;
	appSelectAlert.popoverPresentationController.sourceRect = [tableView rectForRowAtIndexPath:indexPath];

	[LSPresentationDelegate presentViewController:appSelectAlert animated:YES completion:nil];
}

- (void)purgeCachedIconsForApps:(NSArray <LSApplicationProxy *>*)apps
{
	for (LSApplicationProxy *appProxy in apps) {
		NSString *appId = appProxy.bundleIdentifier;
		if (_cachedIcons[appId]) {
			[_cachedIcons removeObjectForKey:appId];
		}
	}
}

- (void)applicationsDidInstall:(NSArray <LSApplicationProxy *>*)apps
{
	[self purgeCachedIconsForApps:apps];
	[self reloadTable];
}

- (void)applicationsDidUninstall:(NSArray <LSApplicationProxy *>*)apps
{
	[self purgeCachedIconsForApps:apps];
	[self reloadTable];
}

@end
