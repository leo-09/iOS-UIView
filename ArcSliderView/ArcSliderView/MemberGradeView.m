//
//  MemberGradeView.m
//  BTG
//
//  Created by liyy on 2017/12/5.
//  Copyright © 2017年 CCDC. All rights reserved.
//

#import "MemberGradeView.h"
#import <math.h>

// ---------------- 设置圆角和边框 ----------------
#define CTXViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// ----------------  设置颜色 ----------------
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MemberGradeView() {
    CGFloat gradeProgress;
    
    CADisplayLink *displayLink;
}

@property(nonatomic, retain) CAShapeLayer *gradeLayer;
@property(nonatomic, retain) CAGradientLayer *gradeGradientLayer;

@property (nonatomic, assign) CGPoint circleCenter;   // 圆心
@property (nonatomic, assign) CGFloat angle;    // 角度的一半
@property (nonatomic, assign) CGFloat edgeRadius;// 边角的半径
@property (nonatomic, assign) CGFloat outerRadius;  // 外层弧线的半径
@property (nonatomic, assign) CGFloat innterRadius; // 内层弧线的半径
@property (nonatomic, assign) CGFloat outerMarginBottom;

// 左侧的半圆的圆心
@property (nonatomic, assign) CGPoint leftCenter;
// 左侧的半圆
@property (nonatomic, assign) CGFloat leftStartAngle;
@property (nonatomic, assign) CGFloat leftEndAngle;

@end

@implementation MemberGradeView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addContentView];
    }
    
    return self;
}

- (void) addContentView {
    CGFloat ivWidth = 25;   // 图标的尺寸
    _edgeRadius = 4; // 边角的半径
    _outerMarginBottom = _edgeRadius * 2;
    CGFloat arcThickness = _edgeRadius * 2;  // 弧线的厚度
    CGFloat outerWidth = self.frame.size.width - _edgeRadius * 2;// 外层弧线的宽度
    
    CGFloat upHeight = self.frame.size.height - _outerMarginBottom - ivWidth;
    // 外层弧线的半径
    _outerRadius = (outerWidth * outerWidth / 4 + upHeight * upHeight) / (2 * upHeight);
    // 内层弧线的半径
    _innterRadius = _outerRadius - arcThickness;
    // 角度的一半
    _angle = acos((_outerRadius - upHeight) / _outerRadius);
    // 圆心
    _circleCenter = CGPointMake(self.frame.size.width / 2, ivWidth + _outerRadius);
    
    // 根据圆心_circleCenter，计算两侧半圆的位置
    CGFloat xDistance = sin(_angle) * (_outerRadius - _edgeRadius);
    CGFloat yDistance = cos(_angle) * (_outerRadius - _edgeRadius);
    // 右侧的半圆的圆心
    CGPoint rightCenter = CGPointMake(_circleCenter.x + xDistance, _circleCenter.y - yDistance);
    // 左侧的半圆的圆心
    _leftCenter = CGPointMake(_circleCenter.x - xDistance, _circleCenter.y - yDistance);
    
    // UIBezierPath
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 起点：外层弧线的左端
    [path moveToPoint:CGPointMake(_edgeRadius, self.frame.size.height - _outerMarginBottom)];
    // 外层弧线
    CGFloat startAngle = M_PI * 1.5 - _angle;
    CGFloat endAngle = M_PI * 1.5 + _angle;
    [path addArcWithCenter:_circleCenter radius:_outerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    // 右侧的半圆
    CGFloat rightStartAngle = M_PI * 1.5 + _angle;
    CGFloat rightEndAngle = M_PI * 0.5 + _angle;
    [path addArcWithCenter:rightCenter radius:_edgeRadius startAngle:rightStartAngle endAngle:rightEndAngle clockwise:YES];
    // 内层弧线
    [path addArcWithCenter:_circleCenter radius:_innterRadius startAngle:endAngle endAngle:startAngle clockwise:NO];
    // 左侧的半圆
    _leftStartAngle = M_PI * 0.5 - _angle;
    _leftEndAngle = M_PI * 1.5 - _angle;
    [path addArcWithCenter:_leftCenter radius:_edgeRadius startAngle:_leftStartAngle endAngle:_leftEndAngle clockwise:YES];
    
    // CAShapeLayer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor blueColor].CGColor;
    layer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:layer];
    
    // CAGradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0x2D2F1F).CGColor,
                             (__bridge id)UIColorFromRGB(0x1C2A2C).CGColor,
                             (__bridge id)UIColorFromRGB(0x0C233D).CGColor ];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    [self.layer addSublayer:gradientLayer];

    gradientLayer.mask = layer;
}

- (void) addGiftViewWithGrade:(CGFloat)grade {
    CGFloat widthHeight = 4;
    CGFloat averageAngle = _angle * 2 / 5;
    
    UIImage *image = [UIImage imageNamed:@"gift01"];
    CGFloat imageDistance = 8;
    
    for (int i = 0; i < 6; i++) {
        // 只显示中间4个图
        if (i == 0 || i == 5) {
            continue;
        }
        
        // 角度差
        CGFloat gradeAngle = averageAngle * i;
        
        // 圆点的位置
        CGFloat xDistance = sin(_angle-gradeAngle) * (_outerRadius + widthHeight/2);
        CGFloat yDistance = cos(_angle-gradeAngle) * (_outerRadius + widthHeight/2);
        CGPoint circleCenter = CGPointMake(_circleCenter.x - xDistance, _circleCenter.y - yDistance);
        // 圆点
        CGRect circleFrame = CGRectMake(circleCenter.x-widthHeight/2, circleCenter.y-widthHeight/2, widthHeight, widthHeight);
        UIView *circle = [[UIView alloc] initWithFrame:circleFrame];
        CTXViewBorderRadius(circle, widthHeight/2, 0, [UIColor clearColor]);
        [self addSubview:circle];
        
        // 图片的位置
        CGFloat xGradeDistance = sin(_angle-gradeAngle) * (_outerRadius + image.size.width/2 + imageDistance);
        CGFloat yGradeDistance = cos(_angle-gradeAngle) * (_outerRadius + image.size.height/2 + imageDistance);
        CGPoint imageCenter = CGPointMake(_circleCenter.x - xGradeDistance, _circleCenter.y - yGradeDistance);
        // 图片
        CGRect imageFrame = CGRectMake(imageCenter.x-image.size.width/2, imageCenter.y-widthHeight/2-imageDistance, image.size.width, image.size.height);
        UIImageView *iv = [[UIImageView alloc] initWithFrame:imageFrame];
        [self addSubview:iv];
        
        if (grade >= (i / 5.0)) {
            iv.image = [UIImage imageNamed:@"gift02"];
            circle.backgroundColor = UIColorFromRGB(0x3d4650);
        } else {
            iv.image = [UIImage imageNamed:@"gift01"];
            circle.backgroundColor = UIColorFromRGB(0xffbd00);
        }
        // 选择图片
        CGFloat rotateAngle = -(_angle - gradeAngle);
        iv.transform = CGAffineTransformRotate(iv.transform, rotateAngle);
    }
}

#pragma mark - 设置等级

- (void) setGrade:(CGFloat)grade {
    _grade = grade;
    gradeProgress = 0;
    
    [self addGiftViewWithGrade:(CGFloat)grade];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink {
    [displayLink invalidate];
    displayLink = nil;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (gradeProgress >= 1.0) {
        [self stopDisplayLink];
        
        return;
    }
    
    gradeProgress += 0.02;
    CGFloat gradeAngle = _angle * 2 * (_grade * gradeProgress);
    
    // UIBezierPath
    UIBezierPath *gradePath = [UIBezierPath bezierPath];
    // 起点：外层弧线的左端
    [gradePath moveToPoint:CGPointMake(_edgeRadius, self.frame.size.height - _outerMarginBottom)];
    // 外层弧线
    CGFloat gradeStartAngle = M_PI * 1.5 - _angle;
    CGFloat gradeEndAngle = gradeStartAngle + gradeAngle;
    [gradePath addArcWithCenter:_circleCenter radius:_outerRadius startAngle:gradeStartAngle endAngle:gradeEndAngle clockwise:YES];
    
    // 右侧的半圆
    // 根据圆心center，计算两侧半圆的位置
    CGFloat xGradeDistance = sin(_angle-gradeAngle) * (_outerRadius - _edgeRadius);
    CGFloat yGradeDistance = cos(_angle-gradeAngle) * (_outerRadius - _edgeRadius);
    CGPoint gradeRightCenter = CGPointMake(_circleCenter.x - xGradeDistance, _circleCenter.y - yGradeDistance);
    CGFloat gradeRightStartAngle = M_PI * 1.5 - (_angle - gradeAngle);
    CGFloat gradeRightEndAngle = M_PI * 0.5 - (_angle - gradeAngle);
    
    [gradePath addArcWithCenter:gradeRightCenter radius:_edgeRadius startAngle:gradeRightStartAngle endAngle:gradeRightEndAngle clockwise:YES];
    
    // 内层弧线
    [gradePath addArcWithCenter:_circleCenter radius:_innterRadius startAngle:gradeEndAngle endAngle:gradeStartAngle clockwise:NO];
    // 左侧的半圆
    [gradePath addArcWithCenter:_leftCenter radius:_edgeRadius startAngle:_leftStartAngle endAngle:_leftEndAngle clockwise:YES];
    
    if (!_gradeLayer) {
        _gradeLayer = [[CAShapeLayer alloc] init];
        _gradeLayer.strokeColor = [UIColor blueColor].CGColor;
        _gradeLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_gradeLayer];
    }
    
    _gradeLayer.path = gradePath.CGPath;
    
    if (!_gradeGradientLayer) {
        _gradeGradientLayer = [CAGradientLayer layer];
        _gradeGradientLayer.frame = self.bounds;
        _gradeGradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xf4ba09).CGColor,
                                      (__bridge id)UIColorFromRGB(0x0376ca).CGColor ];
        _gradeGradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradeGradientLayer.endPoint = CGPointMake(1, 0.5);
        [self.layer addSublayer:_gradeGradientLayer];
        //
        _gradeGradientLayer.mask = _gradeLayer;
    }
}

@end
