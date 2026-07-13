// This file is part of Kpapp for iOS.

#import <Foundation/Foundation.h>
#import "ZimFileMetaData.h"

NS_ASSUME_NONNULL_BEGIN

@interface OPDSParser : NSObject

- (nonnull instancetype)init;
- (BOOL)parseData:(nonnull NSData *)data using: (nonnull NSString *)urlHost NS_REFINED_FOR_SWIFT;
- (nonnull NSSet *)getZimFileIDs NS_REFINED_FOR_SWIFT;
- (nullable ZimFileMetaData *)getZimFileMetaData:(nonnull NSUUID *)identifier NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
