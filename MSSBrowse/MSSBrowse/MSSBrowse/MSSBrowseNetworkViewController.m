//
//  MSSBrowseNetworkViewController.m
//  MSSBrowse
//
//  Created by 于威 on 16/4/26.
//  Copyright © 2016年 于威. All rights reserved.
//

#import "MSSBrowseNetworkViewController.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIView+MSSLayout.h"
#import "UIImage+MSSScale.h"
#import "MSSBrowseDefine.h"

@implementation MSSBrowseNetworkViewController

- (void)loadBrowseImageWithBrowseItem:(MSSBrowseModel *)browseItem Cell:(MSSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect
{
    // 停止加载
    [cell.loadingView stopAnimation];
    // 判断大图是否存在
    if([[SDImageCache sharedImageCache]diskImageExistsWithKey:browseItem.bigImageUrl])
    {
        // 显示大图
        [self showBigImage:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect];
    }
    // 如果大图不存在
    else
    {
        self.isFirstOpen = NO;
        // 加载大图
        [self loadBigImageWithBrowseItem:browseItem cell:cell rect:bigImageRect];
    }
}

- (void)showBigImage:(UIImageView *)imageView browseItem:(MSSBrowseModel *)browseItem rect:(CGRect)rect
{
    // 取消当前请求防止复用问题
    [imageView sd_cancelCurrentImageLoad];
    // 如果存在直接显示图片
    imageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl];
    // 第一次打开浏览页需要加载动画
    if(self.isFirstOpen)
    {
        self.isFirstOpen = NO;
        imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = rect;
        }];
    }
    else
    {
        if (CGRectIsEmpty(rect)) {
            imageView.frame = [imageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_WIDTH screenHeight:MSS_SCREEN_HEIGHT];
        } else {
            imageView.frame = rect;
        }
    }
}

// 加载大图
- (void)loadBigImageWithBrowseItem:(MSSBrowseModel *)browseItem cell:(MSSBrowseCollectionViewCell *)cell rect:(CGRect)rect
{
    UIImageView *imageView = cell.zoomScrollView.zoomImageView;
    // 加载圆圈显示
    [cell.loadingView startAnimation];
    // 默认为屏幕中间
    [imageView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(browseItem.smallImageView.mssWidth, browseItem.smallImageView.mssHeight)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 关闭图片浏览view的时候，不需要继续执行小图加载大图动画
        if(self.collectionView.userInteractionEnabled)
        {
            // 停止加载
            [cell.loadingView stopAnimation];
            if(error)
            {
                [self showBrowseRemindViewWithText:@"图片加载失败"];
            }
            else
            {
                // 图片加载成功
                [UIView animateWithDuration:0.5 animations:^{
                    if (CGRectIsEmpty(rect)) {
                        imageView.frame = [image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_WIDTH screenHeight:MSS_SCREEN_HEIGHT];
                        browseItem.smallImageView.image = image;
                    } else {
                        imageView.frame = rect;
                    }

                }];
            }
        }
    }];
}

@end
