//Hello World! (keeping traditions alive)
#define BLACKLIST @"/var/mobile/Library/Preferences/BadgeClearer_blacklist.plist"
#define DEBUG 0

@interface SBApplication 
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
- (id)displayName;
@end

static BOOL justLaunch = NO;

%hook SBApplicationIcon

- (void)launch {
	//justLaunch will be YES when selecting either option 2 or 3 in the UIAlertView that shows up
	//![self badgeValue] will be true only when it is 0
    if (justLaunch || ![self badgeValue]) {
	justLaunch = NO; //reset for next launch
    	%orig;
    	return;
    }
    
    
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
    NSString *launchingBundleID = [self applicationBundleID];
    NSString *displayName = [self displayName];

    //if the list is valid and it contains the bundle ID for the launching app, it means that the application is present
    // in blacklist; therefore it should do the original implementation.
    if (prefs && [prefs objectForKey:launchingBundleID]) {
        %orig;
    } else {
        // Show the alert view   
        UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:(DEBUG?launchingBundleID:displayName) //ternary operator, switches between the string SpringBoard shows and the internal name for the app
            message:nil
            delegate:self
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
        [launchView show];
        [launchView release];
    }
    [prefs release];
}



%new(v@:@@) - (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
    switch (button) {
        case 3: // "Both" pressed
            // Because there is no 'break;', code will continue onto case 2 and then break
            [self setBadge:nil];   
        case 2: // "Launch app" pressed
            // Launch the app, skip all the other checks
	    	justLaunch = YES;	
            [self launch];
            break;
        case 1: // "Clear badge count" pressed
            // Clear badge count
            [self setBadge:nil];
            break;
    }
}

%end
