//Hello World! (keeping traditions alive)
#define BLACKLIST @"/var/mobile/Library/Preferences/com.gnos.BadgeClearer.blacklist.plist"

@interface SBApplicationIcon
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
- (id)displayName;
@end

static BOOL justLaunch = NO;

%hook SBApplicationIcon

-(void)launch {
	BOOL debug;
	NSDictionary *prefs = nil;
	NSNumber *num;
	NSString *displayName = [self displayName];
	NSString *launchingBundleID = [self applicationBundleID];

	if (justLaunch == NO) {
		prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
		//Is BLACKLIST not existent?
		if (prefs == nil) { // create new plist
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
			// Load the plist again
			prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST];
		}

		num = (NSNumber *)[prefs objectForKey:@"enabled"];
		// does prefs contain a @"enabled" key? or is it true?
		if (num == nil || [num boolValue] == NO) {
			// then launch normally
			justLaunch = YES;
		}

		num = (NSNumber *)[prefs objectForKey:launchingBundleID];
		// if the list is valid or it contains the bundle ID for the launching app and its key is true,
		// it means that the application is present in blacklist; then do the original implementation.
		if (num != nil && [num boolValue] == YES) {
			// then launch normally
			justLaunch = YES;
		}

		if ([self badgeValue] == 0) {
			// then launch normally
			justLaunch = YES;
		}

		//debug key
		num = (NSNumber *)[prefs objectForKey:@"debug"];
		debug = (num != nil)? [num boolValue]:NO;

		[prefs release];
	}

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
		// Show the alert view
		id avClass = %c(UIAlertView);
		id launchView = [[avClass alloc] initWithTitle:
		(debug?launchingBundleID:displayName)
		 //ternary operator, switches between the string SpringBoard shows and the internal name for the app
			message:nil
			delegate:self
			cancelButtonTitle:@"Cancel"
			otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
		[launchView show];
		[launchView release];
	}
}

%new
- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
	switch (button) {
	case 3: // "Both" pressed
		// Because there is no 'break;', code will continue onto case 2 and then break
		[self setBadge:nil];
	case 2: // "Launch app" pressed
		// Launch the app, skip all the other checks
		justLaunch = YES;
		[self launch];
		break;
	case 1: // "Clear Badges" pressed
		// Clear badge count
		[self setBadge:nil];
		break;
	}
}

%end
