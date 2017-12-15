//
//  HttpRequest.h
//  EasyLink
//
//  Created by 琦琦 on 2017/5/2.
//  Copyright © 2017年 fengdian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AddressModel.h" // 地址模型
//#import "HomeDataModel.h" // 首页拼团数据模型
//#import "PingJiaModel.h" // 评价模型
//#import "CategoryListModel.h" // 分类的类型模型
//#import "UserAddressModel.h" // 用户收货地址模型

#import "AllTieZiLingYuModel.h" // 所有帖子领域列表模型
#import "SearchUserModel.h" // 搜索用户信息模型
#import "SearchBiaoQianModel.h" // 搜索标签的模型
#import "UserLikeTieZiListModel.h" // 用户喜欢帖子模型
#import "SearchTieZiModel.h" // 搜索帖子模型
#import "pinglunModel.h" // 评论数据模型
#import "FollowUserInfoListModel.h" // 关注用户信息Model
#import "DongTaiModel.h" // 动态Model
#import "TrendsModel.h" // 获取关注用户动态
#import "SearchTieZiWithKeyWordModel.h" // 搜索帖子模型
#import "TieZiDetail.h" // 帖子详情模型
#import "ZhuanTiModel.h" // 专题模型
#import "ZhuanTiDetailModel.h" // 专题详情模型
#import "BannerModel.h" // banner模型


#define STRPATH @"https://app.blog.huopinb.com"

@interface HttpRequest : NSObject

// 数据请求
+ (void)postWithURL:(NSString *)str andDic:(NSDictionary *)dic success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

// 获取公共rsa公钥
- (void) GetRSAPublicKeySuccess:(void(^)(id strPublickey))success failure:(void (^)(NSError *error))failure;

// 获取验证码
- (void) PostPhoneCodeWithDic:(NSDictionary *)datedic Success:(void(^)(id status))success failure:(void (^)(NSError *error))failure;

// 注册
- (void) PostRegisterWithDic:(NSDictionary *)datedic Success:(void(^)(id userDataJsonStr))success failure:(void (^)(NSError *error))failure;

// 登录
- (void) PostLoginWithDic:(NSDictionary *)datedic Success:(void(^)(id userDataJsonStr))success failure:(void (^)(NSError *error))failure;

// 核对验证码
- (void) PostCheckCodeWithDic:(NSDictionary *)datedic Success:(void(^)(id confirmCode))success failure:(void (^)(NSError *error))failure;

// 重置密码
- (void) PostResetPassWordWithDic:(NSDictionary *)datadic Success:(void(^)(id resetMessage))success failure:(void (^)(NSError *error))failure;

// 修改密码
- (void) PostRevisePassWordWithDic:(NSDictionary *)datadic Success:(void(^)(id resetMessage))success failure:(void (^)(NSError *error))failure;

// 获取城市
- (void) GetAddressWithPid:(NSString *)strPid Success:(void(^)(id addressMessage))success failure:(void (^)(NSError *error))failure;

// 获取用户资料
- (void) PostUserInfoWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 修改用户图像
- (void)testUploadImageWithPost:(NSDictionary *)dic andImg:(UIImage *)image Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;

// 修改用户资料
- (void) PostReviseUserInfoWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 获取用户中心可见页面配置参数
- (void) PostGetShowPageTabConfigWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 配置用户中心可见页面
- (void) PostSetShowPageTabConfigWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 添加用户关注
- (void) PostAddFollowUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 移除用户关注
- (void) PostDelFollowUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 添加不喜欢用户
- (void) PostAddDislikeUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;

// 移除不喜欢用户
- (void) PostDelDislikeUserWithDic:(NSDictionary *)userInfoDic Success:(void(^)(id userInfo))success failure:(void (^)(NSError *error))failure;


// 获取用户所有关注的用户的编号
- (void) PostGetAllFollowUserIdListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取关注的用户信息列表
- (void) PostGetFollowUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取指定用户所关注的用户列表分页数据 ***
- (void) PostGetFollowUserInfoListForUcenterWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取粉丝信息列表
- (void) PostGetFollowerUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户不喜欢的用户
- (void) PostGetDislikeUserInfoListWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 添加用户意见反馈
- (void) PostAddUserFeedbackWithDic:(NSDictionary *)userInfoData Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 搜索用户
- (void) PostSearchUserWithKeyword:(NSString *)keyword andPageStart:(NSString *)pageStart andPageSize:(NSString *)pageSize Success:(void(^)(id userListInfo))success failure:(void(^)(NSError *error))failure;

// 获取搜索结果页面推荐用户列表
- (void) PostGetUserListRecommendForSearchWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取所有帖子领域
- (void) GetFieldListSuccess:(void(^)(id fieldList))success failure:(void (^)(NSError *error))failure;

// 获取用户所订阅的所有领域的编号
- (void) PostGetAllFollowFieldIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 绑定用户喜欢领域
- (void) PostBindFieldWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户订阅的所有关键词编号
- (void) PostGetAllFollowKeywordIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户所有订阅关键词
- (void) PostGetAllFollowKeywordListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 用户订阅关键词
- (void) PostFollowKeywordWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 用户取消关键词订阅
- (void) PostRemoveFollowKeywordWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取检索相关关键词结果
- (void) GetKeyWordListLikeWithKeyword:(NSString *)keyword andPageStart:(NSString *)pageStart andPageSize:(NSString *)pageSize Success:(void(^)(id userListInfo))success failure:(void(^)(NSError *error))failure;

// 发布帖子
- (void) PostAddNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 修改帖子
- (void) PostEditNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 删除帖子
- (void) PostDelNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取帖子详情
- (void) PostShowNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户所有喜欢的帖子编号
- (void) PostGetAllLoveNoteIdListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户喜欢帖子
- (void) PostGetLoveNoteListWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户喜欢帖子列表分页数据 ***
- (void) PostGetLoveNoteListForUcenterWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;


// 获取用户发布的帖子
- (void) PostGetNoteListByUserWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户发布的帖子列表分页数据 ***
- (void) PostGetNoteListByUserForUcenterWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取当前用户首页关注的用户和自己发布的帖子
- (void) PostGetNoteListByFollowUserWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取当前用户首页中帖子列表分页数据 ***
- (void) PostGetNoteListPageForHomeWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;


// 获取关键词绑定帖子
- (void) PostGetNoteListByKeywordWithDataDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取检索相关帖子结果
- (void) PostGetNoteListLikeWithdicData:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 发布评论或回复评论
- (void) PostFabuAndHuiFuPingLunWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取评论
- (void) GetCommentListWithnoteId:(NSString *)noteid andpageStart:(NSString *)pageStart andpageSize:(NSString *)pageSize Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 标记喜欢帖子
- (void) PostAddLoveNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 移除喜欢帖子
- (void) PostDelLoveNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 用户举报帖子
- (void) PostAccusationNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;


// 获取当前帖子的用户动态
- (void) PostGetUserActivityByNoteWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取通知消息
- (void) PostGetMessageWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取通知消息列表分页数据 ***
- (void) PostGetMessageForPageWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;


// 获取关注用户动态
- (void) PostGetFollowUserActivityWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取推荐用户列表
- (void) PostGetUserListRecommendWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户喜好相关订阅关键词
- (void) PostGetKeywordListForUserLikeWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取用户喜好相关订阅关键词分页数据(带关联帖子列表) ***
- (void) PostGetKeywordListForUserLikeWithNotesWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取搜索结果页推荐关键词
- (void) PostgetKeywordListRecommendForSearchWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;

// 获取关键词推荐的绑定帖子
- (void) PostGetNoteListByKeywordRecommendWithDic:(NSDictionary *)dataDic Success:(void(^)(id userInfo))success failure:(void(^)(NSError *error))failure;



// 获取专题活动列表 ***
- (void) GetSpecialEventListWithpageStart:(NSString *)pagestart andpageSize:(NSString *)pagesize Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;


// 获取专题活动详情 ***
- (void) GetSpecialEventDetailWithId:(NSString *)idStr Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;

// 获取Banner数据列表 ***
- (void) GetBannerListWithPosition:(NSString *)position Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;


// 上传图片
- (void) PostImgToServerWithUserInfo:(NSDictionary *)dic andImg:(UIImage *)image Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;

// 上传视频
- (void) PostVideoToServerWithUserInfo:(NSDictionary *)dic andImg:(UIImage *)image andVideo:(NSURL *)videoURL Success:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;

// 获取用户注册协议
- (void) GetRegistrationAgreementSuccess:(void(^)(id arrForDetail))success failure:(void (^)(NSError *error))failure;


// 判断用户是否登录超时
- (void) PostPanduanUserTimeOutWithDic:(NSDictionary *)dic Success:(void (^)(id statusInfo))success failure:(void (^)(NSError *error))failure;


// 转换时间戳方法
- (NSString *)stringFromDate:(NSDate *)date;


// 弹出提示
- (void) GetHttpDefeatAlert:(NSString *)str;


@end
