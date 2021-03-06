//
//  httpData.m
//  meepo
//
//  Created by Mikael Melander on 2018-02-02.
//  Copyright © 2018 Mikael Melander. All rights reserved.
//

#import "httpData.h"

#define k_notesLink @"https://timesheet-1172.appspot.com/2a00ea83/notes"

@implementation httpData

-(void)getData {
    
    NSURL *url = [[NSURL alloc]initWithString:k_notesLink];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *err) {
                
               
                
                // request error
                if (err) {
                    [task cancel];
                    [self.delegate didFailWithRequest:[NSString stringWithFormat:@"error: %@", err]];
                    
                }
                // response error
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    if (statusCode != 200) {
                        [task cancel];
                        [self.delegate didFailWithRequest:[NSString stringWithFormat:@"request failed with status code: %ld", (long)statusCode]];
                    }
                }
                
               if (!err) {
                   NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
                   NSLog(@"%@", jsonArray);
                    [self.delegate didFininshRequestWithJson:jsonArray];
                }

    }];
    [task resume];
}

-(void)postData:(noteObject *)note :(NSString *)type {
    
    NSString *urlString;
    if (![type isEqualToString:@"POST"])
        urlString = [NSString stringWithFormat:@"%@/%d", k_notesLink, [note getId]];
    else
        urlString = k_notesLink;
    
   
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[note getJson] options:0 error:&error];
    NSURL *url = [[NSURL alloc]initWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:type];
    if ([type isEqualToString:@"POST"] || [type isEqualToString:@"PUT"])
        [request setHTTPBody:data];
    
    NSLog(@"%@", urlString);
    
    NSURLSessionDataTask *postTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@", response);
        // request error
        if (error) {
            [self.delegate didFailWithRequest:[NSString stringWithFormat:@"error: %@", error]];
        }
        // response error
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 201 && statusCode != 204 && statusCode != 200) {
                [self.delegate didFailWithRequest:[NSString stringWithFormat:@"request failed with status code: %ld", (long)statusCode]];
            }
            else if (statusCode == 204)
                [self.delegate didFininshRequestWithJson:nil];
        }
        
        if (!error) {
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"%@", jsonArray);
                [self.delegate didFininshRequestWithJson:jsonArray];
        }
        else
            return;
    }];
    
    [postTask resume];
}

@end
