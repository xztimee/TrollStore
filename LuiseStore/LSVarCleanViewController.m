#import "LSVarCleanViewController.h"
#import "LSUITheme.h"
#import <LSPresentationDelegate.h>
#import <LSUtil.h>

@interface LSVarCleanViewController ()
@property (nonatomic, copy) NSArray<NSMutableDictionary *> *groups;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL emptyStateVisible;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation LSVarCleanViewController

- (instancetype)init
{
	return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"varClean";
	self.clearsSelectionOnViewWillAppear = NO;
	[LSUITheme styleTableView:self.tableView];
	self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 12.0, 0.0);
	self.tableView.tableHeaderView = [self makeHeaderView];
	[LSUITheme sizeHeaderForTableView:self.tableView];
	self.tableView.tableFooterView = [UIView new];
	self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.tintColor = LSUITheme.accentColor;
	[self.refreshControl addTarget:self action:@selector(manualRefresh) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All"
		style:UIBarButtonItemStylePlain target:self action:@selector(toggleAll)];
	UIAction *editRulesAction = [UIAction actionWithTitle:@"Edit Custom Rules"
		image:[UIImage systemImageNamed:@"doc.text"] identifier:nil handler:^(UIAction *action) {
			[self openPathInFileViewer:self.customRulesPath];
		}];
	UIAction *cleanAction = [UIAction actionWithTitle:@"Clean Selected"
		image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(UIAction *action) {
			[self confirmClean];
		}];
	cleanAction.attributes = UIMenuElementAttributesDestructive;
	cleanAction.discoverabilityTitle = @"Delete selected files and folders";
	UIBarButtonItem *rulesButton = [[UIBarButtonItem alloc] initWithImage:
		[UIImage systemImageNamed:@"ellipsis.circle"] menu:
		[UIMenu menuWithTitle:@"varClean" children:@[cleanAction, editRulesAction]]];
	rulesButton.accessibilityLabel = @"varClean actions";
	self.navigationItem.rightBarButtonItem = rulesButton;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshKeepingSelection)
		name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChange:)
		name:UIContentSizeCategoryDidChangeNotification object:nil];
	[self refreshKeepingSelection:NO];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
	[LSUITheme sizeHeaderForTableView:self.tableView];
	[self.tableView reloadData];
}

- (UIView *)makeHeaderView
{
	CGFloat width = self.view.bounds.size.width;
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 1.0)];

	UIView *accent = [[UIView alloc] init];
	accent.translatesAutoresizingMaskIntoConstraints = NO;
	accent.backgroundColor = LSUITheme.accentColor;
	accent.layer.cornerRadius = 2.0;
	[header addSubview:accent];

	UILabel *title = [[UILabel alloc] init];
	title.translatesAutoresizingMaskIntoConstraints = NO;
	title.text = @"Filesystem residue";
	title.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleTitle2]
		scaledFontForFont:[LSUITheme displayFontWithSize:23.0 weight:UIFontWeightBold]];
	title.adjustsFontForContentSizeCategory = YES;
	title.numberOfLines = 0;
	title.textColor = LSUITheme.primaryTextColor;
	[header addSubview:title];

	_countLabel = [[UILabel alloc] init];
	_countLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_countLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption1]
		scaledFontForFont:[LSUITheme monoFontWithSize:11.0 weight:UIFontWeightMedium]];
	_countLabel.adjustsFontForContentSizeCategory = YES;
	_countLabel.numberOfLines = 0;
	_countLabel.textColor = LSUITheme.secondaryTextColor;
	[header addSubview:_countLabel];

	[NSLayoutConstraint activateConstraints:@[
		[accent.leadingAnchor constraintEqualToAnchor:header.readableContentGuide.leadingAnchor],
		[accent.topAnchor constraintEqualToAnchor:header.topAnchor constant:16.0],
		[accent.widthAnchor constraintEqualToConstant:30.0],
		[accent.heightAnchor constraintEqualToConstant:4.0],
		[title.leadingAnchor constraintEqualToAnchor:header.readableContentGuide.leadingAnchor],
		[title.trailingAnchor constraintEqualToAnchor:header.readableContentGuide.trailingAnchor],
		[title.topAnchor constraintEqualToAnchor:accent.bottomAnchor constant:10.0],
		[_countLabel.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
		[_countLabel.trailingAnchor constraintEqualToAnchor:title.trailingAnchor],
		[_countLabel.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:5.0],
		[_countLabel.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-16.0]
	]];
	return header;
}

- (NSString *)configDirectory
{
	return @"/var/mobile/Library/varClean";
}

- (NSString *)customRulesPath
{
	return [[self configDirectory] stringByAppendingPathComponent:@"varCleanRules-custom.plist"];
}

- (void)openPathInFileViewer:(NSString *)path
{
	NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:
		NSCharacterSet.URLQueryAllowedCharacterSet];
	for (NSString *prefix in @[@"filzer://view", @"filza://view"]) {
		NSURL *URL = [NSURL URLWithString:[prefix stringByAppendingString:encodedPath ?: @""]];
		if (URL && [UIApplication.sharedApplication canOpenURL:URL]) {
			[UIApplication.sharedApplication openURL:URL options:@{} completionHandler:nil];
			return;
		}
	}
	UIPasteboard.generalPasteboard.string = path;
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Path copied"
		message:@"Filza is unavailable. The path was copied to the clipboard."
		preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
	[LSPresentationDelegate presentViewController:alert animated:YES completion:nil];
}

- (NSDictionary *)dictionaryFromCommentedJSONResource:(NSString *)name error:(NSError **)error
{
	NSURL *URL = [NSBundle.mainBundle URLForResource:name withExtension:@"json"];
	if (!URL) {
		if (error) *error = [NSError errorWithDomain:@"LuiseStoreVarClean" code:1
			userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@.json is missing.", name]}];
		return nil;
	}

	NSString *JSON = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
	if (!JSON) return nil;

	NSRegularExpression *comments = [NSRegularExpression regularExpressionWithPattern:@"//[^\\r\\n]*"
		options:0 error:nil];
	JSON = [comments stringByReplacingMatchesInString:JSON options:0
		range:NSMakeRange(0, JSON.length) withTemplate:@""];

	NSRegularExpression *trailingCommas = [NSRegularExpression regularExpressionWithPattern:@",\\s*([}\\]])"
		options:0 error:nil];
	JSON = [trailingCommas stringByReplacingMatchesInString:JSON options:0
		range:NSMakeRange(0, JSON.length) withTemplate:@"$1"];

	NSData *data = [JSON dataUsingEncoding:NSUTF8StringEncoding];
	id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
	return [object isKindOfClass:NSDictionary.class] ? object : nil;
}

- (NSDictionary *)rulesByMergingBase:(NSDictionary *)base overrides:(NSDictionary *)overrides
{
	NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithDictionary:base ?: @{}];
	[overrides enumerateKeysAndObjectsUsingBlock:^(NSString *path, id value, BOOL *stop) {
		if (![value isKindOfClass:NSDictionary.class]) return;
		NSDictionary *override = value;
		if ([override[@"_remove"] boolValue]) {
			[merged removeObjectForKey:path];
			return;
		}

		NSMutableDictionary *section = [NSMutableDictionary dictionaryWithDictionary:
			[merged[path] isKindOfClass:NSDictionary.class] ? merged[path] : @{}];
		for (NSString *listKey in @[@"whitelist", @"blacklist"]) {
			NSArray *additions = override[[listKey stringByAppendingString:@"_add"]];
			NSArray *removals = override[[listKey stringByAppendingString:@"_remove"]];
			if (![additions isKindOfClass:NSArray.class] && ![removals isKindOfClass:NSArray.class]) continue;
			NSMutableArray *list = [NSMutableArray arrayWithArray:
				[section[listKey] isKindOfClass:NSArray.class] ? section[listKey] : @[]];
			for (id item in removals ?: @[]) {
				[list removeObject:item];
			}
			for (id item in additions ?: @[]) {
				if (![list containsObject:item]) [list addObject:item];
			}
			section[listKey] = list;
		}
		for (NSString *key in override) {
			if (![key isEqualToString:@"_remove"] && ![key hasSuffix:@"_add"] && ![key hasSuffix:@"_remove"]) {
				section[key] = override[key];
			}
		}
		merged[path] = section;
	}];
	return merged;
}

- (NSDictionary *)defaultRulesWithError:(NSError **)error
{
	NSDictionary *rules = [self dictionaryFromCommentedJSONResource:@"VarCleanRules" error:error];
	if (!rules) return nil;
	if (NSProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 14) {
		NSDictionary *overrides = [self dictionaryFromCommentedJSONResource:@"varCleanRules_rootful_overrides" error:error];
		if (!overrides) return nil;
		rules = [self rulesByMergingBase:rules overrides:overrides];
	}
	return rules;
}

- (BOOL)ensureConfigDirectory:(NSError **)error
{
	NSFileManager *manager = NSFileManager.defaultManager;
	if (![manager fileExistsAtPath:self.configDirectory]) {
		NSDictionary *attributes = @{
			NSFilePosixPermissions: @(0755),
			NSFileOwnerAccountID: @501,
			NSFileGroupOwnerAccountID: @501
		};
		if (![manager createDirectoryAtPath:self.configDirectory withIntermediateDirectories:YES
			attributes:attributes error:error]) return NO;
	}
	if (![manager fileExistsAtPath:self.customRulesPath]) {
		if (![@{} writeToFile:self.customRulesPath atomically:YES]) {
			if (error) *error = [NSError errorWithDomain:@"LuiseStoreVarClean" code:2
				userInfo:@{NSLocalizedDescriptionKey: @"Could not create the custom rules file."}];
			return NO;
		}
	}
	return YES;
}

- (BOOL)file:(NSString *)file matchesList:(NSArray *)list
{
	for (id item in list ?: @[]) {
		if ([item isKindOfClass:NSString.class] && [file isEqualToString:item]) return YES;
		if (![item isKindOfClass:NSDictionary.class]) continue;
		NSString *name = item[@"name"];
		NSString *match = item[@"match"];
		if ([match isEqualToString:@"include"] && [file rangeOfString:name].location != NSNotFound) return YES;
		if ([match isEqualToString:@"regexp"]) {
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:name options:0 error:nil];
			if ([regex numberOfMatchesInString:file options:0 range:NSMakeRange(0, file.length)] > 0) return YES;
		}
	}
	return NO;
}

- (void)addItemsFromRules:(NSDictionary *)rules
	customRules:(NSDictionary *)customRules
	remainingCustomRules:(NSMutableDictionary *)remainingCustomRules
	groups:(NSMutableArray *)groups
	previousStates:(NSDictionary *)previousStates
{
	for (NSString *path in rules) {
		NSDictionary *rule = rules[path] ?: @{};
		NSDictionary *custom = customRules[path] ?: @{};
		[remainingCustomRules removeObjectForKey:path];
		NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
		NSMutableArray *items = [NSMutableArray array];

		for (NSString *file in contents ?: @[]) {
			BOOL checked = NO;
			BOOL ignored = NO;
			NSArray *whiteList = rule[@"whitelist"];
			NSArray *blackList = rule[@"blacklist"];
			NSArray *customWhiteList = custom[@"whitelist"];
			NSArray *customBlackList = custom[@"blacklist"];

			if ([self file:file matchesList:blackList]) {
				ignored = [self file:file matchesList:customWhiteList];
				checked = !ignored;
			} else if ([self file:file matchesList:customBlackList]) {
				checked = YES;
			} else if ([self file:file matchesList:whiteList]) {
				continue;
			} else if ([rule[@"default"] isEqualToString:@"blacklist"]) {
				ignored = [self file:file matchesList:customWhiteList] ||
					[custom[@"default"] isEqualToString:@"whitelist"];
				checked = !ignored;
			} else if ([rule[@"default"] isEqualToString:@"whitelist"]) {
				if ([custom[@"default"] isEqualToString:@"blacklist"]) checked = YES;
				else continue;
			} else {
				ignored = [self file:file matchesList:customWhiteList] ||
					[custom[@"default"] isEqualToString:@"whitelist"];
				checked = !ignored && [custom[@"default"] isEqualToString:@"blacklist"];
			}

			NSString *fullPath = [path stringByAppendingPathComponent:file];
			if (!ignored && previousStates[fullPath]) checked = [previousStates[fullPath] boolValue];
			BOOL isDirectory = NO;
			[NSFileManager.defaultManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
			[items addObject:[@{
				@"name": file,
				@"path": fullPath,
				@"isDirectory": @(isDirectory),
				@"checked": @(checked),
				@"ignored": @(ignored)
			} mutableCopy]];
		}

		[items sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
			if ([a[@"isDirectory"] boolValue] != [b[@"isDirectory"] boolValue]) {
				return [a[@"isDirectory"] boolValue] ? NSOrderedAscending : NSOrderedDescending;
			}
			return [a[@"name"] localizedCaseInsensitiveCompare:b[@"name"]];
		}];
		[groups addObject:[@{
			@"path": path,
			@"items": items,
			@"error": @(!contents && [NSFileManager.defaultManager fileExistsAtPath:path])
		} mutableCopy]];
	}
}

- (NSArray<NSMutableDictionary *> *)groupsForRules:(NSDictionary *)rules
	customRules:(NSMutableDictionary *)customRules previousGroups:(NSArray *)previousGroups
{
	NSMutableArray *groups = [NSMutableArray array];
	NSMutableDictionary *remainingCustomRules = [customRules mutableCopy] ?: [NSMutableDictionary dictionary];
	NSMutableDictionary *previousStates = [NSMutableDictionary dictionary];
	for (NSDictionary *group in previousGroups ?: @[]) {
		for (NSDictionary *item in group[@"items"]) {
			previousStates[item[@"path"]] = item[@"checked"] ?: @NO;
		}
	}

	[self addItemsFromRules:rules customRules:customRules remainingCustomRules:remainingCustomRules
		groups:groups previousStates:previousStates];
	[self addItemsFromRules:remainingCustomRules customRules:nil remainingCustomRules:
		[NSMutableDictionary dictionary] groups:groups previousStates:previousStates];

	[groups sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
		BOOL aHasItems = [a[@"items"] count] > 0;
		BOOL bHasItems = [b[@"items"] count] > 0;
		if (aHasItems != bHasItems) return aHasItems ? NSOrderedAscending : NSOrderedDescending;
		return [a[@"path"] compare:b[@"path"]];
	}];
	return groups;
}

- (void)manualRefresh
{
	[self refreshKeepingSelection:NO];
}

- (void)refreshKeepingSelection
{
	[self refreshKeepingSelection:YES];
}

- (void)refreshKeepingSelection:(BOOL)keepSelection
{
	if (self.loading) return;
	self.loading = YES;
	[self updateSummary];
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	NSArray *previous = keepSelection ? self.groups : nil;

	dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
		NSError *error = nil;
		NSDictionary *rules = [self defaultRulesWithError:&error];
		if (rules && [self ensureConfigDirectory:&error]) {
			NSMutableDictionary *custom = [NSMutableDictionary dictionaryWithContentsOfFile:self.customRulesPath];
			NSArray *groups = [self groupsForRules:rules customRules:custom previousGroups:previous];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.groups = groups;
				self.loading = NO;
				[self.refreshControl endRefreshing];
				[self.tableView reloadData];
				[self updateSummary];
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.loading = NO;
				[self.refreshControl endRefreshing];
				[self.tableView reloadData];
				[self updateSummary];
				[self showError:error ?: [NSError errorWithDomain:@"LuiseStoreVarClean" code:3
					userInfo:@{NSLocalizedDescriptionKey: @"Could not load varClean rules."}]];
			});
		}
	});
}

- (NSArray<NSMutableDictionary *> *)selectedItems
{
	NSMutableArray *selected = [NSMutableArray array];
	for (NSDictionary *group in self.groups) {
		for (NSMutableDictionary *item in group[@"items"]) {
			if ([item[@"checked"] boolValue] && ![item[@"ignored"] boolValue]) [selected addObject:item];
		}
	}
	return selected;
}

- (void)updateSummary
{
	NSUInteger candidates = 0;
	for (NSDictionary *group in self.groups) candidates += [group[@"items"] count];
	NSUInteger selected = self.selectedItems.count;
	self.countLabel.text = self.loading ? @"SCANNING…" :
		[NSString stringWithFormat:@"%lu CANDIDATE%@  ·  %lu SELECTED",
			(unsigned long)candidates, candidates == 1 ? @"" : @"S", (unsigned long)selected];
	self.navigationItem.leftBarButtonItem.enabled = !self.loading && candidates > 0;
	self.navigationItem.rightBarButtonItem.enabled = !self.loading;
	UIBarButtonItem *actionsButton = self.navigationItem.rightBarButtonItem;
	UIAction *cleanAction = (UIAction *)actionsButton.menu.children.firstObject;
	cleanAction.attributes = selected > 0
		? UIMenuElementAttributesDestructive
		: (UIMenuElementAttributesDestructive | UIMenuElementAttributesDisabled);
	self.emptyStateVisible = candidates == 0 && !self.loading;
	if (self.emptyStateVisible) {
		self.tableView.backgroundView = self.emptyLabel;
	} else {
		self.tableView.backgroundView = nil;
	}
}

- (void)toggleAll
{
	BOOL shouldSelect = self.selectedItems.count == 0;
	for (NSDictionary *group in self.groups) {
		for (NSMutableDictionary *item in group[@"items"]) {
			if (![item[@"ignored"] boolValue]) item[@"checked"] = @(shouldSelect);
		}
	}
	[self.tableView reloadData];
	[self updateSummary];
}

- (void)confirmClean
{
	NSArray *selected = self.selectedItems;
	if (!selected.count) return;

	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:selected.count];
	for (NSDictionary *item in selected) [paths addObject:item[@"path"]];
	NSString *message = [paths componentsJoinedByString:@"\n"];

	UIAlertController *alert = [UIAlertController alertControllerWithTitle:
		[NSString stringWithFormat:@"Delete %lu item%@?", (unsigned long)selected.count, selected.count == 1 ? @"" : @"s"]
		message:message preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
		handler:^(UIAlertAction *action) { [self cleanItems:selected]; }]];
	[LSPresentationDelegate presentViewController:alert animated:YES completion:nil];
}

- (void)cleanItems:(NSArray<NSDictionary *> *)items
{
	[LSPresentationDelegate startActivity:@"Cleaning selected items"];
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
		NSMutableArray<NSString *> *failures = [NSMutableArray array];
		NSMutableArray<NSString *> *allowedRoots = [NSMutableArray array];
		for (NSDictionary *group in self.groups) {
			NSString *root = [group[@"path"] stringByStandardizingPath];
			if (root.length) [allowedRoots addObject:root];
		}
		for (NSDictionary *item in items) {
			NSString *path = [item[@"path"] stringByStandardizingPath];
			NSString *parent = [path stringByDeletingLastPathComponent];
			if (![allowedRoots containsObject:parent] || ![parent hasPrefix:@"/var"]) {
				[failures addObject:path];
				continue;
			}
			NSString *error = nil;
			if (spawnRoot(rootHelperPath(), @[@"var-clean", path], nil, &error) != 0) {
				[failures addObject:error.length
					? [NSString stringWithFormat:@"%@ — %@", path,
						[error stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]]
					: path];
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[LSPresentationDelegate stopActivityWithCompletion:^{
				if (failures.count) {
					NSError *error = [NSError errorWithDomain:@"LuiseStoreVarClean" code:4
						userInfo:@{NSLocalizedDescriptionKey:
							[NSString stringWithFormat:@"%lu item%@ could not be deleted.\n\n%@",
								(unsigned long)failures.count, failures.count == 1 ? @"" : @"s",
								[failures componentsJoinedByString:@"\n"]]}];
					[self showError:error];
				}
				[self refreshKeepingSelection:NO];
			}];
		});
	});
}

- (void)showError:(NSError *)error
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"varClean Error"
		message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
	[LSPresentationDelegate presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.groups[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.groups[section][@"path"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VarCleanCell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VarCleanCell"];
	NSDictionary *item = self.groups[indexPath.section][@"items"][indexPath.row];
	BOOL ignored = [item[@"ignored"] boolValue];
	BOOL checked = [item[@"checked"] boolValue];

	cell.backgroundColor = LSUITheme.surfaceColor;
	cell.tintColor = LSUITheme.accentColor;
	cell.textLabel.text = item[@"name"];
	cell.textLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
		scaledFontForFont:[LSUITheme bodyFontWithSize:15.0 weight:UIFontWeightMedium]];
	cell.textLabel.adjustsFontForContentSizeCategory = YES;
	cell.textLabel.textColor = ignored ? LSUITheme.tertiaryTextColor : LSUITheme.primaryTextColor;
	cell.detailTextLabel.text = [item[@"isDirectory"] boolValue] ? @"Directory" : @"File";
	cell.detailTextLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption2]
		scaledFontForFont:[LSUITheme monoFontWithSize:10.0 weight:UIFontWeightRegular]];
	cell.detailTextLabel.adjustsFontForContentSizeCategory = YES;
	cell.detailTextLabel.textColor = LSUITheme.secondaryTextColor;
	cell.imageView.image = [UIImage systemImageNamed:[item[@"isDirectory"] boolValue] ? @"folder.fill" : @"doc.fill"];
	cell.imageView.tintColor = ignored ? LSUITheme.tertiaryTextColor : LSUITheme.secondaryAccentColor;
	cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:
		ignored ? @"lock.fill" : (checked ? @"checkmark.circle.fill" : @"circle")]];
	cell.accessoryView.tintColor = ignored ? LSUITheme.tertiaryTextColor : LSUITheme.accentColor;
	cell.selectionStyle = ignored ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
	cell.isAccessibilityElement = YES;
	cell.accessibilityLabel = item[@"name"];
	cell.accessibilityValue = ignored ? @"Protected by custom rules" : (checked ? @"Selected for deletion" : @"Not selected");
	cell.accessibilityHint = ignored ? nil : @"Double tap to toggle selection";
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSMutableDictionary *item = self.groups[indexPath.section][@"items"][indexPath.row];
	if ([item[@"ignored"] boolValue]) return;
	item[@"checked"] = @(![item[@"checked"] boolValue]);
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	[self updateSummary];
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView
	contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point
{
	NSString *path = self.groups[indexPath.section][@"items"][indexPath.row][@"path"];
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil
		actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
			UIAction *openAction = [UIAction actionWithTitle:@"Open in Filza"
				image:[UIImage systemImageNamed:@"folder"] identifier:nil handler:^(UIAction *action) {
					[self openPathInFileViewer:path];
				}];
			UIAction *copyAction = [UIAction actionWithTitle:@"Copy Path"
				image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction *action) {
					UIPasteboard.generalPasteboard.string = path;
				}];
			return [UIMenu menuWithChildren:@[openAction, copyAction]];
		}];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	NSDictionary *group = self.groups[section];
	header.textLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleCaption2]
		scaledFontForFont:[LSUITheme monoFontWithSize:10.0 weight:UIFontWeightMedium]];
	header.textLabel.adjustsFontForContentSizeCategory = YES;
	header.textLabel.textColor = [group[@"error"] boolValue] ? UIColor.systemRedColor :
		([group[@"items"] count] ? LSUITheme.secondaryTextColor : LSUITheme.tertiaryTextColor);
}

- (UILabel *)emptyLabel
{
	if (!_emptyLabel) {
		_emptyLabel = [[UILabel alloc] initWithFrame:self.tableView.bounds];
		_emptyLabel.text = @"No residue found\nYour filesystem looks clean.";
		_emptyLabel.numberOfLines = 2;
		_emptyLabel.textAlignment = NSTextAlignmentCenter;
	_emptyLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
		scaledFontForFont:[LSUITheme bodyFontWithSize:16.0 weight:UIFontWeightMedium]];
	_emptyLabel.adjustsFontForContentSizeCategory = YES;
		_emptyLabel.textColor = LSUITheme.secondaryTextColor;
	}
	return _emptyLabel;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[LSUITheme sizeHeaderForTableView:self.tableView];
	_emptyLabel.frame = self.tableView.bounds;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	self.tableView.backgroundColor = LSUITheme.backgroundColor;
	if (self.emptyStateVisible) self.tableView.backgroundView = self.emptyLabel;
	[self.tableView reloadData];
}

@end
