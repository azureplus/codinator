//
//  AppDelegate.m
//  Codinator
//
//  Created by Vladimir Danila on 24/10/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

@import CoreSpotlight;


#import "AppDelegate.h"
#import "WelcomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Create FileSystem
    
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

        NSString *playgroundsDirPath = [path stringByAppendingPathComponent:@"Playground"];
        NSString *projectsDirPath = [path stringByAppendingPathComponent:@"Projects"];
        
        NSError *error;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:projectsDirPath withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:playgroundsDirPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        
        
        NSURL *rootDirectory = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
        
        
        
        
        // And finish up the 'store' action
        if (![[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:[NSURL fileURLWithPath:playgroundsDirPath isDirectory:YES] destinationURL:[rootDirectory URLByAppendingPathComponent:@"Playground"] error:&error]) {
            NSLog(@"Error occurred: %@", error);
        }
        
        if (![[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:[NSURL fileURLWithPath:projectsDirPath isDirectory:YES] destinationURL:[rootDirectory URLByAppendingPathComponent:@"Projects"] error:&error]) {
            NSLog(@"Error occurred: %@", error);
        }
        
        
        
        
    
    

    

    _window.tintColor = [UIColor purpleColor];
    
    
    return YES;
}






- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0){
    // Import file
    return [self moveImportedFile:url.path.lastPathComponent atPath:url.path];
    
}



- (BOOL)moveImportedFile:(NSString *)filename atPath:(NSString *)path{
    
    
    // Get storage path
    NSString *storagePath = [[AppDelegate storagePath] stringByAppendingPathComponent:@"Projects"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if dir exists
    if ([fileManager fileExistsAtPath:storagePath]) {
        
        
        // Move imported file to the location
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:[storagePath stringByAppendingPathComponent:filename] error:&error];
        
        // Check if no error happened
        if (error){
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        else{
            
            UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
            WelcomeViewController *welcomeController = navController.viewControllers[0];
            
            [welcomeController reloadData];
            
            return YES;
        }
        
    }

    return NO;
}




#pragma mark - File Managment

// Storage Path
+ (NSString *)storagePath {
    
    NSURL *rootDirectory = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
    
    
    if (rootDirectory && ![[NSUserDefaults standardUserDefaults] boolForKey:@"CnCloud"]){
        return rootDirectory.path;
    }
    else{
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        NSURL *homeURL = [NSURL fileURLWithPath:documentDirectory isDirectory:YES];
        
        return homeURL.path;
    }
    
    
}



#pragma mark - Spotlight


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
    WelcomeViewController *welcomeController = navController.viewControllers[0];
    
    [welcomeController restoreUserActivityState:userActivity];
    
    return true;
}



#pragma mark - Other

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




@end
