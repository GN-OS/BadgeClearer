//Hello World! (keeping traditions alive)
#define BLACKLIST @"/var/mobile/Library/Preferences/BadgeClearer_blacklist.plist"


@interface SBApplication 
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
@end


%hook SBApplicationIcon

- (void)launch {
    if ([self badgeValue] == 0)  {
        %orig;
        return;
    }
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
    NSString * launchingBundleID = [self applicationBundleID];
    if ([prefs objectForKey:launchingBundleID]) { // Application is present in blacklist
        %orig;
    } else {
     // Show the alert view   
     UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:@"BadgeClearer"
        message:nil
        delegate:self
        cancelButtonTitle:@"Cancel"
        otherButtonTitles:@"Clear badge count", @"Launch app", @"Both", nil];
    [launchView show];
    [launchView release];
    }
    [prefs release];
}

%new(v@:@@) - (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
    switch (button) {
        case 3:
            // "Both" pressed
            // Because there is no break;, code will continue onto case 2 and then break
            [self setBadge:nil];   
        case 2:
            // "Launch app" pressed
            // Launch the app
            [self launch];
            break;
        case 1:
            // "Clear badge count" pressed
            // Clear badge count
            [self setBadge:nil];
            break;
    }
}

%end
