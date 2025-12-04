#import <Foundation/Foundation.h>

#define LUISESTORE_ROOT_PATH @"/var/containers/Bundle/LuiseStore"
#define LUISESTORE_MAIN_PATH [LUISESTORE_ROOT_PATH stringByAppendingPathComponent:@"Main"]
#define LUISESTORE_APPLICATIONS_PATH [LUISESTORE_ROOT_PATH stringByAppendingPathComponent:@"Applications"]

@interface LSApplicationsManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray*)installedAppPaths;

- (NSError*)errorForCode:(int)code;
- (int)installIpa:(NSString*)pathToIpa force:(BOOL)force log:(NSString**)logOut;
- (int)installIpa:(NSString*)pathToIpa;
- (int)uninstallApp:(NSString*)appId;
- (int)uninstallAppByPath:(NSString*)path;
- (BOOL)openApplicationWithBundleID:(NSString *)appID;
- (int)enableJITForBundleID:(NSString *)appID;
- (int)changeAppRegistration:(NSString*)appPath toState:(NSString*)newState;

@end