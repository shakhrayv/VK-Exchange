
#import <Foundation/Foundation.h>
#import "Constants.h"

NSString *const NSUDEFAULTS_KEY_PHOTO_QUEUE = @"nsudefaults_key_photo_queue";
NSString *const NSUDEFAULTS_KEY_WALL_POSTS = @"nsudefaults_key_wall_posts";
NSString *const NSUDEFAULTS_KEY_ACCESS_TOKEN = @"nsudefaults_key_access_token";
NSString *const NSUDEFAULTS_KEY_USER_INFO = @"nsuserdefaults_key_user_info";
NSString *const NSUDEFAULTS_KEY_USER_ID = @"nsuserdefaults_key_user_id";
NSString *const NSUDEFAULTS_KEY_BALANCE = @"nsudefaults_key_balance";
NSString *const NSUDEFAULTS_KEY_IS_PRIVILEGED = @"nsudefaults_key_is_privileged";

NSString *const SETTINGS_KEY_TRAFFIC_ECONOMY = @"settings_key_traffic_economy";
NSString *const SETTINGS_KEY_LOAD_IMAGES = @"settings_key_load_images";
NSString *const SETTINGS_KEY_TURBO = @"settings_key_turbo";
NSString *const NSUDEFAULTS_KEY_APP_VERSION = @"nsudefaults_key_app_version";
NSString *const SERVER_REQUEST_REPOSTS_PATH = @"reposts.request.php";
NSString *const NSUDEFAULTS_KEY_SHOP_PRICES = @"nsudefaults_key_shop_prices";
NSString *const NSUDEFAULTS_KEY_SUBSCRIBERS_BRIEF = @"nsudefaults_key_subscribers_brief";
NSString *const NSUDEFAULTS_KEY_LIKES_BRIEF = @"nsudefaults_key_likes_brief";
NSString *const NSUDEFAULTS_KEY_REPOSTS_BRIEF = @"nsudefaults_key_reposts_brief";
NSString *const SERVER_REQUEST_SALES_HIT_INFORMATION_PATH = @"other.getSalesHit.php";
NSString *const SERVER_REQUEST_SALES_INFORMATION_PATH = @"other.getSalesInformation.php";
NSString *const NSUDEFAULTS_KEY_GET_LIKES_WELCOME_SHOWN = @"nsudefaults_key_get_likes_welcome_shown";
NSString *const NSUDEFAULTS_KEY_GET_SUBSCRIBERS_WELCOME_SHOWN = @"nsudefaults_key_get_subscribers_welcome_shown";
NSString *const NSUDEFAULTS_KEY_GET_MONEY_WELCOME_SHOWN = @"nsudefaults_key_get_money_welcome_shown";
NSString *const NSUDEFAULTS_KEY_SHOP_WELCOME_SHOWN = @"nsudefaults_key_shop_welcome_shown";
NSString *const NSUDEFAULTS_KEY_SETTINGS_WELCOME_SHOWN = @"nsudefaults_key_settings_welcome_shown";
NSString *const NSUDEFAULTS_KEY_REPOSTS_WELCOME_SHOWN = @"nsudefaults_key_reposts_welcome_shown";
NSString *const NSUDEFAULTS_KEY_SALES_HIT = @"nsudefaults_key_sales_hit";
NSString *const NSUDEFAULTS_KEY_SALES = @"nsudefaults_key_sales";
BOOL const SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY = NO;
BOOL const SETTINGS_DEFAULT_VALUE_LOAD_IMAGES = YES;
BOOL const SETTINGS_DEFAULT_VALUE_TURBO = NO;
NSTimeInterval const TIME_TILL_UNLOCK = 5.0f;
NSString *const VK_APP_ID = @"5079678";
NSString *const AS_APP_ID = @"1056958450";
NSString *const AD_ID = @"56f15d3ca94d7ae44a000100";
int AD_REWARD = 5;
NSString *const SERVER_REQUEST_PRIVILEGE_PATH = @"user.privilege.php";
NSTimeInterval const SERVER_TIMEOUT = 10;
NSInteger const VK_TIMEOUT = 5;
NSString *const SERVER_REQUEST_LIKES_ON_PHOTO_PATH = @"likes.request.php";
NSString *const SERVER_USER_PURCHASED_MONEY_PACK_PATH = @"user.addCoins.php";
NSString *const SERVER_GET_TASK_PATH = @"tasks.get.php";
NSString *const SERVER_COMPLETE_TASK_PATH = @"tasks.complete.php";
NSString *const SERVER_REQUEST_SUBSCRIBERS_PATH = @"subscribers.request.php";
NSString *const SERVER_REQUEST_TOTALS_PATH = @"tasks.getTotals.php";
NSString *const SERVER_REQUEST_AD_STATUS_PATH = @"sys.checkAdStatus.php";

CGFloat const SELECTED_VIEW_HEIGHT = 220;
int const SERVER_PRIVILEGE_MAX_ATTEMPTS = 5;
int AD_AVAILABLE = 0;
int const MAX_PROFILE_PHOTOS = 4;
int const MAX_WALL_PHOTOS = 20;
int const MAX_WALL_POSTS = 10;
NSString* const DEFAULT_PRICE_PACK_1 = @"15 р.";
NSString* const DEFAULT_PRICE_PACK_2 = @"29 р.";
NSString* const DEFAULT_PRICE_PACK_3 = @"75 р.";
NSString* const DEFAULT_PRICE_PACK_4 = @"149 р.";
NSString* const DEFAULT_PRICE_PACK_5 = @"299 р.";
NSString* const DEFAULT_PRICE_PACK_6 = @"459 р.";
NSString* const DEFAULT_PRICE_PACK_7 = @"699 р.";
NSString* const DEFAULT_PRICE_PACK_7S = @"459 р.";

NSString *const TEXT_GET_REPOSTS_WELCOME_TITLE = @"Репосты";
NSString *const TEXT_GET_REPOSTS_WELCOME_TEXT = @"Заказывайте репосты по самой привлекательной цене. Скажем по секрету - это бывает очень полезно на конкурсах репостов!";

CGFloat const REPOSTS_ROW_HEIGHT = 130.0f;
CGFloat const TABLE_VIEW_STANDARD_ROW_HEIGHT = 48.0f;
CGFloat const TABLE_VIEW_STANDARD_LEFT_OFFSET = 22.0f;
CGFloat const TABLE_VIEW_STANDARD_RIGHT_OFFSET = 14.0f;
NSString *const SERVER_URL = @"http://codelovin.co/apps/vklikes/api";
CGFloat const GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT = 40.0f;
CGFloat const GET_LIKES_CONSTRAINT_PHOTO_OFFSET = 17;
CGFloat const GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT = 34.0f;
NSTimeInterval const ANIMATIONS_DURATION_05X = 0.1f;
NSTimeInterval const ANIMATIONS_DURATION_1X = 0.2f;
NSTimeInterval const ANIMATIONS_DURATION_2X = 0.4f;
NSTimeInterval const ANIMATIONS_DURATION_4X = 0.8f;
NSTimeInterval const ANIMATIONS_DURATION_1S = 1.0f;
NSString *const SERVER_REQUEST_GET_INFO_PATH = @"user.getInfo.php";
CGFloat const LOGIN_BUTTON_WIDTH = 220.0f;
CGFloat const LOGIN_BUTTON_HEIGHT = 50.0f;
CGFloat const LOGIN_BUTTON_OFFSET_BOTTOM = 60.0f;
NSString *const GBSTORAGE_DEFAULT_NAMESPACE = @"gbstorage_default_namespace";
NSString *const GBSTORAGE_PHOTO_MAX_SQUARED = @"gbstorage_photo_max_squared";
NSString *const CONTACT_EMAIL = @"support@codelovin.co";
NSString *const FLURRY_APP_KEY = @"574CHBQCTJP6S5BN578Q";
CGFloat const ANIM_VIEW_KOEF = 0.2;
CGFloat const ANIM_MIN_VELOCITY = 1480;
CGFloat const ANIM_ACCELERATION_MOD = 40;
NSString *const NSUDEFAULTS_KEY_SHOULD_REWARD = @"nsudefaults_key_should_reward";
NSString *const NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN = @"nsudefaults_key_reposts_warning_shown";

//Text constants
NSString *const TEXT_GET_LIKES_WELCOME_TITLE = @"Добро пожаловать!";
NSString *const TEXT_GET_LIKES_WELCOME_TEXT = @"Заходите каждый день и\nмы сделаем Вас популярными!";
NSString *const TEXT_GET_SUBSCRIBERS_WELCOME_TITLE = @"Накрутка подписчиков";
NSString *const TEXT_GET_SUBSCRIBERS_WELCOME_TEXT = @"Накручивайте до 500 подписчиков в день! Просто выберите необходимое количество и нажмите \"Заказать\".";
NSString *const TEXT_GET_MONEY_WELCOME_TITLE = @"Задания";
NSString *const TEXT_GET_MONEY_WELCOME_TEXT = @"Выполняйте задания и получайте за это монеты! Чем больше заданий Вы выполняете, тем больше монеток Вы получаете за каждое задание.";
NSString *const TEXT_SHOP_WELCOME_TITLE = @"Магазин";
NSString *const TEXT_SHOP_WELCOME_TEXT = @"Покупайте монетки по самому выгодному курсу! Более того, с каждой покупкой Вас ждет небольшой подарок!";
NSString *const TEXT_SETTINGS_WELCOME_TITLE = @"Настройки";
NSString *const TEXT_SETTINGS_WELCOME_TEXT = @"Здесь Вы сможете настроить приложение под свой вкус, а также оставить отзыв в App Store или связаться с разработчиками.\nМы будем рады от Вас услышать!";

CGFloat const BACKGROUND_WHITE_COMPONENT = 0.95;