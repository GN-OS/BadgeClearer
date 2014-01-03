#define BLACKLIST @"/var/mobile/Library/Preferences/com.gnos.BadgeClearer.blacklist.plist"

// iOS 7 stuff
typedef enum {
	SBIconLocationHomeScreen = 0,
	SBIconLocationDock       = 1,
	SBIconLocationSwitcher   = 2
} SBIconLocation;

@interface SBApplicationIcon
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (NSString *)applicationBundleID;
- (NSString *)displayName;
- (void)launch; // <=iOS6
- (void)launchFromLocation:(SBIconLocation)location; // >=iOS7
@end

static BOOL justLaunch = NO;


@interface GNSomeUIAlertViewDelegateClass : NSObject <UIAlertViewDelegate> {
}
@property (nonatomic, assign) SBApplicationIcon *appIcon;
@property (nonatomic, assign) SBIconLocation appLocation;

+ (id)sharedInstance;

- (void)createDefaultPreferences;
- (BOOL)keyIsEnabled:(NSString *)key;
- (BOOL)applicationWithIdentifier:(NSString *)applicationBundleID andBadgeValueShouldLaunch:(int)badgeValue;

- (void)showAlert;

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

//- (void)alertViewCancel:(UIAlertView *)alertView; // never called

//- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
//- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
@end

@implementation GNSomeUIAlertViewDelegateClass

@synthesize appIcon, appLocation;

+ (id)sharedInstance {
	static id si = nil;
	if (si == nil) {
		si = [[GNSomeUIAlertViewDelegateClass alloc] init];
	}
	return si;
}

- (void)createDefaultPreferences {
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:
		[NSArray arrayWithObjects:
			[NSNumber numberWithBool:YES],
			[NSNumber numberWithBool:NO],
		nil]
	forKeys:
		[NSArray arrayWithObjects:
			@"enabled",
			@"debug",
		nil]
	];
	[d writeToFile:BLACKLIST atomically:YES];
	[d release];
}

- (BOOL)keyIsEnabled:(NSString *)key {
	NSDictionary *prefs = nil;
	prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
	//Is BLACKLIST not existent?
	if (prefs == nil) { // create new plist
		[[GNSomeUIAlertViewDelegateClass sharedInstance] createDefaultPreferences];
		// Load the plist again
		prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST];
	}

	BOOL value =  [[prefs objectForKey:key] boolValue];
	[prefs release];

	return value;
}

- (BOOL)applicationWithIdentifier:(NSString *)applicationBundleID andBadgeValueShouldLaunch:(int)badgeValue {
//	GNSomeUIAlertViewDelegateClass *si = [GNSomeUIAlertViewDelegateClass sharedInstance];
	BOOL enabled = [self keyIsEnabled:@"enabled"];
	BOOL appIsBlacklisted = [self keyIsEnabled:applicationBundleID];
	return ((badgeValue != 0)? enabled : NO)? appIsBlacklisted : YES;
}

- (void)showAlert {
//	GNSomeUIAlertViewDelegateClass *si = [GNSomeUIAlertViewDelegateClass sharedInstance];
	BOOL debug = [self keyIsEnabled:@"debug"];
	NSString *displayName = (self.appIcon == nil)? @"" : [self.appIcon displayName];
	NSString *applicationBundleID = (self.appIcon == nil)? @"" : [self.appIcon applicationBundleID];

	id launchView = [[%c(UIAlertView) alloc] initWithTitle:(debug? applicationBundleID : displayName)
	//ternary operator, switches between the string SpringBoard shows and the internal name for the app
		message:nil
		delegate:self
		cancelButtonTitle:@"Cancel"
		otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
	[launchView show];
	[launchView release];
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}
*/
/*
- (void)alertViewCancel:(UIAlertView *)alertView {
}
*/

/*
- (void)willPresentAlertView:(UIAlertView *)alertView {
}
*/
/*
- (void)didPresentAlertView:(UIAlertView *)alertView {
}
*/

/*
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
}
*/
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self.appIcon == nil) {
		return;
	}
	switch (buttonIndex) {
	case 3: // "Both" pressed
		// Because there is no 'break;', code will continue onto case 2 and then break
		[self.appIcon setBadge:nil];
	case 2: // "Launch app" pressed
		// Launch the app, skip all the other checks
		justLaunch = YES;
		if (kCFCoreFoundationVersionNumber < 847.20) {
			[self.appIcon launch];
		} else {
			[self.appIcon launchFromLocation:self.appLocation];
		}

		break;
	case 1: // "Clear Badges" pressed
		// Clear badge count
		[self.appIcon setBadge:nil];
		break;
	}
}
@end


%hook SBApplicationIcon

- (void)launch {
	GNSomeUIAlertViewDelegateClass *si = [GNSomeUIAlertViewDelegateClass sharedInstance];
	[si setAppIcon:self];
	[si setAppLocation:SBIconLocationHomeScreen];

	justLaunch = (justLaunch == NO)? [si applicationWithIdentifier:[self applicationBundleID] andBadgeValueShouldLaunch:[self badgeValue]] : YES;

	// justLaunch will be YES when:
	// -the tweak is disabled
	// -the app is in the blacklist
	// -the user selects either option 2 or 3 in the UIAlertView that shows up
	// ![self badgeValue] will be true only when it is 0
	if (justLaunch == YES) {
		//reset for next launch
		justLaunch = NO;
		%orig;
	} else {
		[si showAlert];
	}
}

- (void)launchFromLocation:(SBIconLocation)location {
	GNSomeUIAlertViewDelegateClass *si = [GNSomeUIAlertViewDelegateClass sharedInstance];
	[si setAppIcon:self];
	[si setAppLocation:location];

	justLaunch = (justLaunch == NO)? [si applicationWithIdentifier:[self applicationBundleID] andBadgeValueShouldLaunch:[self badgeValue]] : YES;

	// justLaunch will be YES when:
	// -the tweak is disabled
	// -the app is in the blacklist
	// -the user selects either option 2 or 3 in the UIAlertView that shows up
	// ![self badgeValue] will be true only when it is 0
	if (justLaunch == YES) {
		//reset for next launch
		justLaunch = NO;
		%orig;
	} else {
		[si showAlert];
	}
}

%end

%ctor {
	%init;
	[GNSomeUIAlertViewDelegateClass sharedInstance];
}
