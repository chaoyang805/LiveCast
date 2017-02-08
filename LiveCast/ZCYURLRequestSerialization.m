//
//  ZCYURLRequestSerialization.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/6.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYURLRequestSerialization.h"

NSString * ZCYPercentEscapingStringFromString(NSString *string) {
    static NSString * const kZCYCharactersGeneralDelimitersToEncode = @":#[]@";
    static NSString * const kZCYCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kZCYCharactersGeneralDelimitersToEncode stringByAppendingString:kZCYCharactersSubDelimitersToEncode]];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    
    NSMutableString *escaped = [@"" mutableCopy];
    while (index < string.length) {
        
        NSUInteger length = MIN(string.length - index, batchSize);
        
        NSRange range = NSMakeRange(index, length);
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        NSString *subString = [string substringWithRange:range];
        NSString *encoded = [subString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        
        [escaped appendString:encoded];
        index += range.length;
    }
    
    return escaped;
}

static NSArray * ZCYHTTPRequestSerializerObservedKeyPaths() {
    static NSArray *_ZCYHTTPRequestSerializerObservedKeyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ZCYHTTPRequestSerializerObservedKeyPaths = @[NSStringFromSelector(@selector(allowsCellularAccess)),
                                                      NSStringFromSelector(@selector(cachePolicy)),
                                                      NSStringFromSelector(@selector(HTTPShouldHandleCookies)),
                                                      NSStringFromSelector(@selector(HTTPShouldUsePipelining)),
                                                      NSStringFromSelector(@selector(networkServiceType)),
                                                      NSStringFromSelector(@selector(timeoutInterval))
                                                      ];
    });
    return _ZCYHTTPRequestSerializerObservedKeyPaths;
}
static void *ZCYHTTPRequestSerializerObserverContext = &ZCYHTTPRequestSerializerObserverContext;

@interface ZCYQueryStringPair: NSObject

@property (nonatomic, strong) id field;
@property (nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;
- (NSString *)URLEncodedStringValue;

@end

@implementation ZCYQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (self) {
        self.field = field;
        self.value = value;
    }
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return ZCYPercentEscapingStringFromString(self.field);
    }
    return [NSString stringWithFormat:@"%@=%@", ZCYPercentEscapingStringFromString(self.field), ZCYPercentEscapingStringFromString(self.value)];
}

@end

FOUNDATION_EXPORT NSArray * ZCYQueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * ZCYQueryStringPairsFromKeyAndValue(NSString * key, id value);

NSString * ZCYQueryStringFromParameters(NSDictionary *parameters) {
    
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (ZCYQueryStringPair *pair in ZCYQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * ZCYQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return ZCYQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * ZCYQueryStringPairsFromKeyAndValue(NSString * key, id value) {
    
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dictionary = value;
        for (id nestedKey in [[dictionary allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:
                 ZCYQueryStringPairsFromKeyAndValue(
                                                    (key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey),
                                                    nestedValue
                                                    )
                 ];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:ZCYQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            [mutableQueryStringComponents addObjectsFromArray:ZCYQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[ZCYQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
    
}

@interface ZCYHTTPRequestSerializer ()

@property (nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;

@property (nonatomic, strong) NSMutableSet *mutableObservedChangedKeyPaths;

@end

@implementation ZCYHTTPRequestSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    self.mutableHTTPRequestHeaders = [NSMutableDictionary dictionary];
    
    // Accept-Language Header field
    NSMutableArray *acceptedLanguagesComponents = [NSMutableArray array];
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        float q = 1.0f - (idx * 0.1f);
        [acceptedLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
        *stop = q <= 0.5f;
    }];
    
    [self setValue:[acceptedLanguagesComponents componentsJoinedByString:@", "] forHTTPHeaderField:@"Accept-Language"];
    
    // User-Agent Header field
    NSString *userAgent = nil;
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)",
                 /* bundle executable */ [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?:
                 /* bundle identifier */[[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey],
                 /* bundle version */[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey],
                 /* device model */[[UIDevice currentDevice] model],
                 /* device system version */[[UIDevice currentDevice] systemVersion],
                 /* screen scale */[[UIScreen mainScreen] scale]
                 ];
    
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)mutableUserAgent, NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        
        [self setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    self.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    
    self.mutableObservedChangedKeyPaths = [NSMutableSet set];
    for (NSString *keyPath in ZCYHTTPRequestSerializerObservedKeyPaths()) {
        if ([self respondsToSelector:NSSelectorFromString(keyPath)]) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:ZCYHTTPRequestSerializerObserverContext];
        }
    }
    return self;
}

- (void)dealloc {
    for (NSString *keyPath in ZCYHTTPRequestSerializerObservedKeyPaths()) {
        if ([self respondsToSelector:NSSelectorFromString(keyPath)]) {
            [self removeObserver:self forKeyPath:keyPath context:ZCYHTTPRequestSerializerObserverContext];
        }
    }
}

#pragma mark - 

- (void)setAllowsCellularAccess:(BOOL)allowsCellularAccess {
    [self willChangeValueForKey:NSStringFromSelector(@selector(allowsCellularAccess))];
    _allowsCellularAccess = allowsCellularAccess;
    [self didChangeValueForKey:NSStringFromSelector(@selector(allowsCellularAccess))];
}

- (void)setHTTPShouldHandleCookies:(BOOL)HTTPShouldHandleCookies {
    [self willChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldHandleCookies))];
    _HTTPShouldHandleCookies = HTTPShouldHandleCookies;
    [self didChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldHandleCookies))];
}

- (void)setHTTPShouldUsePipelining:(BOOL)HTTPShouldUsePipelining {
    [self willChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldUsePipelining))];
    _HTTPShouldUsePipelining = HTTPShouldUsePipelining;
    [self didChangeValueForKey:NSStringFromSelector(@selector(HTTPShouldUsePipelining))];
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    [self willChangeValueForKey:NSStringFromSelector(@selector(cachePolicy))];
    _cachePolicy = cachePolicy;
    [self didChangeValueForKey:NSStringFromSelector(@selector(cachePolicy))];
}

- (void)setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType {
    [self willChangeValueForKey:NSStringFromSelector(@selector(networkServiceType))];
    _networkServiceType = networkServiceType;
    [self didChangeValueForKey:NSStringFromSelector(@selector(networkServiceType))];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    [self willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    _timeoutInterval = timeoutInterval;
    [self didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
}

#pragma mark -

- (NSDictionary<NSString *,NSString *> *)HTTPRequestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [self.mutableHTTPRequestHeaders setValue:value forKey:field];
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [self.mutableHTTPRequestHeaders valueForKey:field];
}

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password {
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    [self setValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHTTPHeaderField:@"Authorization"];
}

- (void)clearAuthorization {
    [self.mutableHTTPRequestHeaders removeObjectForKey:@"Authorization"];
}

#pragma mark - 

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError * __autoreleasing *)error {
    
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    mutableRequest.HTTPMethod = method;
    
    for (NSString *keyPath in ZCYHTTPRequestSerializerObservedKeyPaths()) {
        if ([self.mutableObservedChangedKeyPaths containsObject:keyPath]) {
            [mutableRequest setValue:[self valueForKeyPath:keyPath] forKey:keyPath];
        }
    }
    
    mutableRequest = [[self requestBySerializingRequest:mutableRequest withParameters:parameters error:error] mutableCopy];

    return mutableRequest;
    
}

#pragma mark ZCYURLRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(nonnull NSURLRequest *)request withParameters:(nullable id)parameters error:(NSError *__autoreleasing _Nullable *)error {
    
    NSParameterAssert(request);
    
    // Set Http headers
    NSMutableURLRequest *mutableRequest = [request copy];
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    // Concat query string
    NSString *query = nil;
    
    // TODO - queryStringSerialization
    if (parameters) {
        query = ZCYQueryStringFromParameters(parameters);
    }
    
    // encode query in url if should
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[mutableRequest.HTTPMethod uppercaseString]]) {
        if (query && query.length > 0) {
            
            NSString *originURLString = mutableRequest.URL.absoluteString;
            mutableRequest.URL = [NSURL URLWithString:
                                  [originURLString stringByAppendingFormat:
                                   mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    } else {
        if (!query) {
            query = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        mutableRequest.HTTPBody = [query dataUsingEncoding:self.stringEncoding];
    }
    
    return mutableRequest;
}

#pragma mark NSKeyValueObserving
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([ZCYHTTPRequestSerializerObservedKeyPaths() containsObject:key]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == ZCYHTTPRequestSerializerObserverContext) {
        if ([change[NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            [self.mutableObservedChangedKeyPaths removeObject:keyPath];
        } else {
            [self.mutableObservedChangedKeyPaths addObject:keyPath];
        }
    }
}

@end







