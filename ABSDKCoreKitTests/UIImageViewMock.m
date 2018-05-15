//
//  UIImageViewMock.m
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import "UIImageViewMock.h"

@interface UIImageViewMock ()

@property (nonatomic, strong) UIImage *mockImage;
@property (nonatomic, strong) NSString *mockUrl;

@end

@implementation UIImageViewMock

- (id)initWithMockURL:(NSString*)url image:(UIImage*)image
{
    self = [super init];
    if (self) {
        _mockUrl = url;
        _mockImage = image;
    }
    return self;
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
{
    if ([url.absoluteString isEqualToString:_mockUrl]) {
        self.image = _mockImage;
    }
    else {
        self.image = nil;
    }
}

@end
