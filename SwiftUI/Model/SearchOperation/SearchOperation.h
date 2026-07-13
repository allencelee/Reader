// This file is part of Kpapp for iOS.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchOperation : NSOperation

@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, assign) BOOL extractMatchingSnippet;
@property (nonatomic, strong) NSMutableSet *foundURLs;
@property (nonatomic, strong) NSMutableOrderedSet *results NS_REFINED_FOR_SWIFT;

- (id)initWithSearchText:(NSString *)searchText zimFileIDs:(NSSet *)zimFileIDs;
- (void)performSearch;

@end

NS_ASSUME_NONNULL_END
