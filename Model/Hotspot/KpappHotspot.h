// This file is part of Kpapp for iOS.

#import <Foundation/Foundation.h>
#import "kiwix/library.h"

@interface KpappHotspot : NSObject

- (nonnull KpappHotspot *) init NS_REFINED_FOR_SWIFT;
- (Boolean) startFor: (NSSet *_Nonnull) zimFileIDs onPort: (int) port NS_REFINED_FOR_SWIFT;
- (nullable NSString *) address NS_REFINED_FOR_SWIFT;
- (void) stop NS_REFINED_FOR_SWIFT;

@end

