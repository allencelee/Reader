// This file is part of Kpapp for iOS.

#import "SearchResult.h"

@implementation SearchResult

- (instancetype)initWithZimFileID:(NSUUID *)zimFileID path:(NSString *)path title:(NSString *)title {
    self = [super init];
    if (self) {
        self.zimFileID = zimFileID;
        self.title = title;
        
        // HACK: assuming path is always absolute, which is required to construct a url using NSURLComponents
        if (![path hasPrefix:@"/"]) { path = [@"/" stringByAppendingString:path]; }
        
        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = @"zim";
        components.host = [zimFileID UUIDString];
        components.path = path;
        self.url = [components URL];
        
        if (self.zimFileID == nil || self.title == nil || self.url == nil) {
            return nil;
        }
    }
    return self;
}

@end
