#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef KEYRI_SWIFT_H
#define KEYRI_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import AVFoundation;
@import CoreFoundation;
@import Foundation;
@import ObjectiveC;
@import UIKit;
#endif

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="Keyri",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
@class Session;
@class UIView;

SWIFT_CLASS("_TtC5Keyri24ConfirmationScreenUIView") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface ConfirmationScreenUIView : NSObject
- (nonnull instancetype)initWithSession:(Session * _Nonnull)session dismissalDelegate:(void (^ _Nonnull)(BOOL))dismissalDelegate OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly, strong) UIView * _Nonnull view;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSString;

SWIFT_CLASS("_TtC5Keyri7FPError") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface FPError : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull message;
@end


SWIFT_CLASS("_TtC5Keyri10FPLocation") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface FPLocation : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull city;
@property (nonatomic, readonly, copy) NSString * _Nonnull continentCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull continentName;
@property (nonatomic, readonly, copy) NSString * _Nonnull country;
@property (nonatomic, readonly, copy) NSString * _Nonnull countryCode;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly, copy) NSString * _Nonnull region;
@property (nonatomic, readonly, copy) NSString * _Nonnull regionCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull regionType;
@end


SWIFT_CLASS("_TtC5Keyri19FingerprintResponse")
@interface FingerprintResponse : NSObject
@property (nonatomic, readonly, copy) NSString * _Nullable apiCiphertextSignature;
@property (nonatomic, readonly, copy) NSString * _Nullable publicEncryptionKey;
@property (nonatomic, readonly, copy) NSString * _Nullable ciphertext;
@property (nonatomic, readonly, copy) NSString * _Nullable iv;
@property (nonatomic, readonly, copy) NSString * _Nullable salt;
@end


SWIFT_CLASS("_TtC5Keyri11GeoDataPair") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface GeoDataPair : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSURL;
@class NSData;

SWIFT_CLASS("_TtC5Keyri9KeyriObjC") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface KeyriObjC : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)initializeKeyriWithAppKey:(NSString * _Nonnull)appKey publicAPIKey:(NSString * _Nullable)publicAPIKey serviceEncryptionKey:(NSString * _Nullable)serviceEncryptionKey;
- (void)easyKeyriAuthWithPayload:(NSString * _Nonnull)payload publicUserId:(NSString * _Nonnull)publicUserId completion:(void (^ _Nonnull)(BOOL, NSError * _Nullable))completion;
- (void)processLinkWithUrl:(NSURL * _Nonnull)url payload:(NSString * _Nonnull)payload publicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(BOOL, NSError * _Nullable))completion;
- (void)initiateQrSessionWithSessionId:(NSString * _Nonnull)sessionId publicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(Session * _Nullable, NSError * _Nullable))completion;
- (void)initializeDefaultConfirmationScreenWithSession:(Session * _Nonnull)session payload:(NSString * _Nonnull)payload completion:(void (^ _Nonnull)(BOOL))completion;
- (void)generateAssociationKeyWithPublicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)generateUserSignatureWithPublicUserId:(NSString * _Nullable)publicUserId data:(NSData * _Nonnull)data completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)getAssociationKeyWithPublicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)removeAssociationKeyWithPublicUserId:(NSString * _Nonnull)publicUserId completion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (void)listAssociactionKeysWithCompletion:(void (^ _Nonnull)(NSDictionary<NSString *, NSString *> * _Nullable, NSError * _Nullable))completion;
- (void)listUniqueAccountsWithCompletion:(void (^ _Nonnull)(NSDictionary<NSString *, NSString *> * _Nullable, NSError * _Nullable))completion;
- (void)sendEventWithPublicUserId:(NSString * _Nullable)publicUserId eventType:(NSString * _Nonnull)eventType success:(BOOL)success completion:(void (^ _Nonnull)(FingerprintResponse * _Nullable, NSError * _Nullable))completion;
@end

@class NSNumber;

SWIFT_CLASS("_TtC5Keyri12LocationData") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface LocationData : NSObject
@property (nonatomic, copy) NSString * _Nullable countryCode;
@property (nonatomic, copy) NSString * _Nullable city;
@property (nonatomic, copy) NSString * _Nullable continentCode;
@property (nonatomic, copy) NSString * _Nullable regionCode;
@property (nonatomic, readonly, strong) NSNumber * _Nullable latitude;
@property (nonatomic, readonly, strong) NSNumber * _Nullable longitude;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class Template;
@class UserAgent;

SWIFT_CLASS("_TtC5Keyri22MobileTemplateResponse") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface MobileTemplateResponse : NSObject
@property (nonatomic, strong) Template * _Nullable mobile;
@property (nonatomic, strong) Template * _Nullable widget;
@property (nonatomic, strong) UserAgent * _Nullable userAgent;
@property (nonatomic, copy) NSString * _Nonnull title;
@property (nonatomic, copy) NSString * _Nullable message;
@end

@class NSBundle;
@class NSCoder;
@class AVCaptureMetadataOutput;
@class AVMetadataObject;
@class AVCaptureConnection;

SWIFT_CLASS("_TtC5Keyri23QRCodeScannerController")
@interface QRCodeScannerController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationBarDelegate>
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)viewWillAppear:(BOOL)animated;
- (void)captureOutput:(AVCaptureMetadataOutput * _Nonnull)output didOutputMetadataObjects:(NSArray<AVMetadataObject *> * _Nonnull)metadataObjects fromConnection:(AVCaptureConnection * _Nonnull)connection;
@end


@interface QRCodeScannerController (SWIFT_EXTENSION(Keyri))
@property (nonatomic, readonly) BOOL shouldAutorotate;
@property (nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;
@property (nonatomic, readonly) UIInterfaceOrientation preferredInterfaceOrientationForPresentation;
@end


SWIFT_CLASS("_TtC5Keyri13RiskAnalytics") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface RiskAnalytics : NSObject
@property (nonatomic, copy) NSString * _Nullable riskStatus;
@property (nonatomic, copy) NSString * _Nullable riskFlagString;
@property (nonatomic, strong) GeoDataPair * _Nullable geoData;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC5Keyri7Session") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface Session : NSObject
@property (nonatomic, copy) NSString * _Nullable payload;
@property (nonatomic, copy) NSString * _Nullable publicUserId;
@property (nonatomic, copy) NSString * _Nullable appKey;
@property (nonatomic, copy) NSString * _Nonnull sessionId;
- (void)denyWithCompletion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (void)confirmWithCompletion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (BOOL)setNewUserIdWithUserId:(NSString * _Nonnull)userId SWIFT_WARN_UNUSED_RESULT;
@end


SWIFT_CLASS("_TtC5Keyri10SquareView")
@interface SquareView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)drawRect:(CGRect)rect;
@end


SWIFT_CLASS("_TtC5Keyri8Template")
@interface Template : NSObject
@property (nonatomic, copy) NSString * _Nullable location;
@property (nonatomic, copy) NSString * _Nullable issue;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end



SWIFT_CLASS("_TtC5Keyri9UserAgent")
@interface UserAgent : NSObject
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, copy) NSString * _Nullable issue;
@end


SWIFT_CLASS("_TtC5Keyri14UserParameters") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface UserParameters : NSObject
@property (nonatomic, copy) NSString * _Nullable base64EncodedData;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC5Keyri15WidgetUserAgent") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface WidgetUserAgent : NSObject
@property (nonatomic, copy) NSString * _Nonnull electronVersion;
@property (nonatomic) BOOL isDesktop;
@property (nonatomic, copy) NSString * _Nonnull os;
@property (nonatomic, copy) NSString * _Nonnull browser;
@property (nonatomic) BOOL isAuthoritative;
@property (nonatomic, copy) NSString * _Nonnull source;
@property (nonatomic, copy) NSString * _Nonnull version;
@property (nonatomic, copy) NSString * _Nonnull platform;
@property (nonatomic) BOOL isChrome;
@end

#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#elif defined(__x86_64__) && __x86_64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef KEYRI_SWIFT_H
#define KEYRI_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import AVFoundation;
@import CoreFoundation;
@import Foundation;
@import ObjectiveC;
@import UIKit;
#endif

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="Keyri",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
@class Session;
@class UIView;

SWIFT_CLASS("_TtC5Keyri24ConfirmationScreenUIView") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface ConfirmationScreenUIView : NSObject
- (nonnull instancetype)initWithSession:(Session * _Nonnull)session dismissalDelegate:(void (^ _Nonnull)(BOOL))dismissalDelegate OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly, strong) UIView * _Nonnull view;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSString;

SWIFT_CLASS("_TtC5Keyri7FPError") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface FPError : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull message;
@end


SWIFT_CLASS("_TtC5Keyri10FPLocation") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface FPLocation : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull city;
@property (nonatomic, readonly, copy) NSString * _Nonnull continentCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull continentName;
@property (nonatomic, readonly, copy) NSString * _Nonnull country;
@property (nonatomic, readonly, copy) NSString * _Nonnull countryCode;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly, copy) NSString * _Nonnull region;
@property (nonatomic, readonly, copy) NSString * _Nonnull regionCode;
@property (nonatomic, readonly, copy) NSString * _Nonnull regionType;
@end


SWIFT_CLASS("_TtC5Keyri19FingerprintResponse")
@interface FingerprintResponse : NSObject
@property (nonatomic, readonly, copy) NSString * _Nullable apiCiphertextSignature;
@property (nonatomic, readonly, copy) NSString * _Nullable publicEncryptionKey;
@property (nonatomic, readonly, copy) NSString * _Nullable ciphertext;
@property (nonatomic, readonly, copy) NSString * _Nullable iv;
@property (nonatomic, readonly, copy) NSString * _Nullable salt;
@end


SWIFT_CLASS("_TtC5Keyri11GeoDataPair") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface GeoDataPair : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSURL;
@class NSData;

SWIFT_CLASS("_TtC5Keyri9KeyriObjC") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface KeyriObjC : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)initializeKeyriWithAppKey:(NSString * _Nonnull)appKey publicAPIKey:(NSString * _Nullable)publicAPIKey serviceEncryptionKey:(NSString * _Nullable)serviceEncryptionKey;
- (void)easyKeyriAuthWithPayload:(NSString * _Nonnull)payload publicUserId:(NSString * _Nonnull)publicUserId completion:(void (^ _Nonnull)(BOOL, NSError * _Nullable))completion;
- (void)processLinkWithUrl:(NSURL * _Nonnull)url payload:(NSString * _Nonnull)payload publicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(BOOL, NSError * _Nullable))completion;
- (void)initiateQrSessionWithSessionId:(NSString * _Nonnull)sessionId publicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(Session * _Nullable, NSError * _Nullable))completion;
- (void)initializeDefaultConfirmationScreenWithSession:(Session * _Nonnull)session payload:(NSString * _Nonnull)payload completion:(void (^ _Nonnull)(BOOL))completion;
- (void)generateAssociationKeyWithPublicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)generateUserSignatureWithPublicUserId:(NSString * _Nullable)publicUserId data:(NSData * _Nonnull)data completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)getAssociationKeyWithPublicUserId:(NSString * _Nullable)publicUserId completion:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))completion;
- (void)removeAssociationKeyWithPublicUserId:(NSString * _Nonnull)publicUserId completion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (void)listAssociactionKeysWithCompletion:(void (^ _Nonnull)(NSDictionary<NSString *, NSString *> * _Nullable, NSError * _Nullable))completion;
- (void)listUniqueAccountsWithCompletion:(void (^ _Nonnull)(NSDictionary<NSString *, NSString *> * _Nullable, NSError * _Nullable))completion;
- (void)sendEventWithPublicUserId:(NSString * _Nullable)publicUserId eventType:(NSString * _Nonnull)eventType success:(BOOL)success completion:(void (^ _Nonnull)(FingerprintResponse * _Nullable, NSError * _Nullable))completion;
@end

@class NSNumber;

SWIFT_CLASS("_TtC5Keyri12LocationData") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface LocationData : NSObject
@property (nonatomic, copy) NSString * _Nullable countryCode;
@property (nonatomic, copy) NSString * _Nullable city;
@property (nonatomic, copy) NSString * _Nullable continentCode;
@property (nonatomic, copy) NSString * _Nullable regionCode;
@property (nonatomic, readonly, strong) NSNumber * _Nullable latitude;
@property (nonatomic, readonly, strong) NSNumber * _Nullable longitude;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class Template;
@class UserAgent;

SWIFT_CLASS("_TtC5Keyri22MobileTemplateResponse") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface MobileTemplateResponse : NSObject
@property (nonatomic, strong) Template * _Nullable mobile;
@property (nonatomic, strong) Template * _Nullable widget;
@property (nonatomic, strong) UserAgent * _Nullable userAgent;
@property (nonatomic, copy) NSString * _Nonnull title;
@property (nonatomic, copy) NSString * _Nullable message;
@end

@class NSBundle;
@class NSCoder;
@class AVCaptureMetadataOutput;
@class AVMetadataObject;
@class AVCaptureConnection;

SWIFT_CLASS("_TtC5Keyri23QRCodeScannerController")
@interface QRCodeScannerController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationBarDelegate>
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)viewWillAppear:(BOOL)animated;
- (void)captureOutput:(AVCaptureMetadataOutput * _Nonnull)output didOutputMetadataObjects:(NSArray<AVMetadataObject *> * _Nonnull)metadataObjects fromConnection:(AVCaptureConnection * _Nonnull)connection;
@end


@interface QRCodeScannerController (SWIFT_EXTENSION(Keyri))
@property (nonatomic, readonly) BOOL shouldAutorotate;
@property (nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;
@property (nonatomic, readonly) UIInterfaceOrientation preferredInterfaceOrientationForPresentation;
@end


SWIFT_CLASS("_TtC5Keyri13RiskAnalytics") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface RiskAnalytics : NSObject
@property (nonatomic, copy) NSString * _Nullable riskStatus;
@property (nonatomic, copy) NSString * _Nullable riskFlagString;
@property (nonatomic, strong) GeoDataPair * _Nullable geoData;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC5Keyri7Session") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface Session : NSObject
@property (nonatomic, copy) NSString * _Nullable payload;
@property (nonatomic, copy) NSString * _Nullable publicUserId;
@property (nonatomic, copy) NSString * _Nullable appKey;
@property (nonatomic, copy) NSString * _Nonnull sessionId;
- (void)denyWithCompletion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (void)confirmWithCompletion:(void (^ _Nonnull)(NSError * _Nullable))completion;
- (BOOL)setNewUserIdWithUserId:(NSString * _Nonnull)userId SWIFT_WARN_UNUSED_RESULT;
@end


SWIFT_CLASS("_TtC5Keyri10SquareView")
@interface SquareView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)drawRect:(CGRect)rect;
@end


SWIFT_CLASS("_TtC5Keyri8Template")
@interface Template : NSObject
@property (nonatomic, copy) NSString * _Nullable location;
@property (nonatomic, copy) NSString * _Nullable issue;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end



SWIFT_CLASS("_TtC5Keyri9UserAgent")
@interface UserAgent : NSObject
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, copy) NSString * _Nullable issue;
@end


SWIFT_CLASS("_TtC5Keyri14UserParameters") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface UserParameters : NSObject
@property (nonatomic, copy) NSString * _Nullable base64EncodedData;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC5Keyri15WidgetUserAgent") SWIFT_AVAILABILITY(ios,introduced=14.0)
@interface WidgetUserAgent : NSObject
@property (nonatomic, copy) NSString * _Nonnull electronVersion;
@property (nonatomic) BOOL isDesktop;
@property (nonatomic, copy) NSString * _Nonnull os;
@property (nonatomic, copy) NSString * _Nonnull browser;
@property (nonatomic) BOOL isAuthoritative;
@property (nonatomic, copy) NSString * _Nonnull source;
@property (nonatomic, copy) NSString * _Nonnull version;
@property (nonatomic, copy) NSString * _Nonnull platform;
@property (nonatomic) BOOL isChrome;
@end

#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#else
#error unsupported Swift architecture
#endif
