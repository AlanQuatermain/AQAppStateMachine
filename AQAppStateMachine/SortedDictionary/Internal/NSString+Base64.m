#import "NSString+Base64.h"
#import "common.h"


@implementation NSString (Base64)


static NSString *base64chars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";


- (NSData *) decodeBase64 {
	int				length	= [self length];
	NSMutableData	*data	= [[NSMutableData alloc] initWithCapacity: length  * 3 / 4];
	
	for (int i = 0; i < length; i += 4) {
		Byte quad[4];
		Byte triplet[3];
		
		quad[0] = [base64chars rangeOfString: [self substringWithRange: NSMakeRange(i    , 1)]].location;
		quad[1] = [base64chars rangeOfString: [self substringWithRange: NSMakeRange(i + 1, 1)]].location;
		quad[2] = [base64chars rangeOfString: [self substringWithRange: NSMakeRange(i + 2, 1)]].location;
		quad[3] = [base64chars rangeOfString: [self substringWithRange: NSMakeRange(i + 3, 1)]].location;
		
		triplet[0] = (quad[0] << 2) | (quad[1] >> 4);
		triplet[1] = ((quad[1] & 15) << 4) | (quad[2] >> 2);
		triplet[2] = ((quad[2] & 3) << 6) | quad[3];
		
		[data appendBytes: triplet length: (quad[2] != 64) ? ((quad[3] != 64) ? 3 : 2) : 1];
	}
	
	return data;
}


+ (id) encodeBase64: (NSData *) data {
	int				length	= [data length];
	NSMutableString *base64 = [[NSMutableString alloc] init];
	
	for (int i = 0; i < length; i += 3) {
		Byte	triplet[3];
		unichar	quad[4];
		
		triplet[1] = triplet[2] = 0;
		[data getBytes: triplet range: NSMakeRange(i, min(3, length - i))];

		quad[0] = [base64chars characterAtIndex: triplet[0] >> 2];
		quad[1] = [base64chars characterAtIndex: ((triplet[0] & 3) << 4) | (triplet[1] >> 4)];
		quad[2] = [base64chars characterAtIndex: ((triplet[1] & 15) << 2) | (triplet[2] >> 6)];
		quad[3] = [base64chars characterAtIndex: triplet[2] & 63];
		
		if (i + 1 >= length) { quad[2] = '='; }
		if (i + 2 >= length) { quad[3] = '='; }
		
		[base64 appendString: [NSString stringWithCharacters: quad length: 4]];
	}
	
	return base64;
}


@end
