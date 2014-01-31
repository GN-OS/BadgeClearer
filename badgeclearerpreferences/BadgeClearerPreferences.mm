//#import <Preferences/Preferences.h>
//Tired of having header issues? Just forward-declare stuff!

@interface PSListController : NSObject { //Good enough
	id _specifiers;
}

-(id)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;

@end

@interface BadgeClearerPreferencesListController: PSListController
@end

@implementation BadgeClearerPreferencesListController
-(id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"BadgeClearerPreferences" target:self] retain];
	}
	return _specifiers;
}

-(void)donation {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LAEUC26VGLX2N"]];
}

-(void)twitter {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/GN_OS"]];
	}
}

-(void)getFlipswitchToggle {
}

@end

// vim:ft=objc
