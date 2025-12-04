#import "LSListControllerShared.h"

@interface LSSettingsListController : LSListControllerShared
{
    PSSpecifier* _installPersistenceHelperSpecifier;
    NSString* _newerVersion;
    NSString* _newerLdidVersion;
    BOOL _devModeEnabled;
}
@end