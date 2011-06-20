#import "NSStringExtensionsTests.h"
#import "NSString+Base64.h"


@implementation NSStringExtensionsTests


- (void) testDecodeBase64 {
	STAssertEqualObjects(
		@"A house divided against itself cannot stand",
		[[NSString alloc] initWithData: [@"QSBob3VzZSBkaXZpZGVkIGFnYWluc3QgaXRzZWxmIGNhbm5vdCBzdGFuZA==" decodeBase64] encoding: NSASCIIStringEncoding],
		@"Expected equal string");
}


- (void) testEncodeBase64 {
	STAssertEqualObjects(
		@"QSBob3VzZSBkaXZpZGVkIGFnYWluc3QgaXRzZWxmIGNhbm5vdCBzdGFuZA==",
		[NSString encodeBase64: [@"A house divided against itself cannot stand" dataUsingEncoding: NSASCIIStringEncoding]],
		@"Expected equal strings");
}


@end
