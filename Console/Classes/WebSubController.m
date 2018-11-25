/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2012, OpenRemote Inc.
 *
 * See the contributors.txt file in the distribution for a
 * full listing of individual contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#import <WebKit/WebKit.h>
#import "WebSubController.h"
#import "ORControllerClient/ORWebView.h"
#import "SensorStatusCache.h"

static void *const WebSubControllerKVOContext = (void *) &WebSubControllerKVOContext;

@interface WebSubController ()

@property (nonatomic, readwrite, strong) WKWebView *view;
@property (weak, nonatomic, readonly) ORWebView *web;
@property (nonatomic, strong) NSString *oldStatus;

- (void)loadRequestForURL:(NSString *)url;

@end

@implementation WebSubController

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent {
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        self.view = [[WKWebView alloc] initWithFrame:CGRectZero];
        [self loadRequestForURL:self.web.src];

        [self.web addObserver:self forKeyPath:@"src" options:NSKeyValueObservingOptionNew context:WebSubControllerKVOContext];
    }

    return self;
}

- (void)dealloc {
    [self.web removeObserver:self forKeyPath:@"src"];
}


- (ORWebView *)web {
    return (ORWebView *) self.component;
}

- (void)loadRequestForURL:(NSString *)url {
    ORWebView *webModel = self.web;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    // If a username if provided in the config, use that for authentication
    if (webModel.username != nil && ![@"" isEqualToString:webModel.username]) {
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", webModel.username, webModel.password] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authString = [authData base64EncodedStringWithOptions:0];
        authString = [NSString stringWithFormat:@"Basic %@", authString];
        [request setValue:authString forHTTPHeaderField:@"Authorization"];
    }

    [self.view loadRequest:request];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == WebSubControllerKVOContext) {
        if ([@"src" isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadRequestForURL:self.web.src];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@synthesize view;
@synthesize oldStatus;

@end