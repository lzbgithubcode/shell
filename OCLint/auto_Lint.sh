#!/bin/bash

COLOR_ERR="\033[1;31m"    #出错提示
COLOR_SUCC="\033[0;32m"  #成功提示
COLOR_QS="\033[1;37m"  #问题颜色
COLOR_AW="\033[0;37m"  #答案提示
COLOR_END="\033[1;34m"     #颜色结束符

# 寻找项目的 ProjectName
function searchProjectName () {
    find . -maxdepth 1 -name "*.xcodeproj"
}

function oclintForProject () {
   
    # 1.预先检测所需的安装包是否存在
    if which oclint 2>/dev/null; then
        echo 'oclint exist'
    else
        brew tap oclint/formulae
        brew install oclint
    fi
    

    if which xcodebuild 2>/dev/null; then
        echo 'xcodebuild exist'
    else
        echo '🤔️ 连 xcodebuild 都没有安装，玩鸡毛啊？ 🤔️'
    fi

    if which oclint 2>/dev/null; then
        echo 'oclint exist'
    else
        echo '😠 完蛋了你，玩 oclint 却不安装吗，你要闹哪样 😠'
        echo '😠 检查未准备好安装所需环境 😠'
    fi
    if which xcpretty 2>/dev/null; then
        echo 'xcpretty exist'
    else
        gem install xcpretty
    fi


    # 指定编码
    export LANG="zh_CN.UTF-8"
    export LC_COLLATE="zh_CN.UTF-8"
    export LC_CTYPE="zh_CN.UTF-8"
    export LC_MESSAGES="zh_CN.UTF-8"
    export LC_MONETARY="zh_CN.UTF-8"
    export LC_NUMERIC="zh_CN.UTF-8"
    export LC_TIME="zh_CN.UTF-8"
    export xcpretty=/usr/local/bin/xcpretty # xcpretty 的安装位置可以在终端用 which xcpretty找到

    searchFunctionName=`searchProjectName`
    path=${searchFunctionName}
    # 字符串替换函数。//表示全局替换 /表示匹配到的第一个结果替换。
    path=${path//.\//}  # ./BridgeLabiPhone.xcodeproj -> BridgeLabiPhone.xcodeproj
    path=${path//.xcodeproj/} # BridgeLabiPhone.xcodeproj -> BridgeLabiPhone
    
    myworkspace=$path".xcworkspace" # workspace名字
    myscheme=$path  # scheme名字

    # 2.清除上次编译数据先清除缓存
    if [ -d ./derivedData ]; then
        echo -e $COLOR_SUCC'-----清除上次编译数据derivedData-----'$COLOR_SUCC
        rm -rf ./derivedData
    fi

    # 3.xcodebuild clean
    echo '我正在清除编译缓存.......'
    xcodebuild -scheme $myscheme -workspace $myworkspace clean


    #4.生成编译数据
    echo '开始生成编译数据.......'
    xcodebuild -scheme $myscheme -workspace $myworkspace -configuration Debug | xcpretty -r json-compilation-database -o compile_commands.json

    if [ -f ./compile_commands.json ]; then
        echo -e $COLOR_SUCC'编译数据生成完毕😄😄😄'$COLOR_SUCC
    else
        echo -e $COLOR_ERR'编译数据生成失败😭😭😭'$COLOR_ERR
        return -1
    fi

    # 5.生成报表
     echo '努力生成报表中.......'
    oclint-json-compilation-database -e Pods -- -report-type html -o oclintReport.html \
    -rc LONG_LINE=200 \
    -disable-rule ShortVariableName \
    -disable-rule ObjCAssignIvarOutsideAccessors \
    -disable-rule AssignIvarOutsideAccessors \
    -max-priority-1=100000 \
    -max-priority-2=100000 \
    -max-priority-3=100000

    if [ -f ./oclintReport.html ]; then
        rm compile_commands.json
        echo -e $COLOR_SUCC'😄分析完毕😄'$COLOR_SUCC
    else
        echo -e $COLOR_ERR'😢分析失败😢'$COLOR_ERR
        return -1
    fi

    echo -e $COLOR_AW'脚本将自动打开 lint 的分析结果'$COLOR_AW
    #6. 用 safari 浏览器打开 oclint 的结果
    open -a "/Applications/Safari.app" oclintReport.html
}

oclintForProject
