
// Sample code originally posted on 
// http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk


#import <Foundation/Foundation.h>

/**
 * Base64 encoding util.
 */
@interface NSString (NSStringAdditions)

- (NSString *)escapeXmlEntities;

- (NSString *)unescapeXmlEntities;
@end
