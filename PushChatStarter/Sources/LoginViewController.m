//
//  LoginViewController.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"


//#import <AddressBookUI/AddressBookUI.h>

@interface LoginViewController()
- (IBAction)selectUser:(id)sender;
@property (nonatomic, retain) IBOutlet UITextField* nicknameTextField;
@property (nonatomic, retain) IBOutlet UITextField* secretCodeTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.nicknameTextField.text = [self.dataModel nickname];
	self.secretCodeTextField.text = [self.dataModel secretCode];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.nicknameTextField.text.length == 0)
		[self.nicknameTextField becomeFirstResponder];
	else
		[self.secretCodeTextField becomeFirstResponder];
}


#pragma mark -
#pragma mark Actions

- (void)userDidJoin
{
	// Close the Login screen
	[self.dataModel setJoinedChat:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postJoinRequest
{
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Connecting", nil);
    
    NSDictionary *params = @{@"cmd":@"join",
                             @"user_id":[_dataModel userId],
                             @"token":[_dataModel deviceToken],
                             @"name":[_dataModel nickname],
                             @"code":[_dataModel secretCode]};
    
    [_client postPath:@"/api.php"
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     
                                     if ([self isViewLoaded]) {
                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                         if([operation.response statusCode] != 200) {
                                             ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
                                         } else {
                                             [self userDidJoin];
                                         }
                                     }
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if ([self isViewLoaded]) {
                                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                                         ShowErrorAlert([error localizedDescription]);
                                     }
                                 }];
}

- (IBAction)loginAction
{
	if (self.nicknameTextField.text.length == 0)
	{
		ShowErrorAlert(NSLocalizedString(@"Fill in your nickname", nil));
		return;
	}

	if (self.secretCodeTextField.text.length == 0)
	{
		ShowErrorAlert(NSLocalizedString(@"Fill in a secret code", nil));
		return;
	}

	[self.dataModel setNickname:self.nicknameTextField.text];
	[self.dataModel setSecretCode:self.secretCodeTextField.text];
    
    [self.dataModel setRecordId:_myRecordId];
    

	// Hide the keyboard
	[self.nicknameTextField resignFirstResponder];
	[self.secretCodeTextField resignFirstResponder];

	[self postJoinRequest];
}

- (IBAction)selectUser:(id)sender {
    
    
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    

     
     
}

-(void)displayPerson:(ABRecordRef)person{
    
    NSString* name  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    self.nicknameTextField.text = name;
    
    
    _myRecordId = ABRecordGetRecordID(person);
    
    
    
}

#pragma mark - PeoplePicker Delegate Methods
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    return NO;
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
 
    
    [self displayPerson:person];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}



@end
