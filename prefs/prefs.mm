@class PSSpecifier;

@interface PSListController {
	NSArray *_specifiers;
}
@property(retain) NSArray *specifiers;

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;

@end

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
	
    return @"3.1-15";
}
- (NSString *) developer: (PSSpecifier *) specifier {//PSSpecifier for the developer PSTitleValueCell
    
	return @"GN-OS ";
}
    
@end

// vim:ft=objc
