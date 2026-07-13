// This file is part of Kpapp for iOS.

#import <Foundation/Foundation.h>
#import "ZimFileMetaData.h"
#import "zim/archive.h"

@interface ZimFileService : NSObject

@property (nonatomic, strong) NSString *_Nonnull libkpappVersion;
@property (nonatomic, strong) NSString *_Nonnull libzimVersion;

- (instancetype _Nonnull)init NS_REFINED_FOR_SWIFT;
+ (nonnull ZimFileService *)sharedInstance NS_REFINED_FOR_SWIFT;

#pragma mark - Reader Management

- (void)store:(NSURL *_Nonnull)url with:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (NSUUID *_Nullable)open:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (void)close:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (NSArray *_Nonnull)getReaderIdentifiers NS_REFINED_FOR_SWIFT;
- (zim::Archive *_Nullable) archiveBy: (NSUUID *_Nonnull) zimFileID;
- (zim::Archive *_Nullable) findArchiveBy: (NSUUID *_Nonnull) zimFileID;
- (nonnull void *) getArchives;

# pragma mark - Metadata

+ (nullable ZimFileMetaData *)getMetaDataWithFileURL:(nonnull NSURL *)url NS_REFINED_FOR_SWIFT;

# pragma mark - URL Handling

- (NSURL *_Nullable)getFileURL:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (NSString *_Nullable)getRedirectedPath:(NSUUID *_Nonnull)zimFileID contentPath:(NSString *_Nonnull)contentPath NS_REFINED_FOR_SWIFT;
- (NSString *_Nullable)getMainPagePath:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (NSString *_Nullable)getRandomPagePath:(NSUUID *_Nonnull)zimFileID NS_REFINED_FOR_SWIFT;
- (NSNumber *_Nullable)getContentSize:(NSUUID *_Nonnull)zimFileID contentPath:(NSString *_Nonnull)contentPath NS_REFINED_FOR_SWIFT;
- (NSDictionary *_Nullable)getContent:(NSUUID *_Nonnull)zimFileID contentPath:(NSString *_Nonnull)contentPath
                           start:(NSUInteger)start end:(NSUInteger)end NS_REFINED_FOR_SWIFT;
- (NSDictionary *_Nullable)getMetaData:(NSUUID *_Nonnull)zimFileID contentPath:(NSString *_Nonnull)contentPath  NS_REFINED_FOR_SWIFT;
- (NSDictionary *_Nullable)getDirectAccess: (NSUUID *_Nonnull)zimFileID contentPath:(NSString *_Nonnull)contentPath NS_REFINED_FOR_SWIFT;

@end
