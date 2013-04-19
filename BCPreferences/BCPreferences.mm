@class PSSpecifier;

@interface PSListController {
	NSArray *_specifiers;
}
@property(retain) NSArray *specifiers;

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;

@end

@interface BCPreferencesListController: PSListController {
}
@end

@implementation BCPreferencesListController
- (id)specifiers {
	if(!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"BCPreferences" target:self] retain];
	}
	return _specifiers;
}

@end

// vim:ft=objc
