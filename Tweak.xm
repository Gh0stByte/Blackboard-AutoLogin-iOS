/* 
 * Tweak.xm
 * Date: January 16, 2018
 * Developed by Gh0stByte, All Rights Reserved
 */
 NSString *username, *password;

// Hook into the main view controller
%hook BBLFTWViewController

// Hook into when the login page finishes loading
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // The javascript that we're gonna execute, which will set the username & password to what we've stored
    NSString *inject = [NSString stringWithFormat:@"document.getElementById('username').value = '%@';document.getElementById('password').value = '%@';", username, password];
    // Inject the JS
    [webView stringByEvaluatingJavaScriptFromString:inject];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
    {
        // Submit the form by pressing the button.
        [webView stringByEvaluatingJavaScriptFromString:@"document.forms[\"fm1\"].submit.click();"];
    });
    %orig;
}

%end

// Interface so we can call our custom method
@interface BBLFTWViewController : UIViewController
-(void)getAutofillInfo;
@end

// Hook into the login view controller
%hook BBLoginViewController

// Hook into when the login button is pressed
-(void)loginBtnTapped {
    // Grab your username and password from the userdefaults
    username = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    password = [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"];
    // If you don't have an username & password setup
    if(!(username && password) || ([username isEqualToString:@""] || [password isEqualToString:@""])) {
        // Setup your username & password
        [self getAutofillInfo];
    } else { 
        // Otherwise, load up the webview
        %orig;
    }
}

// Hook into when the help button is tapped
-(void)helpBtnTapped {
    // Ask the user if they want to change their information
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Auto-Login" message:@"Would you like to change your login information?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // If so, setup their username and pass
        [self getAutofillInfo];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Otherwise, use the normal function for the help button
        %orig;
    }];
    [alertController addAction:cancelAction];
    // Present the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

// New function to get the login info
%new
-(void)getAutofillInfo {
    // Ask the user to enter their input
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Auto-Login" message:@"Enter your username & password\n(Note: Information stored plaintext in the standard app defaults. To change the information, press the help button)" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Username";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //Store the information
       [[NSUserDefaults standardUserDefaults] setObject:[[alertController textFields][0] text] forKey:@"USERNAME"];
       [[NSUserDefaults standardUserDefaults] setObject:[[alertController textFields][1] text] forKey:@"PASSWORD"];
       [[NSUserDefaults standardUserDefaults] synchronize];

   }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    // Show the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

%end
