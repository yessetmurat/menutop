//
//  IOReport.h
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

// The parts of the private libIOReport this app uses, as `mactop` and other Apple Silicon
// monitors declare them. The library ships with macOS but has no public header.

#include <CoreFoundation/CoreFoundation.h>

CF_ASSUME_NONNULL_BEGIN

/// The channels of `group` (and `subgroup`, when given) as a channel description dictionary.
CFMutableDictionaryRef _Nullable IOReportCopyChannelsInGroup(
    CFStringRef group,
    CFStringRef _Nullable subgroup,
    uint64_t a,
    uint64_t b,
    uint64_t c
) CF_RETURNS_RETAINED;

/// A subscription to `channels`; `subscribed` receives the channels actually subscribed.
CFTypeRef _Nullable IOReportCreateSubscription(
    const void * _Nullable a,
    CFMutableDictionaryRef channels,
    CFMutableDictionaryRef _Nullable * _Nonnull subscribed,
    uint64_t channelID,
    CFTypeRef _Nullable b
) CF_RETURNS_RETAINED;

/// The current values of every subscribed channel.
CFDictionaryRef _Nullable IOReportCreateSamples(
    CFTypeRef subscription,
    CFMutableDictionaryRef subscribed,
    CFTypeRef _Nullable a
) CF_RETURNS_RETAINED;

/// The change of every channel from `previous` to `current`.
CFDictionaryRef _Nullable IOReportCreateSamplesDelta(
    CFDictionaryRef previous,
    CFDictionaryRef current,
    CFTypeRef _Nullable a
) CF_RETURNS_RETAINED;

CFStringRef _Nullable IOReportChannelGetChannelName(CFDictionaryRef channel) CF_RETURNS_NOT_RETAINED;

CFStringRef _Nullable IOReportChannelGetUnitLabel(CFDictionaryRef channel) CF_RETURNS_NOT_RETAINED;

int64_t IOReportSimpleGetIntegerValue(CFDictionaryRef channel, int32_t index);

CF_ASSUME_NONNULL_END
