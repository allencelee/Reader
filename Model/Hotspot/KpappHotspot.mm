// This file is part of Kpapp for iOS.

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic pop

#import <Foundation/Foundation.h>
#import "KpappHotspot.h"
#import "zim/archive.h"
#import "kiwix/library.h"
#import "kiwix/book.h"
#import "kiwix/server.h"
#import "ZimFileService.h"


@interface KpappHotspot ()

@property kiwix::LibraryPtr library;
@property std::shared_ptr<kiwix::Server> server;

@end

@implementation KpappHotspot

- (KpappHotspot *_Nonnull) init {
    self = [super init];
    self.library = kiwix::Library::create();
    self.server = std::make_shared<kiwix::Server>(self.library);
    return self;
}

- (Boolean) startFor: (nonnull NSSet *) zimFileIDs onPort: (int) port {
    self.server->stop();
    [self removeAllBooksFromLibrary];
    for (NSUUID *zimFileID in zimFileIDs) {
        try {
            zim::Archive * _Nullable archive = [[ZimFileService sharedInstance] archiveBy: zimFileID];
            if(archive != nullptr) {
                kiwix::Book book = kiwix::Book();
                book.update(*archive);
                self.library->addBook(book);
            } else {
                NSLog(@"couldn't add to hotspot zimFileID: %@", zimFileID);
            }
        } catch (std::exception &e) {
            NSLog(@"couldn't add zimFile to Hotspot: %@ because: %s", zimFileID, e.what());
        }
    }
    if(self.library->getBooksIds().size() > 0) {
        self.server->setPort(port);
        return self.server->start(); // this returns false if the port is occupied
    } else {
        NSLog(@"no point in starting the hotspot with no zim files");
        self.server->stop();
        return false;
    }
}

- (NSString *_Nullable) address {
    std::vector<std::string> urls = self.server->getServerAccessUrls();
    if (urls.size() > 0) {
        return [NSString stringWithUTF8String: urls[0].c_str()];
    } else {
        NSLog(@"no hotspot url was found");
        return nil;
    }
}

- (void) stop {
    self.server->stop();
    [self removeAllBooksFromLibrary];
}

- (void) removeAllBooksFromLibrary {
    for (std::string identifierC: self.library->getBooksIds()) {
        self.library->removeBookById(identifierC);
    }
}

@end
