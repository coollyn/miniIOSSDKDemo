#import "AVEngine.h"
#include "AVEngine.cpp"

@implementation AVEngine

+ (NSNumber *)createEngine:(NSString *)videoFilePath {
    long handle = CreateEngine([videoFilePath UTF8String]);
    return handle != 0 ? @(handle) : nil;
}

@end 