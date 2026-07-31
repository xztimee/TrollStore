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
	UIView* _libraryHeaderView;
	UILabel* _libraryCountLabel;
	UIView* _emptyStateView;
	UILabel* _emptyTitleLabel;
	UILabel* _emptyMessageLabel;
}

@end