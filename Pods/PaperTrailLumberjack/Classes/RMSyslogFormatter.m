//
//  RMSyslogFormatter.m
//  Pods
//
//  Created by Malayil Philip George on 5/7/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All
//  rights reserved.
//
//

#import "RMSyslogFormatter+Private.h"
#import "NSString+RMPaperTrailLumberjack.h"

static NSString* const RMAppUUIDKey = @"RMAppUUIDKey";

@implementation RMSyslogFormatter

@synthesize machineName=_machineName;
@synthesize programName=_programName;

-(id) init
{
    self = [super init];
    if (self) {
        _machineName = nil;
        _programName = nil;
    }
    
    return self;
}

- (NSString*)formatLogMessage:(DDLogMessage*)logMessage
{
    NSString* msg = logMessage.message;
    
    NSString* logLevel;
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel = @"11";
            break;
        case DDLogFlagWarning:
            logLevel = @"12";
            break;
        case DDLogFlagInfo:
            logLevel = @"14";
            break;
        case DDLogFlagDebug:
            logLevel = @"15";
            break;
        case DDLogFlagVerbose:
            logLevel = @"15";
            break;
        default:
            logLevel = @"15";
            break;
    }
    
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd HH:mm:ss"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    });
    
    NSString* timestamp = [dateFormatter stringFromDate:logMessage.timestamp];

    NSString* function = [self formatFunctionName:logMessage.function];
    NSString* log =
    [NSString stringWithFormat:@"<%@>%@ %@ %@: %@ %@@%@%lu] \"%@\"",
     logLevel, timestamp, self.machineName,
     self.programName, logMessage.threadID, logMessage.fileName,
     function, (unsigned long)logMessage.line, msg];

    
    return log;
}

-(NSString*) formatFunctionName:(NSString*) functionName
{
    NSString* formattedName = functionName;
    if ([formattedName hasPrefix:@"-"]) {
        formattedName = [formattedName substringFromIndex:1];
    }
    if ([formattedName hasSuffix:@"]"]) {
        formattedName = [formattedName substringToIndex:formattedName.length-1];
    }
    
    return formattedName;
}

-(void) setMachineName:(NSString *)machineName
{
    _machineName = [machineName stringByRemovingAllWhitespace];
}

- (NSString*)machineName
{
    if (_machineName == nil) {
        // We will generate and use a app-specific UUID to maintain user privacy.
        NSString* uuid =
        [[NSUserDefaults standardUserDefaults] stringForKey:RMAppUUIDKey];
        if (uuid == nil) {
            uuid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:uuid
                                                      forKey:RMAppUUIDKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _machineName = uuid;
    }
    
    return _machineName;
}

-(void) setProgramName:(NSString *)programName
{
    _programName = [programName stringByRemovingAllWhitespace];
}

- (NSString*)programName
{
    if (_programName == nil) {
        NSString* bundleName = [[[NSBundle mainBundle] localizedInfoDictionary]
                                objectForKey:@"CFBundleDisplayName"];
        if (bundleName == nil) {
            bundleName = [[[NSBundle mainBundle] infoDictionary]
                          objectForKey:@"CFBundleDisplayName"];
        }
        
        // Remove all whitespace characters from appname
        _programName = [bundleName stringByRemovingAllWhitespace];
    }
    
    return _programName;
}

@end
