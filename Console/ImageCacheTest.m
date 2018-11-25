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

#import <XCTest/XCTest.h>
#import "ImageCache.h"
#import "MockImageLoaderWithNoStorageToFile.h"
#import "MockImageLoaderStoringToFile.h"

#define IMAGE_NAME1 @"Image1"
#define IMAGE_NAME2 @"Image2"

@interface ImageCacheTest : XCTestCase

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, retain) ImageCache *cache;
@property (nonatomic, retain) UIImage *image1;

@end

@implementation ImageCacheTest

- (void)setUp
{
    self.cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    self.cache = [[ImageCache alloc] initWithCachePath:self.cachePath];
    self.image1 = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[ImageCacheTest class]] pathForResource:@"openremote" ofType:@"png"]];
}

- (void)tearDown
{
    self.image1 = nil;
    self.cache = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:NULL];
    self.cachePath = nil;
}

- (void)testInitWithNonExistentCachePath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    ImageCache *cache = [[ImageCache alloc] initWithCachePath:path];
    XCTAssertNotNil(cache, @"Cache should have been created");
    BOOL isDirectory;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory], @"Cache should have created its cache folder");
    XCTAssertTrue(isDirectory, @"Created cache folder should be a directory");
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testInitWithNonExistentCachePathNoAccess
{
    NSString *parentPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    [[NSFileManager defaultManager] createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions : @444} error:NULL];
    NSString *path = [parentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    ImageCache *cache = [[ImageCache alloc] initWithCachePath:path];
    XCTAssertNil(cache, @"Cache should have not been created as folder creation was forbidden");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL], @"Cache folder should not have been created");
    [[NSFileManager defaultManager] removeItemAtPath:parentPath error:NULL];
}

- (void)testInitWithExistentFolderPath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    ImageCache *cache = [[ImageCache alloc] initWithCachePath:path];
    XCTAssertNotNil(cache, @"Cache should have been created");
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testInitWithExistentFilePath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", arc4random()]];
    [@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    ImageCache *cache = [[ImageCache alloc] initWithCachePath:path];
    XCTAssertNil(cache, @"Cache should have not been created as a file exists at its location");
    BOOL isDirectory;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory], @"Cache should not have removed the existing file");
    XCTAssertFalse(isDirectory, @"Cache should not have changed existing file to folder");
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testGetNonAvailableImage
{
    XCTAssertNil([self.cache getImageNamed:IMAGE_NAME1], @"Getting non available image should return nil");
    XCTAssertFalse([self.cache isImageAvailableNamed:IMAGE_NAME1], @"Non available image should be reported as such");
}

- (void)testStoreAndRetrieveImage
{
    [self.cache storeImage:self.image1 named:IMAGE_NAME1];
    XCTAssertNotNil([self.cache getImageNamed:IMAGE_NAME1], @"Getting existing image should not return nil");
    XCTAssertEqualObjects(UIImagePNGRepresentation(self.image1), UIImagePNGRepresentation([self.cache getImageNamed:IMAGE_NAME1]),
                         @"Retrieved image should be registered one");
    XCTAssertTrue([self.cache isImageAvailableNamed:IMAGE_NAME1], @"Available image should be reported as such");
    XCTAssertNil([self.cache getImageNamed:IMAGE_NAME2], @"Getting non available image should return nil");
}

- (void)testGetNotYetCachedImageLoadedViaLoader
{
    MockImageLoaderWithNoStorageToFile *loader = [[MockImageLoaderWithNoStorageToFile alloc] init];
    loader.imageToReturn = self.image1;
    self.cache.loader = loader;
    
    __block UIImage *providedImage = nil;
    UIImage *initialImage = [self.cache getImageNamed:IMAGE_NAME1 finalImageAvailable:^(UIImage *image) {
        providedImage = image;
        XCTAssertNotNil(providedImage, @"Once image has been loaded, it should not be nil");
        XCTAssertEqualObjects(UIImagePNGRepresentation(self.image1), UIImagePNGRepresentation(providedImage), @"Retrieved image should be loaded one");
        XCTAssertTrue([self.cache isImageAvailableNamed:IMAGE_NAME1], @"After being loaded, image should be reported as available");
        XCTAssertNotNil([self.cache getImageNamed:IMAGE_NAME1], @"After being loaded, image should be returned imediately when requested");

        self.cache.loader = nil;
    }];
    XCTAssertNil(initialImage, @"Getting non available image should initially return nil");
}

- (void)testGetNotYetCachedImageLoadedViaLoaderWithFileStorage
{
    MockImageLoaderStoringToFile *loader = [[MockImageLoaderStoringToFile alloc] init];
    loader.imageToReturn = self.image1;
    self.cache.loader = loader;
    
    __block UIImage *providedImage = nil;
    UIImage *initialImage = [self.cache getImageNamed:IMAGE_NAME1 finalImageAvailable:^(UIImage *image) {
        providedImage = image;
        XCTAssertNil(initialImage, @"Getting non available image should initially return nil");
        XCTAssertNotNil(providedImage, @"Once image has been loaded, it should not be nil");
        XCTAssertEqualObjects(UIImagePNGRepresentation(self.image1), UIImagePNGRepresentation(providedImage), @"Retrieved image should be loaded one");
        XCTAssertTrue([self.cache isImageAvailableNamed:IMAGE_NAME1], @"After being loaded, image should be reported as available");
        XCTAssertNotNil([self.cache getImageNamed:IMAGE_NAME1], @"After being loaded, image should be returned imediately when requested");
        
        self.cache.loader = nil;
    }];
}

- (void)testForgetImage
{
    [self.cache storeImage:self.image1 named:IMAGE_NAME1];
    [self.cache forgetImageNamed:IMAGE_NAME1];
    XCTAssertNil([self.cache getImageNamed:IMAGE_NAME1], @"Getting forgotten image should return nil");
    XCTAssertFalse([self.cache isImageAvailableNamed:IMAGE_NAME1], @"Forgotten image should be reported as not available");
}

- (void)testForgetAllImages
{
    [self.cache storeImage:self.image1 named:IMAGE_NAME1];
    UIImage *anotherImage = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[ImageCacheTest class]] pathForResource:@"openremote" ofType:@"png"]];
    [self.cache storeImage:anotherImage named:IMAGE_NAME2];
    XCTAssertNotNil([self.cache getImageNamed:IMAGE_NAME1], @"Getting existing image should not return nil");
    XCTAssertNotNil([self.cache getImageNamed:IMAGE_NAME2], @"Getting existing image should not return nil");
    [self.cache forgetAllImages];
    XCTAssertNil([self.cache getImageNamed:IMAGE_NAME1], @"Getting forgotten image should return nil");
    XCTAssertNil([self.cache getImageNamed:IMAGE_NAME2], @"Getting forgotten image should return nil");
}

@end
