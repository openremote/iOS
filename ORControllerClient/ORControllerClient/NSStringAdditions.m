
// Sample code originally posted on 
// http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk

#import "NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

- (NSString *)escapeXmlEntities
{
	NSString *result = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	result = [result stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
	result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
	result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	result = [result stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	return result;
}

- (NSString *)unescapeXmlEntities
{
	NSString *result = [self stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
	result = [result stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	result = [result stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	result = [result stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	return result;
}

@end
	
