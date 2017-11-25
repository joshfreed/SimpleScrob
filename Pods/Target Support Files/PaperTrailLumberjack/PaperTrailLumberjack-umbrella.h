#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+RMPaperTrailLumberjack.h"
#import "PaperTrailLumberjack.h"
#import "RMPaperTrailLogger.h"
#import "RMSyslogFormatter+Private.h"
#import "RMSyslogFormatter.h"

FOUNDATION_EXPORT double PaperTrailLumberjackVersionNumber;
FOUNDATION_EXPORT const unsigned char PaperTrailLumberjackVersionString[];

