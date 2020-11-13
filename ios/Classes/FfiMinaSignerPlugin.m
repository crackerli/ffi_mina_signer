#import "FfiMinaSignerPlugin.h"
#if __has_include(<ffi_mina_signer/ffi_mina_signer-Swift.h>)
#import <ffi_mina_signer/ffi_mina_signer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ffi_mina_signer-Swift.h"
#endif

@implementation FfiMinaSignerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFfiMinaSignerPlugin registerWithRegistrar:registrar];
}
@end
