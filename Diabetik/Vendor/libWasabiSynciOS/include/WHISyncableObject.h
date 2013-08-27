//
//  SyncableObjectProtocol.h
//  Wishlist
//
//  Created by Jiva DeVoe on 11/20/11.
//  Copyright (c) 2011 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/** All objects that you want to synchronize must implement the WHISyncableObject protocol. The only required property of this protocol is the `-guid` property. Other methods enable you to customize the synchronization behavior. For example, if you want to prevent particular relationships from being serialized because they are not required to be transmitted, then you might implement the `-relationshipsToNotSerialize` method.
 
 **Large data, like images is not currently supported for automatic synchronization. For those, we recommend you store the images elsewhere, and then store URLs to access them in Wasabi Sync.**
 */
@protocol WHISyncableObject <NSObject>
/// A unique identifier for this object which should never **ever** (no really, I mean **never**) change. (**Required**)
@property (nonatomic, strong) NSString *guid;

@optional
/// Returns true if an object has expired. Expired objects do not get synchronized.
-(BOOL)expired;
/// Flags a given object as expired. Expired objects do not get synchronized.
-(void)setExpired:(BOOL)inExpired;
/// A list of relationships which should not be serialized.
/// This is used when objects are being sent to the server.
/// @returns An array of names (strings) which correspond to the names of relationships which should not be serialized.
-(NSArray *)relationshipsToNotSerialize;
/// A list of relationships which should not be deserialized.
/// This is used when objects are received from the server.
/// @returns An array of names (strings) which correspond to the names of relationships which should not be deserialized.
-(NSArray *)relationshipsToNotDeSerialize;

/// This method returns the entity description for this entity type. The default will return an entity description matching the class name of the NSManagedObject.
+(NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
