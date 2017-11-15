//
//  ViewController.m
//  RandomCircleView
//
//  Created by liyy on 2017/11/15.
//  Copyright © 2017年 ccdc. All rights reserved.
//

#import "ViewController.h"
#import <math.h>

@interface BrandWeightModel : NSObject

@property (nonatomic, assign) int weight;       // 权重
@property (nonatomic, assign) CGFloat radius;   // 半径
@property (nonatomic, assign) CGPoint center;   // 圆心
@property (nonatomic, assign) CGRect frame;     // frame

@end

@implementation BrandWeightModel

@end


#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r, g, b,1.0f)

// ---------------- 设置圆角和边框 ----------------
#define CTXViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]


@interface ViewController () {
    UIScrollView *scrollView;
    
    NSMutableArray *weightArray;
}

@end

@implementation ViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.backgroundColor = RGB(arc4random() % 256, arc4random() % 256, arc4random() % 256);
    [self.view addSubview:scrollView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!weightArray) {
        // 源数据
        weightArray = [self brandWeightModels];
        
        [self addItemCircieImageView];
    }
}

#pragma mark - 计算model并添加View

// 添加圆图
- (void) addItemCircieImageView {
    // 对数组进行排序
    NSArray *result = [weightArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BrandWeightModel *model1 = (BrandWeightModel *)obj1;
        BrandWeightModel *model2 = (BrandWeightModel *)obj2;
        
        return model2.weight > model1.weight; // 降序
    }];
    
    // 最大的权重的半径
    CGFloat maxRadius = 100;
    
    // 从最大权重的view开始，默认在scrollView的中间，以此为中心布局
    BrandWeightModel *maxModel = result[0];
    maxModel.center = CGPointMake(scrollView.bounds.size.width / 2, scrollView.bounds.size.height / 2);
    maxModel.radius = maxRadius;
    
    // 每个权重的半径值
    CGFloat radiusPerWeight = maxRadius / maxModel.weight;
    
    // 创建临时可变数组，设置完center后则删除
    NSMutableArray *tempResult = [NSMutableArray arrayWithArray:result];
    
    // 保存设置center后的model
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [models addObject:tempResult.firstObject];
    [tempResult removeObjectAtIndex:0];// 删除第一个(也就是最大权重的)model
    
    while (tempResult.count > 0) {
        //        // 随机取出一个model
        //        int randomIndex = arc4random() % tempResult.count;
        //        BrandWeightModel *model = [tempResult objectAtIndex:randomIndex];
        
        // 按顺序取出model
        BrandWeightModel *model = tempResult.firstObject;
        
        // 计算每个model的半径
        CGFloat r = radiusPerWeight * model.weight;
        model.radius = r > 25 ?  r : 25;  // 尺寸不能小于25 * 2
        // 设置center
        model.center = [self calculateViewCenter:model complateModels:models];
        
        [models addObject:model];
        [tempResult removeObject:model];
    }
    
    // 添加view
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (int i = 0; i < models.count; i++) {
        BrandWeightModel *model = models[i];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, model.radius * 2, model.radius * 2)];
        view.center = model.center;
        view.backgroundColor = RGB(arc4random() % 256, arc4random() % 256, arc4random() % 256);
        CTXViewBorderRadius(view, model.radius, 0, [UIColor clearColor]);
        
        model.frame = view.frame;
        
        [scrollView addSubview:view];
        [views addObject:view];
    }
    
    // 超出scrollview的部分，需要再次修正每个view的位置,否则被遮挡
    CGFloat maxX = 0, maxY = 0;
    CGFloat minX = 9999, minY = 9999;
    for (int i = 0; i < result.count; i++) {
        BrandWeightModel *model = result[i];
        
        if (model.frame.origin.x < minX) {
            minX = model.frame.origin.x;
        }
        
        if (model.frame.origin.y < minY) {
            minY = model.frame.origin.y;
        }
        
        CGFloat x = model.frame.origin.x + model.frame.size.width;
        if (x > maxX) {
            maxX = x;
        }
        
        CGFloat y = model.frame.origin.y + model.frame.size.height;
        if (y > maxY) {
            maxY = y;
        }
    }
    
    // 修正每个view的位置
    CGFloat margin = 10;// 最小边距
    CGFloat correctX = 0;
    if (minX < margin) {
        correctX = -minX + margin;
    }
    CGFloat correctY = 0;
    // 设置不能上下滑动的话，就不能修正y
    if (minY < margin) {
        correctY = -minY + margin;
    }
    for (UIView *view in views) {
        view.center = CGPointMake(view.center.x + correctX, view.center.y + correctY);
    }
    
    // 最大的contentSize
    scrollView.contentSize = CGSizeMake((maxX - minX) + margin * 2, (maxY - minY) + margin * 2);
    
    // 移动到中心位置
    CGFloat centerX = 0;
    if (scrollView.contentSize.width > scrollView.frame.size.width) {
        centerX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2;
    }
    
    CGFloat centerY = 0;
    if (scrollView.contentSize.height > scrollView.frame.size.height) {
        centerY = (scrollView.contentSize.height - scrollView.frame.size.height) / 2;
    }
    
    scrollView.contentOffset = CGPointMake(centerX, centerY);
}

// 生成源数据
- (NSMutableArray *)brandWeightModels {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 12; i++) {
        BrandWeightModel *model = [[BrandWeightModel alloc] init];
        model.weight = 10 + arc4random() % 101;// 10-110
        [result addObject:model];
    }
    
    return result;
}

/**
 给model设置一个合适的center
 
 @param model 需要设置center的model
 @param models 已经设置好centr的所有model
 @return 合适的center
 */
- (CGPoint) calculateViewCenter:(BrandWeightModel*)model complateModels:(NSMutableArray *)models {
    // 每个view的圆圈的距离
    CGFloat distance = 10;
    
    // 中心位置的model
    BrandWeightModel *centerModel = [models firstObject];
    CGPoint centerPoint = centerModel.center;
    // 初始位置是：当前model距离centerModel的最近距离
    CGFloat startRadius = centerModel.radius + distance + model.radius;
    // 每次圆的半径增加10的距离，再在这个圆上找位置
    for (; ; startRadius += distance) {
        // 计算当前圆在这个轨道上的夹角大小
        CGFloat a = sqrt(startRadius * startRadius - model.radius * model.radius);
        CGFloat rankAngle = 2 * acos(a / startRadius);
        
        // 在这个圆上不断找一个合适的位置
        for (float angle = 0; angle <= 2 * M_PI; angle += rankAngle) {
            // 计算当前的圆心点
            CGFloat x = centerPoint.x + startRadius * sin(angle);
            CGFloat y = centerPoint.y - startRadius * cos(angle);
            CGPoint result = CGPointMake(x, y);
            
            // 不能超出scrollView的上下边界,即不可以上下滑动
            if (y - model.radius < 5) {
                continue;
            }
            if (y + model.radius > scrollView.bounds.size.height-5) {
                continue;
            }
            
            // 判断与之前的view不能重叠
            BOOL isOverlap = NO;
            for (int i = 1; i < models.count; i++) {
                BrandWeightModel *item = models[i];
                
                if ([self isOverlapOriginalModel:item centerPoint:result radius:model.radius]) {
                    isOverlap = YES;
                    break;
                }
            }
            
            if (!isOverlap) {
                return result;
            }
        }
    }
    
    return CGPointMake(0, 0);
}

- (BOOL) isOverlapOriginalModel:(BrandWeightModel *)model centerPoint:(CGPoint)center radius:(CGFloat)radius {
    CGFloat minDistance = model.radius + radius + 10;// 圆心的最小距离
    
    CGFloat x = model.center.x - center.x;
    CGFloat y = model.center.y - center.y;
    CGFloat distance = sqrt(x * x + y * y);
    
    return distance < minDistance;
}

@end
