//
//  SyncController.h
//  Hipster iPad
//
//  Created by Jiva DeVoe on 9/27/10.
//  Copyright 2010 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define STARTED_SYNC @"STARTING_SYNC"
#define ENDED_SYNC @"ENDED_SYNC"

/** The `WHISyncController` class is the main entry point for starting and interfacing with the Wasabi Sync subsystem. Currently this is a singleton, but you should not rely on this behavior as this is likely to change in future releases.
 
 To begin synchronizing data, You should first initialize the system by using the `+globalInstanceWithServerURL:contextCreator:` class method. This should be done early in your application launch cycle. You should also set the `appId` and `apiKey`. You get these values from the Wasabi Sync web portal.  The synchronization system will not begin actually actively syncing objects until you call the `-start` method. A typical initialization would look something like the following:

    WHISyncController *sync = [WHISyncController globalInstanceWithServerURL:@"http://www.wasabisync.com/" 
                                                              contextCreator:^NSManagedObjectContext *
    {
        return {... code to create new NSManagedObjectContexts for your app ...}  ;
    }];
    [sync setAppId:@"com.yourcompany.yourapp"];
    [sync setApiKey:@"yourkey"];
    [sync load];
    [sync start];
 
 The call to `-load` loads the synchronization state, if any, that was previously saved using a call to `-save`. This allows any transactions which are currently in progress to saved to disk so that they can be continued later.
 
 The purpose of the context creator block is to give the synchronization system a mechanism for creating new `NSManagedObjectContexts` as needed. The synchronization system uses background threads in some operations. In these cases, it needs to be able to create new contexts that can be used with these threads. Therefore, it is very important that the context returned from this block is not your main thread context. It is generally preferred that the code used here returns a new context whenever this block is executed.
 
 */

@interface WHISyncController : NSObject

/// The time in seconds between polling calls to the server. Default is every 60 seconds. This may change under heavy server load.
@property (nonatomic) NSTimeInterval refreshInterval;
/// The last time they synchronization successfully completed.
@property (strong)  NSDate *lastSync;
/// The last error that occurred when contacting the server.
@property (strong) NSError *lastError;
/** The current model version.
 
 Whenever you make significant changes to your schema that require a migration, you should probably increment your model version to prevent the user from attempting to synchronize two devices with different versions of the schema.
 */
@property (strong, nonatomic) NSString *latestModelVersion;

/** True when a sync is currently in progress. */
@property (nonatomic) BOOL syncInProgress;

/** Enables sending large datasets in chunks.
 
 Large datasets can take time to parse on the server. If you're sending large datasets, you should enable this flag to improve performance on the server.
 
 */
@property (nonatomic) BOOL enableChunking;

/** The URL of the server to send data to.
 
 The default for this is http://www.wasabisync.com/. If you want to use ssl or an alternative server, you can change that here.
 */
@property (strong, nonatomic) NSString *serverUrl;

/** The user's email address. */
@property (strong, nonatomic) NSString *emailAddress;
/** The user's password. */
@property (strong, nonatomic) NSString *userPassword;
/** The application id. */
@property (strong, nonatomic) NSString *appId;
/** The API key for this application. */
@property (strong, nonatomic) NSString *apiKey;
/** Enables logging of errors to the console. Might be helpful for debugging. 0 = None, 1 = Errors (default), 2 = Info, 3 = Debug (very verbose)*/
@property int logLevel;

/// @name Initialization

/** Class singleton accessor */
+(WHISyncController *)globalInstance;

/** Initialization factory method. */
+(WHISyncController *)globalInstanceWithServerURL:(NSString *)inServerURL contextCreator:(NSManagedObjectContext *(^)(void))inCtxCreator;

/** Resets the refresh timer. */
-(void)resetTimer;

/// @name Change observation

/** Disable observation of changes. If you disable observing and then change your synchronized objects, those changes will not synchronize.
 
 The process of serializing the objects that have been changed can be slow if you are doing a lot of inserts or deletions at once. In some rare cases, you may want to disable observation, do all your inserts and deletes, and then let the server ask for the changed objects. When you do this, the serialization will occur on a background thread and may be faster.
 
 */
 -(void)disableObserving;

/** Enable observation of changes. If you call `-disableObserving` you must remember to call this method to re-enable observation.
 
 You do not need to call this unless you have called `-disableObserving`. Observation defaults to on unless you explicitly disable it.
 
 */
-(void)enableObserving;

/// @name Login and Logout

/** Logs the user in using the give email address and password.
 
 @param inEmailAddress the email address of the user.
 @param inPassword the password for the user.
 @param inCallback Called when the operation has completed.
 */
-(void)loginWithEmailAddress:(NSString *)inEmailAddress password:(NSString *)inPassword callback:(void (^)(BOOL succeeded, NSError *inError))inCallback;
/** Logs the user out of the server and disables synchronization. */
-(void)logout;
/** Logs the user out of the server and disables synchronization. 
 
 @param inCallback block callback is called when the operation completes.
 */
-(void)logoutWithCallback:(void (^)(BOOL succeeded, NSError *inError))inCallback;
/** Creates an account on the server for the given username and password.
 
 @param inEmailAddress The email address of the user.
 @param inPassword The user's password. You are responsible for prompting the user to confirm their password before sending.
 @param inCallback A block to call when the operation completes.
 */
-(void)signupWithEmailAddress:(NSString *)inEmailAddress password:(NSString *)inPassword callback:(void (^)(BOOL succeeded, NSError *inError))inCallback;
/** Returns TRUE if the user is currently logged into the server. */
-(BOOL)loggedIn;

/// @name Synchronization Control

/** Start automatically synchronizing with the server. */
-(void)start;
/** Stops automatic synchronization with the server. */
-(void)cancel;
/** Forces a synchronization right now. */
-(void)forceSync;
/** Forces a synchronization with the server with a continuation.
 @param inContinuation when the synchronization completes, the continuation will be called.
 */
-(void)forceSyncWithContinuation:(void (^)(void))inContinuation;

/// @name Saving and Restoring State

/** Saves the currently unsynced transactions to the server. */
-(void)save;
/** Loads transactions previously saved using `-save`. */
-(void)load;

//-(void)addChangesOfType:(NSString *)inType fromObjects:(NSSet *)inObjects;
//
//// In these calls, the "genericObjectId" parameter specifies the *NAME* of the object... ie: "Settings" or something. It's unique to your object, but not unique among users.
//// VERY VERY IMPORTANT: This is a case where using setters in dealloc to set values to nil WILL CAUSE BUGS beware!
//-(void)registerObservationOfKeyPath:(NSString *)inKeyPath onObject:(id)inObj withGenericObjectId:(NSString *)inId;
//-(void)unregisterObservationOfKeyPath:(NSString *)inKeyPath onObjectWithGenericObjectId:(NSString *)inId;
@end

