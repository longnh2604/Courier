//
//  VCSplash.m
//  Delivery
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCSplash.h"
#import "VCLogin.h"
#import "VCPermission.h"

@interface VCSplash ()

@end

@implementation VCSplash

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (APPSHARE.userLogin!=nil)
    {
        if (APPSHARE.userLogin.isPhoneConfirmed==YES)
        {
            //co basket
            if (![APPSHARE.userLogin.proBasket isEqualToString:@""])
            {
                [HServiceAPI getCurrentActiveBulkOrder:^(NSDictionary *results, NSError *error) {
                    if (!error)
                    {
                        [APPSHARE checkActiveOrder:YES];
                        OBulk *o = [OBulk convertToObject:results];
                        [OBulk saveOrder:o];
                        [APPSHARE addLeftPanelwithBulkOrder:o];
                    }
                    else
                    {
                        [APPSHARE addLeftPanelwithOrder:nil];
                    }
                }];
            }
            //co order
            else if (APPSHARE.userLogin.proOrder)
            {
                [HServiceAPI getActiveOrderDetails:^(NSDictionary *results, NSError *error)
                 {
                     if (results!=nil)
                     {
                         OOrderAvailable *curOrder = [OOrderAvailable convertToObject:results];
                         [OOrderAvailable saveOrder:curOrder];
                         
                         [APPSHARE addLeftPanelwithOrder:curOrder];
                     }
                     else
                     {
                         id jsonResponse = [HServiceAPI convertToJson:error.userInfo];
                         
                         if ([[jsonResponse stringForKey:@"detail"]isEqualToString:@"Incorrect authentication credentials."])
                         {
                             [APPSHARE configMenuSideWithOrder:nil];
                         }
                         else if ([[jsonResponse stringForKey:@"detail"]isEqualToString:@"You do not have permission to perform this action."])
                         {
                             [APPSHARE configMenuSideWithOrder:nil];
                         }
                         else if ([[jsonResponse stringForKey:@"detail"]isEqualToString:@"Account blocked."])
                         {
                             [APPSHARE configMenuSideWithOrder:nil];
                         }
                         else
                         {
                             OOrderAvailable *o = [OOrderAvailable getCurrentOrder];
                             if (o==nil)
                             {
                                 [APPSHARE checkActiveOrder:NO];
                                 [APPSHARE addLeftPanelwithOrder:nil];
                             }
                             else
                             {
                                 NSLog(@"order %@",o.oid);
                                 [HServiceAPI getDetailOrderWithID:o.oid hander:^(NSDictionary *results, NSError *error)
                                  {
                                      if (results!=nil)
                                      {
                                          if ([[results stringForKey:@"state"]isEqualToString:@"CANCELLED"])
                                          {
                                              NSString *msg;
                                              if ([[results stringForKey:@"sender_cancel_reason"]isEqualToString:@"ADMIN_CANCELLED"])
                                              {
                                                  NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[[results stringForKey:@"sender_cancel_note"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                              options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                                        NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                                                                   documentAttributes:nil
                                                                                                                error:nil];
                                                  msg = [attr string];
                                              }
                                              else if ([[results stringForKey:@"sender_cancel_reason"]isEqualToString:@"CHANGED_MIND"])
                                              {
                                                  msg = [NSString stringWithFormat:@"Sender has cancelled Order #%@ \n Reason: Sorry, I have changed my mind !",o.oid];
                                              }
                                              else if ([[results stringForKey:@"sender_cancel_reason"]isEqualToString:@"COURIER_DELAY"])
                                              {
                                                  msg = [NSString stringWithFormat:@"Sender has cancelled Order #%@ \n Reason: Courier didn't come on time !",o.oid];
                                              }
                                              else if ([[results stringForKey:@"sender_cancel_reason"]isEqualToString:@"OTHER"])
                                              {
                                                  msg = [NSString stringWithFormat:@"Sender has cancelled Order #%@ \n Reason: %@ !",o.oid,[results stringForKey:@"sender_cancel_note"]];
                                              }
                                              [APPSHARE checkActiveOrder:NO];
                                              [OOrderAvailable deleteAllOrder];
                                              [APPSHARE addLeftPanelwithOrder:nil];
                                              [UIAlertView showWithTitle:@"Notice" message:msg handler:nil];
                                          }
                                          else
                                          {
                                              [APPSHARE addLeftPanelwithOrder:o];
                                          }
                                      }
                                      else
                                      {
                                          [APPSHARE checkActiveOrder:NO];
                                          [OOrderAvailable deleteAllOrder];
                                          [APPSHARE addLeftPanelwithOrder:nil];
                                      }
                                  }];
                             }
                         }
                     }
                 }];
            }
            //ko co ca basket lan order
            else
            {
            
            }
        }
        else
        {
            [APPSHARE showVerifyPhone];
        }
    }
    else
    {
        [APPSHARE configMenuSideWithOrder:nil];
    }
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS

#pragma mark - DELEGATES



@end
