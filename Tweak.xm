//old preferences file
#define BLACKLIST @"/var/mobile/Library/Preferences/com.gnos.BadgeClearer.blacklist.plist"
//new preferences file
#define PREFERENCESFILE @"/var/mobile/Library/Preferences/com.gnos.BadgeClearer.plist"

#define GNPreferencesChangedNotification "com.gnos.BadgeClearer.preferences.changed"

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
- (void)launch; // <=iOS 7
- (void)launchFromLocation:(SBIconLocation)location; // =iOS 8
- (void)launchFromLocation:(SBIconLocation)location context:(id)arg2; // >=iOS 9-10
@end

@interface GNSomeUIAlertViewDelegateClass : NSObject <UIAlertViewDelegate> {
}

@end

static GNSomeUIAlertViewDelegateClass *_si;
static BOOL _justLaunch = NO;
static NSDictionary *_prefs = nil;
static SBApplicationIcon *_appIcon = nil;
static SBIconLocation _appLocation = SBIconLocationHomeScreen;

/*
void GN_createDefaultPreferences(void);
void GN_updatePreferencesFile(void);
void GN_reloadPreferences(void);
BOOL GN_keyIsEnabled(NSString *key);
BOOL GN_applicationIconWithLocationShouldLaunch(SBApplicationIcon *icon, SBIconLocation location);
void GN_showAlert(void);
*/



//lang: C

static void GN_updatePreferencesFile(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:BLACKLIST]) {
		NSError *error = nil;
		if (![fm moveItemAtPath:BLACKLIST toPath:PREFERENCESFILE error:&error]) {
			NSLog(@"Failed to move '%@' to '%@': %@", BLACKLIST, PREFERENCESFILE, [error localizedDescription]);
		}
	}
	[pool release];
}

static void GN_createDefaultPreferences(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
	[d writeToFile:PREFERENCESFILE atomically:YES];
	[d release];

	[pool release];
}

static void GN_reloadPreferences(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GN_updatePreferencesFile();

	if (_prefs != nil) {
		[_prefs release];
	}
	_prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCESFILE]; // Load the plist
	//Is PREFERENCESFILE not existent?
	if (_prefs == nil) { // create new plist
		GN_createDefaultPreferences();
		// Load the plist again
		_prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCESFILE];
	}

	[pool release];
}

static inline BOOL GN_keyIsEnabled(NSString *key) {
	return [[_prefs objectForKey:key] boolValue];
}

static BOOL GN_applicationIconWithLocationShouldLaunch(SBApplicationIcon *icon, SBIconLocation location) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	_appIcon = icon;
	_appLocation = location;

	NSString *applicationBundleID = (_appIcon == nil)? @"" : [_appIcon applicationBundleID];
	int badgeValue = (_appIcon == nil)? 0 : [_appIcon badgeValue];

	BOOL enabled = GN_keyIsEnabled(@"enabled");
	BOOL appIsBlacklisted = GN_keyIsEnabled(applicationBundleID);
	BOOL r = ((badgeValue != 0) && enabled)? appIsBlacklisted : YES;
	_justLaunch = (_justLaunch == NO)? r : YES;

	[pool release];
	return _justLaunch;
}

static void GN_showAlert(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	BOOL debug = GN_keyIsEnabled(@"debug");
	NSString *displayName = (_appIcon == nil)? @"" : [_appIcon displayName];
	NSString *applicationBundleID = (_appIcon == nil)? @"" : [_appIcon applicationBundleID];

	id launchView = [[%c(UIAlertView) alloc] initWithTitle:(debug? applicationBundleID : displayName)
		message:nil
		delegate:_si
		cancelButtonTitle:@"Cancel"
		otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
	[launchView show];
	[launchView release];

	[pool release];
}



//lang: Objective-C

@implementation GNSomeUIAlertViewDelegateClass

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {  // after animation
	if (_appIcon == nil) {
		return;
	}
	switch (buttonIndex) {
	case 3: // "Both" pressed
		// Because there is no 'break;', code will continue onto case 2 and then break
		[_appIcon setBadge:nil];
	case 2: // "Launch app" pressed
		// Launch the app, skip all the other checks
		_justLaunch = YES;
		if (kCFCoreFoundationVersionNumber < 847.20) {// iOS 7
			[_appIcon launch];

		} else if (kCFCoreFoundationVersionNumber < 1200){// iOS 8
			[_appIcon launchFromLocation:_appLocation];

		} else {// iOS 9-10
			[_appIcon launchFromLocation:_appLocation context:nil];
		}

		break;
	case 1: // "Clear Badges" pressed
		// Clear badge count
		[_appIcon setBadge:nil];
		break;
	}
}

@end



//lang: Logos

%hook SBApplicationIcon

// iOS 7
- (void)launch {
	if (GN_applicationIconWithLocationShouldLaunch(self, SBIconLocationHomeScreen)) {
		_justLaunch = NO; //reset for next launch
		%orig();
	} else {
		GN_showAlert();
	}
}

// iOS 8
- (void)launchFromLocation:(SBIconLocation)location {
	if (GN_applicationIconWithLocationShouldLaunch(self, location)) {
		_justLaunch = NO; //reset for next launch
		%orig();
	} else {
		GN_showAlert();
	}
}

// iOS 9-10
- (void)launchFromLocation:(SBIconLocation)location context:(id)context {
	if (GN_applicationIconWithLocationShouldLaunch(self, location)) {
		_justLaunch = NO; //reset for next launch
		%orig();
	} else {
		GN_showAlert();
	}
}

%end

%hook SBNotificationCenterTouchEater

-(void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
    %log(@"BCUS");
    return %orig;
}

%end

//notification managing

static void GNPreferencesChanged(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GN_reloadPreferences();
	[pool release];
}

static void GNPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	GNPreferencesChanged();
}

%ctor {
	%init();
	_si = [[GNSomeUIAlertViewDelegateClass alloc] init];
	GNPreferencesChanged();

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, GNPreferencesChangedCallback, CFSTR(GNPreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool release];
}
