#import "Preferences.h"

@interface prefsListController: PSListController {
}
@end

@implementation prefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"prefs" target:self] retain];
	}
	return _specifiers;
}

- (NSString *) version: (PSSpecifier *) specifier {//PSSpecifier for the version PSTitleValueCell
	
    return @"3.0-2";
}
    
@end

