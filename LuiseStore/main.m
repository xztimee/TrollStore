#import <Foundation/Foundation.h>
#import "LSAppDelegate.h"
#import "LSUtil.h"

NSUserDefaults* luiseStoreUserDefaults(void)
{
	return [[NSUserDefaults alloc] initWithSuiteName:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Preferences/%@.plist", APP_ID]]];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		chineseWifiFixup();
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(LSAppDelegate.class));
	}
}
