//
//  LoginViewController.h
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

//#import "AddressBookPeoplePickerViewController.h"

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@class DataModel;

// The Login screen lets the user register a nickname and chat room
@interface LoginViewController : UIViewController  <ABPeoplePickerNavigationControllerDelegate>


@property (nonatomic, assign) DataModel* dataModel;
@property (nonatomic, strong) AFHTTPClient *client;
@property (nonatomic) ABRecordID myRecordId;

@end
