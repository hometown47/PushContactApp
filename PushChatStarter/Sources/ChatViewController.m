//
//  ChatViewController.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "ChatViewController.h"
#import "DataModel.h"
#import "LoginViewController.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"

// Constants for save/restore NSUserDefaults for the user entered display name and service type.
NSString * const kNSDefaultDisplayNameA = @"displayNameKey";

@interface ChatViewController() {
    AFHTTPClient *_client;
}
@end

@implementation ChatViewController



- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataModel = [[DataModel alloc] init];
        [_dataModel loadMessages];
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:ServerApiURL]];
        
        
        // Get the display name and service type from the previous session (if any)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _userRecordId = (ABRecordID)[defaults objectForKey:kNSDefaultDisplayNameA];
    }
    return self;
}

- (void)scrollToNewestMessage
{
	// The newest message is at the bottom of the table
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(self.dataModel.messages.count - 1) inSection:0];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];	
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_dataModel joinedChat])
	{
		[self showLoginViewController];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	self.title = [_dataModel secretCode];

	// Show a label in the table's footer if there are no messages
	if (self.dataModel.messages.count == 0)
	{
		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
		label.text = NSLocalizedString(@"You have no messages", nil);
		label.font = [UIFont boldSystemFontOfSize:16.0f];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.tableView.tableFooterView = label;
	}
	else
	{
		[self scrollToNewestMessage];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataModel.messages.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"MessageCellIdentifier";

	MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

	Message* message = (self.dataModel.messages)[indexPath.row];
	[cell setMessage:message];
	return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	// This function is called before cellForRowAtIndexPath, once for each cell.
	// We calculate the size of the speech bubble here and then cache it in the
	// Message object, so we don't have to repeat those calculations every time
	// we draw the cell. We add 16px for the label that sits under the bubble.
	Message* message = (self.dataModel.messages)[indexPath.row];
	message.bubbleSize = [SpeechBubbleView sizeForText:message.text];
	return message.bubbleSize.height + 16;
}

#pragma mark -
#pragma mark ComposeDelegate

- (void)didSaveMessage:(Message*)message atIndex:(int)index
{
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
		self.tableView.tableFooterView = nil;
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self scrollToNewestMessage];
	}
}

#pragma mark -
#pragma mark Actions

- (void) showLoginViewController {
    LoginViewController* loginController = (LoginViewController*) [ApplicationDelegate.storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	loginController.dataModel = _dataModel;
    loginController.client = _client;
	[self presentViewController:loginController animated:YES completion:nil];
}

- (void)userDidLeave
{
	[self.dataModel setJoinedChat:NO];

	// Show the Login screen. This requires the user to join a new
	// chat room before he can return to the chat screen.
	[self showLoginViewController];
}

- (void)postLeaveRequest
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Signing Out", nil);
    
    NSDictionary *params = @{@"cmd":@"leave",
                             @"user_id":[_dataModel userId]};
    [_client
     postPath:@"/api.php"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if ([self isViewLoaded]) {
             [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
             if (operation.response.statusCode != 200) {
                 ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
                                                  } else {
                                                      [self userDidLeave];
                                                  }
                                                  }
                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      if ([self isViewLoaded]) {
                                                          [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                                          ShowErrorAlert([error localizedDescription]);
                                                      }
                                                  }];
}


-(void)getJSONRequest: (NSString*) fromId{
 
    
 
    [_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [_client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSLog(@"this user is %@ and from user id is %@",[_dataModel userId], fromId);
    
    
    NSDictionary *getparams = @{@"cmd":@"retrieve",
                                // @"json":@"{\"a\":1,\"b\":2,\"c\":3,\"d\":4,\"e\":5}"};
                                
                                @"user_id":[_dataModel userId],
                                @"from_id" : fromId};
    
    
    
    
    NSURL *url = [NSURL URLWithString:ServerApiURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    // NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/json.php" parameters:getparams];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"/apiget.php" parameters:getparams];
    NSLog(@"%@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             NSError* myError;
                                             NSDictionary *jsonDictionary = JSON;
                                             
                                             NSDictionary* theResponse = [jsonDictionary objectForKey:@"Response"];
                                             
                                             
                                             
                                             NSData* theData = [theResponse objectForKey:@"Payload"];
                                             
                                             NSString* myStr = [theResponse valueForKey:@"Payload"];
                                             
                                             //     NSString* vCardStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
                                             
                                             //                       NSString* vBackCard = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
                                             
                                             CFDataRef vCardData = (__bridge CFDataRef)[myStr dataUsingEncoding:NSUTF8StringEncoding];
                                             CFErrorRef* error = NULL;
                                             
                                             ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, error);
                                             
                                             ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
                                             
                                             CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
                                             
                                             ABRecordRef myPerson = CFArrayGetValueAtIndex(vCardPeople, 0);
                                             
                                             NSString* firstName = (__bridge NSString *)(ABRecordCopyValue(myPerson, kABPersonFirstNameProperty));
                                             NSString* lastName = (__bridge NSString *)(ABRecordCopyValue(myPerson, kABPersonLastNameProperty));
                                             //
                                             NSLog(@"Name is %@, %@", firstName, lastName);
                                            NSString* thisStr = [[NSString alloc] initWithFormat:@"%@ %@",firstName, lastName, nil];
                                             
                                            
                                        //     return retString;
                                             [self addMessage:thisStr];
                                        
                                             
                                         }
                                            failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON)
                                         {
                                             NSLog(@"Failed: %@",[error localizedDescription]);
                                            
                                        
                                         }
                                         ];
    [operation start];
    

}

-(void)addMessage: (NSString*) theMessage{
   
  
	Message* message = [[Message alloc] init];
	message.date = [NSDate date];
    
    

    
    
    
	//NSMutableArray* parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
	message.senderName =  @"System" ; //[parts objectAtIndex:0];
	//[parts removeObjectAtIndex:0];
	message.text = theMessage; //[parts componentsJoinedByString:@": "];
    
	int index = [_dataModel addMessage:message];
    
	
    [self didSaveMessage:message atIndex:index];
    
}

- (IBAction)exitAction
{
	[self postLeaveRequest];
}

- (IBAction)composeAction
{
	// Show the Compose screen
	ComposeViewController* composeController = (ComposeViewController*) [ApplicationDelegate.storyBoard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
	composeController.dataModel = _dataModel;
	composeController.delegate = self;
    composeController.client = _client;
	[self presentViewController:composeController animated:YES completion:nil];
}

@end
