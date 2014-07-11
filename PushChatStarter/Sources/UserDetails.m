//
//  UserDetails.m
//  PushChatStarter
//
//  Created by Peter Jones on 07/07/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

#import "UserDetails.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>


@implementation UserDetails

-(NSString*)getUserName{
    
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSString* myfirstName = [[NSString alloc] init];
    
    myfirstName = @"Peter";
    
    NSString* mylastName = [[NSString alloc] init];
    
    mylastName = @"Jones";
    //   ABRecordID myId = 123;
    
    // ABRecordRef* myRecord = ABAddressBookGetPersonWithRecordID(addressBook, myId);
    
    
    
    for(NSInteger i=0; i < ABAddressBookGetPersonCount(addressBook); i++){
        
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        NSString* firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        NSString* secondName =(NSString*)CFBridgingRelease(ABRecordCopyValue(ref, kABPersonLastNameProperty));
        
        if (([myfirstName  compare: firstName] == NSOrderedSame) && ([mylastName compare: secondName] == NSOrderedSame)){
            
            ABRecordID theId = ABRecordGetRecordID(ref);
            
            NSString* retStr = [[NSString alloc] initWithString:secondName];
            return retStr;
            
        }
    }

    
    return @"";
    
}




@end
