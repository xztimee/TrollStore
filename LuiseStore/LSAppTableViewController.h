#import <UIKit/UIKit.h>
#import "LSAppInfo.h"
#import <CoreServices.h>

@interface LSAppTableViewController : UITableViewController <UISearchResultsUpdating, UIDocumentPickerDelegate, LSApplicationWorkspaceObserverProtocol>
{
    UIImage* _placeholderIcon;
    NSArray<LSAppInfo*>* _cachedAppInfos;
    NSMutableDictionary* _cachedIcons;
    UISearchController* _searchController;
	NSString* _searchKey;
}

@end