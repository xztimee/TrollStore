#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface LSListControllerShared : PSListController
- (BOOL)isLuiseStore;
- (NSString*)getLuiseStoreVersion;
- (void)downloadLuiseStoreAndRun:(void (^)(NSString* localLuiseStoreTarPath))doHandler;
- (void)installLuiseStorePressed;
- (void)updateLuiseStorePressed;
- (void)rebuildIconCachePressed;
- (void)refreshAppRegistrationsPressed;
- (void)uninstallPersistenceHelperPressed;
- (void)handleUninstallation;
- (NSMutableArray*)argsForUninstallingLuiseStore;
- (void)uninstallLuiseStorePressed;
@end