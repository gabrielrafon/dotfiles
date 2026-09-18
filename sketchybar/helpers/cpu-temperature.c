#include <CoreFoundation/CoreFoundation.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

// Apple Silicon thermal API. Match btop's sensor preference:
// eACC/pACC, then PMU tdie, then SOC MTR Temp Sensor.
// https://github.com/aristocratos/btop/blob/v1.4.7/src/osx/sensors.cpp
typedef CFTypeRef HIDClient;
typedef CFTypeRef HIDService;
typedef CFTypeRef HIDEvent;
extern HIDClient IOHIDEventSystemClientCreate(CFAllocatorRef);
extern int IOHIDEventSystemClientSetMatching(HIDClient, CFDictionaryRef);
extern CFArrayRef IOHIDEventSystemClientCopyServices(HIDClient);
extern CFTypeRef IOHIDServiceClientCopyProperty(HIDService, CFStringRef);
extern HIDEvent IOHIDServiceClientCopyEvent(HIDService, int64_t, int32_t, int64_t);
extern double IOHIDEventGetFloatValue(HIDEvent, int32_t);

int main(void) {
    int page = 0xff00, usage = 5;
    CFNumberRef numbers[] = {
        CFNumberCreate(NULL, kCFNumberIntType, &page),
        CFNumberCreate(NULL, kCFNumberIntType, &usage)
    };
    const void *keys[] = { CFSTR("PrimaryUsagePage"), CFSTR("PrimaryUsage") };
    CFDictionaryRef match = CFDictionaryCreate(NULL, keys, (const void **)numbers, 2,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    HIDClient client = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    CFRelease(numbers[0]);
    CFRelease(numbers[1]);
    if (!client) { CFRelease(match); return 1; }
    IOHIDEventSystemClientSetMatching(client, match);
    CFRelease(match);
    CFArrayRef services = IOHIDEventSystemClientCopyServices(client);
    double sums[3] = {0};
    unsigned counts[3] = {0};
    if (services) {
        for (CFIndex i = 0; i < CFArrayGetCount(services); ++i) {
            HIDService service = CFArrayGetValueAtIndex(services, i);
            CFTypeRef product = IOHIDServiceClientCopyProperty(service, CFSTR("Product"));
            char name[256];
            int group = -1;
            if (product && CFGetTypeID(product) == CFStringGetTypeID() &&
                CFStringGetCString(product, name, sizeof(name), kCFStringEncodingUTF8)) {
                if (!strncmp(name, "eACC", 4) || !strncmp(name, "pACC", 4)) group = 0;
                else if (!strncmp(name, "PMU tdie", 8)) group = 1;
                else if (!strncmp(name, "SOC MTR Temp Sensor", 19)) group = 2;
            }
            if (product) CFRelease(product);
            if (group < 0) continue;
            HIDEvent event = IOHIDServiceClientCopyEvent(service, 15, 0, 0);
            if (!event) continue;
            double temperature = IOHIDEventGetFloatValue(event, 15 << 16);
            CFRelease(event);
            if (isfinite(temperature) && temperature > 0 && temperature < 150) {
                sums[group] += temperature;
                counts[group]++;
            }
        }
        CFRelease(services);
    }
    CFRelease(client);
    for (int group = 0; group < 3; ++group) {
        if (counts[group]) {
            printf("%.1f\n", sums[group] / counts[group]);
            return 0;
        }
    }
    return 1;
}
