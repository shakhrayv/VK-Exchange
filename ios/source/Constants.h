
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "gistfile1.m"

//User defaults keys
extern NSString *const NSUDEFAULTS_KEY_PHOTO_QUEUE;
extern NSString *const NSUDEFAULTS_KEY_WALL_POSTS;
extern NSString *const NSUDEFAULTS_KEY_ACCESS_TOKEN;
extern NSString *const NSUDEFAULTS_KEY_USER_INFO;
extern NSString *const NSUDEFAULTS_KEY_USER_ID;
extern NSString *const NSUDEFAULTS_KEY_BALANCE;
extern NSString *const NSUDEFAULTS_KEY_SUBSCRIBERS_BRIEF;
extern NSString *const NSUDEFAULTS_KEY_LIKES_BRIEF;
extern NSString *const NSUDEFAULTS_KEY_REPOSTS_BRIEF;
extern NSString *const NSUDEFAULTS_KEY_IS_PRIVILEGED;
extern NSString *const NSUDEFAULTS_KEY_SHOP_PRICES;
extern NSString *const NSUDEFAULTS_KEY_SALES_HIT;
extern NSString *const NSUDEFAULTS_KEY_SALES;

extern NSString *const NSUDEFAULTS_KEY_GET_LIKES_WELCOME_SHOWN;
extern NSString *const NSUDEFAULTS_KEY_GET_SUBSCRIBERS_WELCOME_SHOWN;
extern NSString *const NSUDEFAULTS_KEY_GET_MONEY_WELCOME_SHOWN;
extern NSString *const NSUDEFAULTS_KEY_SHOP_WELCOME_SHOWN;
extern NSString *const NSUDEFAULTS_KEY_SETTINGS_WELCOME_SHOWN;
extern NSString *const NSUDEFAULTS_KEY_REPOSTS_WELCOME_SHOWN;

extern NSString *const NSUDEFAULTS_KEY_SHOULD_REWARD;
extern NSString *const NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN;

//Settings
extern NSString *const SETTINGS_KEY_TRAFFIC_ECONOMY;
extern NSString *const SETTINGS_KEY_LOAD_IMAGES;
extern NSString *const SETTINGS_KEY_TURBO;
extern BOOL const SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY;
extern BOOL const SETTINGS_DEFAULT_VALUE_LOAD_IMAGES;
extern BOOL const SETTINGS_DEFAULT_VALUE_TURBO;

//Shop
extern NSString* const DEFAULT_PRICE_PACK_1;
extern NSString* const DEFAULT_PRICE_PACK_2;
extern NSString* const DEFAULT_PRICE_PACK_3;
extern NSString* const DEFAULT_PRICE_PACK_4;
extern NSString* const DEFAULT_PRICE_PACK_5;
extern NSString* const DEFAULT_PRICE_PACK_6;
extern NSString* const DEFAULT_PRICE_PACK_7;
extern NSString* const DEFAULT_PRICE_PACK_7S;
extern int AD_AVAILABLE;

//Constants
extern int const MAX_PROFILE_PHOTOS;
extern int const MAX_WALL_PHOTOS;
extern int const MAX_WALL_POSTS;
extern NSString *const VK_APP_ID;
extern NSString *const NSUDEFAULTS_KEY_APP_VERSION;
extern NSString *const AD_ID;
extern int AD_REWARD;
extern NSString *const AS_APP_ID;

//Server-related variables
extern NSString *const SERVER_URL;
extern NSString *const SERVER_REQUEST_LIKES_ON_PHOTO_PATH;
extern NSString *const SERVER_REQUEST_REPOSTS_PATH;
extern NSString *const SERVER_USER_PURCHASED_MONEY_PACK_PATH;
extern NSString *const SERVER_GET_TASK_PATH;
extern NSString *const SERVER_COMPLETE_TASK_PATH;
extern NSString *const SERVER_REQUEST_SUBSCRIBERS_PATH;
extern NSString *const SERVER_REQUEST_TOTALS_PATH;
extern NSString *const SERVER_REQUEST_PRIVILEGE_PATH;
extern NSString *const SERVER_REQUEST_GET_INFO_PATH;
extern NSString *const SERVER_REQUEST_SALES_HIT_INFORMATION_PATH;
extern NSString *const SERVER_REQUEST_SALES_INFORMATION_PATH;
extern NSString *const SERVER_REQUEST_AD_STATUS_PATH;
extern int const SERVER_PRIVILEGE_MAX_ATTEMPTS;

//Internet
extern NSTimeInterval const SERVER_TIMEOUT;
extern NSInteger const VK_TIMEOUT;
extern NSTimeInterval const TIME_TILL_UNLOCK;

//Constraints
extern CGFloat const GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT;
extern CGFloat const GET_LIKES_CONSTRAINT_PHOTO_OFFSET;
extern CGFloat const GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT;
extern CGFloat const TABLE_VIEW_STANDARD_ROW_HEIGHT;
extern CGFloat const TABLE_VIEW_STANDARD_LEFT_OFFSET;
extern CGFloat const TABLE_VIEW_STANDARD_RIGHT_OFFSET;
extern CGFloat const SELECTED_VIEW_HEIGHT;
extern CGFloat const LOGIN_BUTTON_WIDTH;
extern CGFloat const LOGIN_BUTTON_HEIGHT;
extern CGFloat const LOGIN_BUTTON_OFFSET_BOTTOM;
extern CGFloat const REPOSTS_ROW_HEIGHT;

//Animations duration
extern NSTimeInterval const ANIMATIONS_DURATION_05X;
extern NSTimeInterval const ANIMATIONS_DURATION_1X;
extern NSTimeInterval const ANIMATIONS_DURATION_2X;
extern NSTimeInterval const ANIMATIONS_DURATION_4X;
extern NSTimeInterval const ANIMATIONS_DURATION_1S;

//GBStorage constants
extern NSString *const GBSTORAGE_DEFAULT_NAMESPACE;
extern NSString *const GBSTORAGE_PHOTO_MAX_SQUARED;

//Contact email
extern NSString *const CONTACT_EMAIL;

//Flurry
extern NSString *const FLURRY_APP_KEY;

//VK
extern NSString *const VK_FOLLOW_STANDARD_TEXT;

//Animations
extern CGFloat const ANIM_VIEW_KOEF;
extern CGFloat const ANIM_ACCELERATION_MOD;
extern CGFloat const ANIM_MIN_VELOCITY;

//Text constants
extern NSString *const TEXT_GET_LIKES_WELCOME_TITLE;
extern NSString *const TEXT_GET_LIKES_WELCOME_TEXT;
extern NSString *const TEXT_GET_SUBSCRIBERS_WELCOME_TITLE;
extern NSString *const TEXT_GET_SUBSCRIBERS_WELCOME_TEXT;
extern NSString *const TEXT_GET_MONEY_WELCOME_TITLE;
extern NSString *const TEXT_GET_MONEY_WELCOME_TEXT;
extern NSString *const TEXT_SHOP_WELCOME_TITLE;
extern NSString *const TEXT_SHOP_WELCOME_TEXT;
extern NSString *const TEXT_SETTINGS_WELCOME_TITLE;
extern NSString *const TEXT_SETTINGS_WELCOME_TEXT;
extern NSString *const TEXT_GET_REPOSTS_WELCOME_TITLE;
extern NSString *const TEXT_GET_REPOSTS_WELCOME_TEXT;

extern NSString *const TEXT_RATE_APP_TITLE;
extern NSString *const TEXT_RATE_APP_DESCRIPTION;

//Colors
extern CGFloat const BACKGROUND_WHITE_COMPONENT;