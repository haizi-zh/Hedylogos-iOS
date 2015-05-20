//
//  Constants.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/10.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
//友盟key
#define UMENG_KEY               @ "5433d2e2fd98c5b7a3020907"

#define APP_ID                  @ 954201036

//第三方分享相关key

#define SHARE_QQ_APPID          @ "1104433490"
#define SHARE_QQ_KEY            @ "9OCrfdw4vb31gHOU"
#define SHARE_SINA_KEY          @ "3743857858"
#define SHARE_RENREN_KEY        @ "5746d38353ed4bbb9bb4018bfb035a89"
#define SHARE_DOUBAN_KEY        @ "07402b7af9b58b7115c08270ed20a253"
#define SHARE_WEIXIN_APPID      @ "wx26b58c7173483529"
#define SHARE_WEIXIN_SECRET     @ "28daa05c021ebebe6d3cf06645b0c5ac"
#define SHARE_TECENTWEIBO_KEY   @ "801545095 "

#define WECHAT_API_DOMAIN       @ "https://api.weixin.qq.com/"

/***** 个推相关 key *****/

#define kGeTuiAppId             @"dajFCa9UMt7Ezo6kqOZ4C9"
#define kGeTuiAppKey            @"2aMWW4drb67bQFixAQ5cj"
#define kGeTuiAppSecret         @"BmkFKzmOqI7YSrQhYbhAn3"


/***** API *****/

#define BASE_URL1                                @ "http://api2.taozilvxing.cn/taozi/"
#define BASE_URL                                 @ "http://182.92.150.243:9000/taozi/"
//攻略相关接口
#define API_GET_RECOMMEND                       (BASE_URL @"recommend")     //获取目的地首页推荐接口
#define API_GET_SCREENING                       (BASE_URL @"users/expert/tracks")  //    达人足迹接口
#define API_GET_DOMESTIC_DESTINATIONS           (BASE_URL @"geo/localities/domestic")     //获取国内目的地接口
#define API_GET_FOREIGN_DESTINATIONS            (BASE_URL @"geo/localities/abroad")       //获取国外目的地接口

//详情接口
#define API_GET_CITYDETAIL                      (BASE_URL @"geo/localities/")
#define API_GET_SPOT_DETAIL                     (BASE_URL @"poi/vs/")
#define API_GET_RESTAURANT_DETAIL               (BASE_URL @"poi/restaurant/")
#define API_GET_SHOPPING_DETAIL                 (BASE_URL @"poi/shopping/")
#define API_GET_HOTEL_DETAIL                    (BASE_URL @"poi/hotel/")

#define API_GET_RESTAURANTSLIST_CITY            (BASE_URL @"poi/restaurant/localities/")//城市的美食列表
#define API_GET_SHOPPINGLIST_CITY               (BASE_URL @"poi/shopping/localities/")//城市的购物列表
#define API_GET_SPOTLIST_CITY                   (BASE_URL @"poi/vs/localities/") //城市的景点列表
#define API_GET_HOTELLIST_CITY                  (BASE_URL @"poi/hotel/localities/") //城市的酒店列表

#define API_GET_GUIDE_CITY                      (BASE_URL @"guides/locality/")    //城市的美食购物攻略介绍

#define API_CREATE_GUIDE                        (BASE_URL @"create-guide")    //制作攻略

#define API_UPDATE_GUIDE_PROPERTY               (BASE_URL @"guides")    //修改攻略属性
#define API_SAVE_TRIP                           (BASE_URL @"guides")    //保存攻略
#define API_GET_GUIDELIST                       (BASE_URL @"guides")    //获取攻略列表
#define API_GET_GUIDELIST_EXPERT                (BASE_URL @"guides/")    //获取达人攻略列表
#define API_GET_GUIDE                           (BASE_URL @"guides/")    //获取攻略列表
#define API_DELETE_GUIDE                        (BASE_URL @"guides/")    //删除攻略列表
#define API_SAVE_TRIPINFO                       (BASE_URL @"guides/info/")    //保存攻略信息
#define API_FORK_TRIP                           (BASE_URL @"copy-guide/")     //复制攻略

#define API_GET_FAVORITES                       (BASE_URL @"misc/favorites")    //获取我的收藏列表

#define API_FAVORITE                            (BASE_URL @"misc/favorites")       //收藏
#define API_UNFAVORITE                          (BASE_URL @"misc/favorites")      //取消收藏

#define API_SEARCH_TRAVELNOTE                   (BASE_URL @"travel-notes/search")      //搜索游记

#define API_NEARBY                              (BASE_URL @"poi/nearby")      //我身边

#define API_SUGGESTION                          (BASE_URL @"suggestions")   //搜索联想

//用户相关接口
#define API_WEIXIN_LOGIN                        (BASE_URL @"users/auth-signup")
#define API_USERINFO                            (BASE_URL @"users/")
#define API_GET_CAPTCHA                         (BASE_URL @"users/send-validation")    //接收验证码
#define API_VERIFY_CAPTCHA                      (BASE_URL @"users/check-validation")   //验证验证码
#define API_RESET_PWD                           (BASE_URL @"users/reset-pwd")           //重新设置密码
#define API_SIGNUP                              (BASE_URL @"users/signup")        //用户注册
#define API_SIGNIN                              (BASE_URL @"users/signin")
#define API_BINDTEL                             (BASE_URL @"users/bind")        //绑定手机号
#define API_SEARCH_USER                         (BASE_URL @"users/search")      //搜索好友
#define API_ADD_CONTACT                         (BASE_URL @"users/contacts")   //添加好友
#define API_REQUEST_ADD_CONTACT                 (BASE_URL @"users/request-contacts")   //请求添加好友
#define API_DELETE_CONTACTS                     (BASE_URL @"users/contacts")   //删除好友
#define API_GET_USERINFO_WITHEASEMOB            (BASE_URL @"users/easemob")   //传一个环信 id 数组，得到一个FM用户信息数组
#define API_CHANGE_PWD                          (BASE_URL @"users/pwd")   //传一个环信 id 数组，得到一个FM用户信息数组
#define API_UPLOAD_ADDRESSBOOK                  (BASE_URL @"users/search-by-address-book")  //上传通讯录接口

//IM相关接口
#define API_GET_CONTACTS                        (BASE_URL @"users/contacts")   //获得联系人列表

//其他一些乱七八糟的接口
#define API_GET_COVER_STORIES                   (BASE_URL @"misc/cover-stories")  //获得封面故事接口
#define API_POST_PHOTOIMAGE                     (BASE_URL @"misc/put-policy/portrait")  //获得封面故事接口
#define API_SEARCH                              (BASE_URL @"search")  //联合搜索
#define API_GET_ALBUM                           (BASE_URL @"geo/localities/")      //获取城市图集
#define API_GET_COLUMNS                         (BASE_URL @"columns")     //获取首页运营位置推荐
#define API_FEEDBACK                            (BASE_URL @"misc/feedback")    //反馈接口

/**
 html 接口
 */
#define APP_ABOUT                               @ "http://h5.taozilvxing.com/about.php"             //关于页面
#define APP_AGREEMENT                           @ "http://h5.taozilvxing.com/agreement.htm"       //用户协议

/***** Notification name *******/
#define weixinDidLoginNoti                      @ "weixinDidLogin"              //微信登录完发送通知，传递 code 给服务器
#define userDidLoginNoti                        @ "userDidLogin"                //用户完成所有登录工作。
#define userDidResetPWDNoti                     @ "userDidResetPWD"                //用户成功完成重设忘记密码的工作。

#define userDidRegistedNoti                     @ "userDidRegisted"                //用户完成所有注册登录工作。
#define userDidLogoutNoti                       @ "userDidLogout"               //用户完成所有退出登录工作。
#define updateUserInfoNoti                      @ "updateUserInfo"              //用户信息有更改。
#define frendRequestListNeedUpdateNoti          @ "updateFrendRequestList"      //更新好友请求列表

#define contactListNeedUpdateNoti               @ "updatecontactList"           //更新好友列表
#define updateDestinationsSelectedNoti          @ "updateDestinationsSelected"           //更新目的地列表
#define updateChateViewNoti                     @ "updateChatView"               //更新聊天界面

#define updateFavoriteListNoti                  @"updateFavoriteListView"    //更新收藏列表
#define updateGuideListNoti                     @"updateFavoriteListView"    //更新我的攻略列表


#pragma mark - ***********各种枚举信息*************

typedef NS_ENUM(NSUInteger, TZPoiType) {
    kSpotPoi = 1,
    kRestaurantPoi,
    kShoppingPoi,
    kHotelPoi,
    kCityPoi,
    kTravelNotePoi
};

/***** app的状态，连接中。收取中。。等 *****/
typedef NS_ENUM(NSUInteger, IM_CONNECT_STATE) {
    IM_CONNECTING = 1,
    IM_CONNECTED,
    IM_RECEIVING,
    IM_RECEIVED,
    IM_DISCONNECTED
};

/***** 登录注册时输入的错误码 *****/
typedef NS_ENUM(NSUInteger, UserInfoInputError) {
    PhoneNumberError = 1,           //手机号号输入非法
    PasswordError,                  //密码输入非法
    PresentPasswordError,           //新密码输入非法
    ConfirmPasswordError,           //确认密码输入非法
    PasswordNotMatchedError,        //修改密码时两次输入的密码不一致
    IllegalCharacterError,          //包含非法字符
    InputEmptyError,                //输入字符为空
    NoError
};

/***** 用户验证验证码时候的原因 *****/
typedef NS_ENUM(NSUInteger, VerifyCaptchaType) {
    UserLosePassword = 1,       //忘记密码
    UserBindTel                 //绑定手机号的时候
};

/***** 请求验证码和验证验证码时候向服务器发送的指令类型 *****/
#define    kUserRegister         @"1"        //用户注册时候进入时天下短信验证码
#define    kUserLosePassword     @"2"        //用户忘记密码
#define    kUserBindTel          @"3"         //用户绑定手机

/**
 修改个人信息的类型
 */
typedef NS_ENUM(NSUInteger, UserInfoChangeType) {
    ChangeName = 1,
    ChangeSignature,
    ChangeTel,
    ChangeGender,
    ChangeAvatar,
    ChangeSmallAvatar,
    ChangeOtherInfo = 100
};

///***** 旅行派自定义消息枚举信息****/
typedef NS_ENUM(NSUInteger, TZChatType) {
    TZChatNormalText = 0,                  //普通文字信息
    TZChatTypeStrategy = 1,         //我的攻略
    TZChatTypeCity,                 //城市
    TZChatTypeTravelNote,           //游记
    TZChatTypeSpot,                 //景点
    TZChatTypeFood,                 //美食
    TZChatTypeShopping,             //购物
    TZChatTypeHotel,                //酒店
    
    TZTipsMsg    =  100             //自定义的提示信息， 如：我加入了旅行派群组
};

/***** 旅行派好友请求枚举信息****/
typedef NS_ENUM(NSUInteger, TZFrendRequest) {
    TZFrendDefault = 0,      //未处理
    TZFrendAgree,            //同意
    TZFrendReject,          //拒绝
};

/***** 旅行派自定义透传枚举信息 ****/
typedef NS_ENUM(NSUInteger, TZCMDChatType) {
    CMDAddContact = 1,
    CMDAgreeAddContact,
    CMDDeleteContact
};


/***** 设备信息 *****/

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define kWindowWidth   [UIApplication sharedApplication].keyWindow.frame.size.width
#define kWindowHeight  [UIApplication sharedApplication].keyWindow.frame.size.height

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4  (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON)
#define IS_IPHONE_5  (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue]>=8)


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define APP_PAGE_COLOR                  UIColorFromRGB(0xf2f2f2)
#define APP_THEME_COLOR                 UIColorFromRGB(0x1cc091)
#define APP_THEME_COLOR_HIGHLIGHT       UIColorFromRGB(0xad0618)
#define APP_HIGNLIGHT_COLOR             UIColorFromRGB(0xff5d38)
#define APP_SUB_THEME_COLOR             UIColorFromRGB(0x6ed8dc)
#define APP_SUB_THEME_COLOR_HIGHLIGHT   UIColorFromRGB(0x279095)
#define APP_BORDER_COLOR                UIColorFromRGB(0xe4e4e4)
#define APP_IMAGEVIEW_COLOR             UIColorFromRGB(0xf8f8f8)

#define APP_DIVIDER_COLOR               UIColorFromRGB(0xe5e5e5)
#define TEXT_COLOR_TITLE                UIColorFromRGB(0x2e2727)
#define TEXT_COLOR_TITLE_SUBTITLE       UIColorFromRGB(0x62626)
#define TEXT_COLOR_TITLE_DESC           UIColorFromRGB(0x999999)
#define TEXT_COLOR_TITLE_HINT           UIColorFromRGB(0xa6a6a6)
#define TEXT_COLOR_TITLE_PH             UIColorFromRGB(0xcdcdcd)
#define GRAY_COLOR                      UIColorFromRGB(0xdddddd)


/*****应用启动时是否应该启动引导页******/
#define shouldSkipIntroduce [[NSUserDefaults standardUserDefaults] boolForKey:[[AppUtils alloc] init].appVersion]

#define kShouldShowIntroduceWhenFirstLaunch   YES

/*****Yahoo!天气对应的 code 列表******/
#define yahooWeatherCode @[   @"龙卷风",\
@"热带风暴",\
@"暴风",\
@"大雷雨",\
@"雷阵雨",\
@"雨夹雪",\
@"雨夹雹",\
@"雪夹雹",\
@"冻雾雨",\
@"细雨",\
@"冻雨",\
@"阵雨",\
@"阵雨",\
@"阵雪",\
@"小阵雪",\
@"高吹雪",\
@"雪",\
@"冰雹",\
@"雨淞",\
@"粉尘",\
@"雾",\
@"薄雾",\
@"烟雾",\
@"大风",\
@"风",\
@"冷",\
@"阴",\
@"多云",\
@"多云",\
@"局部多云",\
@"局部多云",\
@"晴",\
@"晴",\
@"转晴",\
@"转晴",\
@"雨夹冰雹",\
@"热",\
@"局部雷雨",\
@"偶有雷雨",\
@"偶有雷雨",\
@"偶有阵雨",\
@"大雪",\
@"零星阵雪",\
@"大雪",\
@"局部多云",\
@"雷阵雨",\
@"阵雪",\
@"局部雷阵雨",\
@"水深火热"\
]
/*****Yahoo!天气对应的 code 列表******/
#define yahooWeatherImageName @[ @"bao_rain",\
@"bao_rain",\
@"bao_rain",\
@"thunder_rain",\
@"thunder_rain",\
@"rain_snow",\
@"rain_snow",\
@"rain_snow",\
@"rain_snow",\
@"s_rain",\
@"m_rain",\
@"m_rain",\
@"m_rain",\
@"m_snow",\
@"s_snow",\
@"h_rain",\
@"m_snow",\
@"冰雹",\
@"雨淞",\
@"粉尘",\
@"cloudy",\
@"cloudy",\
@"cloudy",\
@"大风",\
@"风",\
@"冷",\
@"cloudy",\
@"cloudy",\
@"cloudy",\
@"cloudy",\
@"cloudy",\
@"clear",\
@"clear",\
@"clear",\
@"clear",\
@"雨夹冰雹",\
@"热",\
@"局部雷雨",\
@"偶有雷雨",\
@"偶有雷雨",\
@"偶有阵雨",\
@"h_snow",\
@"零星阵雪",\
@"h_snow",\
@"cloudy",\
@"thunder_rain",\
@"m_snow",\
@"thunder_rain",\
@"水深火热"\
]






















