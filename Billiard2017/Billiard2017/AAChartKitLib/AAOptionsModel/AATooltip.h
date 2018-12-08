//
//  AATooltip.h
//  AAChartKit
//
//  Created by An An on 17/1/5.
//  Copyright © 2017年 An An. All rights reserved.
//*************** ...... SOURCE CODE ...... ***************
//***...................................................***
//*** https://github.com/AAChartModel/AAChartKit        ***
//*** https://github.com/AAChartModel/AAChartKit-Swift  ***
//***...................................................***
//*************** ...... SOURCE CODE ...... ***************

/*
 
 * -------------------------------------------------------------------------------
 *
 * 🌕 🌖 🌗 🌘  ❀❀❀   WARM TIPS!!!   ❀❀❀ 🌑 🌒 🌓 🌔
 *
 * Please contact me on GitHub,if there are any problems encountered in use.
 * GitHub Issues : https://github.com/AAChartModel/AAChartKit/issues
 * -------------------------------------------------------------------------------
 * And if you want to contribute for this project, please contact me as well
 * GitHub        : https://github.com/AAChartModel
 * StackOverflow : https://stackoverflow.com/users/7842508/codeforu
 * JianShu       : https://www.jianshu.com/u/f1e6753d4254
 * SegmentFault  : https://segmentfault.com/u/huanghunbieguan
 *
 * -------------------------------------------------------------------------------
 
 */

#import <Foundation/Foundation.h>
#import "AAGlobalMacro.h"

@interface AATooltip : NSObject

AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, backgroundColor) 
AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, borderColor)
AAPropStatementAndPropSetFuncStatement(strong, AATooltip, NSNumber *, borderRadius) //边框的圆角半径
AAPropStatementAndPropSetFuncStatement(strong, AATooltip, NSNumber *, borderWidth) //边框宽度
AAPropStatementAndPropSetFuncStatement(strong, AATooltip, NSDictionary *, style) //为提示框添加CSS样式。提示框同样能够通过 CSS 类 .highcharts-tooltip 来设定样式。 默认是：@{@"color":@"#333333",@"cursor":@"default",@"fontSize":@"12px",@"pointerEvents":@"none",@"whiteSpace":@"nowrap" }

AAPropStatementAndPropSetFuncStatement(assign, AATooltip, BOOL,       enabled) 
AAPropStatementAndPropSetFuncStatement(assign, AATooltip, BOOL,       useHTML) 
AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, formatter) 
AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, headerFormat) 
AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, pointFormat) 
AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, footerFormat) 
AAPropStatementAndPropSetFuncStatement(strong, AATooltip, NSNumber *, valueDecimals) //设置取值精确到小数点后几位
AAPropStatementAndPropSetFuncStatement(assign, AATooltip, BOOL,       shared) 
AAPropStatementAndPropSetFuncStatement(assign, AATooltip, BOOL,       crosshairs) 

AAPropStatementAndPropSetFuncStatement(copy,   AATooltip, NSString *, valueSuffix) 
//AAPropStatementAndPropSetFuncStatement(assign, AATooltip, BOOL,       followTouchMove) //在触摸设备上，tooltip.followTouchMove选项为true（默认）时，平移需要两根手指。若要允许用一根手指平移，请将followTouchMove设置为false。





@end
