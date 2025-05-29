#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * AVEngine provides the core functionality for video editing engine.
 * This class can be used in both Objective-C and Swift.
 */
@interface AVEngine : NSObject

/**
 * Creates an engine instance with the given render plan
 * @param renderPlan The path to the render plan file
 * @return A handle (as NSNumber) if successful, nil if failed
 */
+ (nullable NSNumber *)createEngine:(NSString *)videoFilePath;

@end

NS_ASSUME_NONNULL_END