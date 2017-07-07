//
//  XAuxiliaryCalculationHelper.m
//  RecordLife
//
//  Created by 谢俊逸 on 18/01/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "XAuxiliaryCalculationHelper.h"

@implementation XAuxiliaryCalculationHelper


+ (instancetype)shareCalculationHelper {
    static XAuxiliaryCalculationHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[XAuxiliaryCalculationHelper alloc] init];
    });
    return helper;
}
// 全正高度比值
- (CGFloat)calculateTheProportionOfHeightByTop:(CGFloat)top bottom:(CGFloat)bottom height:(CGFloat)height {
    NSCAssert((top >= height) && (height >= bottom), @"The data must meet the following conditions “bottom < height < top “");
    return fabs((height - bottom)/(top - bottom));
}

/// 计算 目前高度   /  （正高度／负高度）的比值
- (CGFloat)calculateThePositiveNegativeProportionOfHeightByTop:(CGFloat)top bottom:(CGFloat)bottom height:(CGFloat)height {
    NSCAssert((top >= height) && (height >= bottom), @"The data must meet the following conditions “bottom < height < top “");
    if (height >= 0) {
        return fabs(height / top);
    } else {
        return fabs(height / bottom);
    }
}

- (CGFloat)calculateTheProportionOfWidthByIdx:(CGFloat)idx count:(NSUInteger)count {
    NSCAssert((idx >= 0) && (idx < count),@"idx > 0 && idx < count");
    return (idx*2+1)/(count*2);
}

//Compute Stroke Start Array
- (NSMutableArray *)computeStrokeStartArrayWithDataArray:(NSMutableArray *)dataArray {
    NSMutableArray *startArray = [[NSMutableArray alloc] init];
    
    //计算总count
    __block CGFloat count = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        count = count + number.doubleValue;
    }];
    //计算start比例
    __block CGFloat priorCount = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        NSNumber *start = @(priorCount/count);
        priorCount = priorCount + number.doubleValue;
        //添加到数组中
        [startArray addObject:start];
    }];
    return startArray;
}

//Compute Stroke End Array
- (NSMutableArray *)computeStrokeEndArrayWithDataArray:(NSMutableArray *)dataArray {
    NSMutableArray *endArray = [[NSMutableArray alloc] init];
    
    //计算总count
    __block CGFloat count = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        count = count + number.doubleValue;
    }];
    //计算end比例
    __block CGFloat nowCount = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        nowCount = nowCount + number.doubleValue;
        NSNumber *start = @(nowCount/count);
        //添加到数组中
        [endArray addObject:start];
    }];
    return endArray;
}


//find Percentage Of Angle In Circle
- (CGFloat) findPercentageOfAngleInCircle:(CGPoint)center fromPoint:(CGPoint)reference{
    //Find angle of line Passing In Reference And Center
    CGFloat angleOfLine = atanf((reference.y - center.y) / (reference.x - center.x));
    CGFloat percentage = (angleOfLine + M_PI/2)/(2 * M_PI);
    return (reference.x - center.x) > 0 ? percentage : percentage + .5;
}

// 改变成容易绘制的坐标系
- (CGPoint)changeCoordinateSystem:(CGPoint)point withViewHeight:(CGFloat)height {
    CGPoint temPoint = CGPointMake(point.x, height - point.y);
    return temPoint;
}


- (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    CGPoint controlPoint = [self midPointBetweenPoint1:point1 andPoint2:point2];
    CGFloat diffY = abs((int) (point2.y - controlPoint.y));
    if (point1.y < point2.y)
        controlPoint.y += diffY;
    else if (point1.y > point2.y)
        controlPoint.y -= diffY;
    return controlPoint;
}

- (CGPoint)midPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
}


/// 计算点是否在多边形内
- (BOOL)containPoint:(NSValue *)pointValue Points:(NSMutableArray<NSValue *> *)pointsArray {
    float vertx[4] = {0,0,0,0};
    float verty[4] = {0,0,0,0};
    CGPoint targetPoint = pointValue.CGPointValue;
    unsigned i = 0;
    for (i = 0; i < pointsArray.count; i = i + 1) {
        CGPoint point1 = pointsArray[i].CGPointValue;
        vertx[i] = point1.x;
        verty[i] = point1.y;
    }
    return pnpoly(4, vertx, verty, targetPoint.x, targetPoint.y);
}
// 判断算法
int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy) {
    int i, j, c = 0;
    for (i = 0, j = nvert - 1; i < nvert; j = i++) {
        if (((verty[i] > testy) != (verty[j] > testy)) &&
            (testx <
             (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) +
             vertx[i]))
            c = !c;
    }
    return c;
}


/// 翻转递增
- (CGFloat)getYInFilpIncrementWithBoundsH:(CGFloat)boudnsHeight targetHeight:(CGFloat)targetHeight percentage:(CGFloat)percentage {
    return boudnsHeight - (boudnsHeight - targetHeight) * percentage;
}

@end
