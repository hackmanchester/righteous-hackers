//
//  AddressBookDoCoMoParsedResult.h
//  ZXing
//
//  Created by Christian Brunschen on 29/05/2008.
/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "ParsedResult.h"

@interface BusinessCardParsedResult : ParsedResult {
  NSArray *names;
  NSString *pronunciation;
  NSArray *phoneNumbers;
  NSArray *emails;
  NSString *note;
  NSArray *addresses;
  NSString *organization;
  NSString *birthday;
  NSString *jobTitle;
  NSString *url;
}

@property (nonatomic, retain) NSArray *names;
@property (nonatomic, copy) NSString *pronunciation;
@property (nonatomic, retain) NSArray *phoneNumbers;
@property (nonatomic, retain) NSArray *emails;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, retain) NSArray *addresses;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *url;

@end
