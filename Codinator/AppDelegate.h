//
//  AppDelegate.h
//  Codinator
//
//  Created by Vladimir Danila on 24/10/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSFileManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSString *storagePath;
+ (NSString *)storagePath;


@end

