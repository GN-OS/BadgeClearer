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
-(void)resetbadges{ //Method for resset badges  button which basically resprings
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)//Over 6.0
    {
                system("killall backboardd");
    }
    else // Under 6.0
    {
        
        system("killall SpringBoard");
    }

    }
    
- (NSString *) version: (PSSpecifier *) specifier {//PSSpecifier for the version PSTitleValueCell
	
    return @"3.0-30";
}
- (NSString *) developer: (PSSpecifier *) specifier {//PSSpecifier for the developer PSTitleValueCell
    
	return @"Ge0rges";
}

- (NSString *) hostedby: (PSSpecifier *) specifier {//PSSpecifier for the Hosted by PSTitleValueCell
    
	return @"BigBoss and my repo";
}


-(void)devwebsite{//Method for Devwebsite button
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ge0rges.webs.com"]];
}
    
@end

// vim:ft=objc
