/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2013, OpenRemote Inc.
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

#import "ImageCache.h"

@interface ImageCache ()

@property (nonatomic, strong) NSString *cachePath;

@property (nonatomic) dispatch_queue_t loadersQueue;
@property (atomic) dispatch_queue_t serialQueue;

/**
 * Keep track of load operations that are active.
 * Key is the name of image to load.
 * Value is an array of availability blocks to be called once operation is finished.
 */
@property (nonatomic, strong) NSMutableDictionary *activeLoad;

@end

@implementation ImageCache

- (id)initWithCachePath:(NSString *)path
{
    self = [super init];
    if (self) {
        BOOL isDirectory;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        
        if (!fileExists) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL]) {
                return nil;
            }
            
        } else {
            if (!isDirectory) {
                return nil;
            }
        }
        self.cachePath = path;
        self.loadersQueue = dispatch_queue_create("org.openremote.imagecache.loader", DISPATCH_QUEUE_CONCURRENT);
        self.serialQueue = dispatch_queue_create("org.openremote.imagecache.serial", DISPATCH_QUEUE_SERIAL);
        self.activeLoad = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    if (self.loadersQueue) {
        self.loadersQueue = NULL;
    }
    if (self.serialQueue) {
        self.serialQueue = NULL;
    }
}

// TODO: will fail if not image -> should inform user about it -> return NO ? exception ?
- (void)storeImage:(UIImage *)image named:(NSString *)name
{
    BOOL v = [UIImagePNGRepresentation(image) writeToFile:[self cacheFilePathForName:name] atomically:YES];
    NSLog(v ? @"YES" : @"NO");
}

- (UIImage *)getImageNamed:(NSString *)name
{
	NSString *path = [self cacheFilePathForName:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}

- (void)notifyImageAvailability:(NSString *)imageName
{
    dispatch_sync(self.serialQueue, ^{
        UIImage *finalImage = [self getImageNamed:imageName];
        
        NSLog(@"Will notify %lu of %@ availability", (unsigned long)[[self.activeLoad objectForKey:imageName] count], imageName);
        
        for (ImageAvailableBlock block in [self.activeLoad objectForKey:imageName]) {
            block(finalImage);
        }
        [self.activeLoad removeObjectForKey:imageName];
    });
}

- (UIImage *)getImageNamed:(NSString *)name finalImageAvailable:(ImageAvailableBlock)availableBlock
{
    __block UIImage *image = nil;
    
    // This whole code is on a serial queue, this ensures that checking if an image is already cached,
    // started the loading process if required and notifying callers when image is available is atomic.
    dispatch_sync(self.serialQueue, ^{
        if ([self isImageAvailableNamed:name]) {
            image = [self getImageNamed:name];
        } else if (self.loader) {
            NSLog(@"Must load image named %@", name);
            NSMutableArray *loaders = [self.activeLoad objectForKey:name];
            
            if (loaders) {
                // This image is already being loaded, just register to be notified when done
                [loaders addObject:availableBlock];
            } else {
                // First time the image is requested, ask the loader for it
                loaders = [NSMutableArray arrayWithObject:availableBlock];
                [self.activeLoad setObject:loaders forKey:name];
                if ([self.loader respondsToSelector:@selector(loadImageNamed:toPath:available:)]) {
                    
                    
                    // TODO: handle fact that there might be loader error -> loading queue should be clear + notification ?
                    
                    dispatch_async(self.loadersQueue, ^{
                        [self.loader loadImageNamed:name toPath:self.cachePath available:^{
                            [self notifyImageAvailability:name];
                        }];
                    });
                } else if ([self.loader respondsToSelector:@selector(loadImageNamed:available:)]) {
                    dispatch_async(self.loadersQueue, ^{
                        [self.loader loadImageNamed:name available:^(UIImage *image) {
                            [self storeImage:image named:name];
                            [self notifyImageAvailability:name];
                        }];
                    });
                } else {
                    // TODO: should there be an error if loader can not provide image ? -> at least should be logged
                }
            }
        }
    });
    return image;
}

- (BOOL)isImageAvailableNamed:(NSString *)name
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cacheFilePathForName:name]];
}

- (void)forgetImageNamed:(NSString *)name
{
    // TODO: handle error -> later, will have to log
    
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFilePathForName:name] error:NULL];
}

- (void)forgetAllImages
{
    NSArray *images = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cachePath error:NULL];
    for (NSString *image in images) {
        [[NSFileManager defaultManager] removeItemAtPath:[self cacheFilePathForName:image] error:NULL];
    }
}

- (NSString *)cacheFilePathForName:(NSString *)name
{
    return [self.cachePath stringByAppendingPathComponent:name];
}

@end
