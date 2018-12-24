#!/bin/bash
#===---UP_NOVEL_TO_RSS.SH -----------------------------------*- sh -*--===//
#
#     用于实现从笔趣阁网址上获取小说更新并生成RSS格式文件
#     源程序采用"https://www.biquge5200.cc/2_2599/"全职法师
#
#===----------------------------------------------------------------------===//
#/参数列表：
#/  siteweb:小说章节主页
#/  rss_file:RSS主页文件
#/  abs_path:设置绝对路径
#/  web_source_code:下载小说章节主页的文件名
#/  log_file:更新日志文件
#/
#===----------------------------------------------------------------------===//


# 设置变量
# 获取最新章节信息网址
siteweb=$1

# 用于更新的RSS主页
rss_file=$2

# 下载小说章节主页的文件名
web_source_code=$3

# 更新日志文件名
log_file=$4

# 用于调试，输出预设网址与标签
#echo $siteweb $rss_file $web_source_code


### STEP ONE 获取目标网址源码curl与章节名grep|sed
# 下载网页源码
curl -sA "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36" $siteweb | iconv -f gbk -t utf-8 > $web_source_code
if [ $? -ne 0 ];then
sleep   5
curl -sA "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36" $siteweb | iconv -f gbk -t utf-8 > $web_source_code
fi

# <dd> <a href=\"\(.*\)\">.*<\/dd>正则获取章节内容网址，取前12行记录
target_web=($(grep "<dd>" ${web_source_code} | \
sed "s/<dd><a href=\"\(.*\)\">.*<\/dd>/\1/" | \
tail -n 10|sed 's/ //g'))

# <dd> <a href=\".*\">\(.*\)<\/a><\/dd>正则获取章节名，取前12行记录
target_chapter=($(grep "<dd>" ${web_source_code} | \
sed  's/<dd><a href=\".*\">\(.*\)<\/a><\/dd>/\1/'| \
tail -n 10|sed 's/ //g'))

#获取章节内容
#   curl -sk ${target_web[0]%$'\r'} | grep -A 2 -e "<div id=\"content\">" | \
#   tail -n 1 |sed 's/<br\/>/\n/g' 

# 获取已有章节名，rss上已发布章节
rss_chapter=($(grep "<title>" $rss_file | sed -n '2,$p' | \
sed 's/<title>\(.*\)<\/title>/\1/g'))


### STEP TWO 比较章节名确认RSS未发布内容
# 计算未更新内容，取已发布最新的章节名与最新获取的章节名对比，获取未发布数量
flag=(0 0 0 0 0 0 0 0 0 0)
index=0
for name in ${target_chapter[*]%$'\r'}
do 
    for rss_name in ${rss_chapter[*]}
    do
        if [ "$name" == "$rss_name" ];then
            flag[index]=1
            break    
        fi
    done
    index=$(($index+1))
done
#echo ${flag[@]}
# 确保最新获取的章节名并未发布
#flag=0
#for chaptername in ${rss_chapter[*]%'\r'}
#do
#    if [ "$chaptername" == ${target_chapter[0]%$'\r'} ];then
#        flag=1
#        break
#    fi
#done

# 获取小说更新的内容并更新RSS文件
for((i=0;i<${#flag[@]};i=i+1))
do
    #获取小说内容
    if [ ${flag[$i]} -eq 1 -o x == x"${target_web[$i]%$'\r'}" ];then 
    continue
    fi
    #echo ${target_web[$i]%$'\r'}
    content=$(curl -sk  ${target_web[$i]%$'\r'}|\
    iconv -f gbk -t utf-8|\
    grep -e "<div id=\"content\">"|\
    sed 's/.*<div id=\"content\">//g')
    count=0
    while [ $? -ne 0 -a $count -ne 5 ]
    do
    sleep 5
    count=$(($count+1))
    content=$(curl -sk  ${target_web[$i]%$'\r'}|\
    iconv -f gbk -t utf-8|\
    grep -e "<div id=\"content\">"|\
    sed 's/.*<div id=\"content\">//g')   
    done
    if [ ${#content} -lt 500 ];then
	continue
    fi
    #以RSS格式写入文件，即更新<item></item>
    sed -i "9a </item>"  ${rss_file}
    sed -i "9a <description><\![CDATA[${content}]]></description>" ${rss_file}
    sed -i "9a <link>${target_web[$i]%$'\r'}</link>"   ${rss_file}
    sed -i "9a <title>${target_chapter[$i]%$'\r'}</title>" ${rss_file}
    sed -i "9a <pubDate>`date`</pubDate>" ${rss_file}
    sed -i "9a <guid isPermaLink=\"false\">`date +%s`${i}</guid>" ${rss_file}
    sed -i "9a <item>"    ${rss_file}
    #更新发布时间
    sed -i "s/<lastBuildDate>\(.*\)<\/lastBuildDate>/<lastBuildDate>$(date)<\/lastBuildDate>/g" ${rss_file}   
    #更新日志
    echo ${target_chapter[$i]%$'\r'}"|"${target_web[$i]%$'\r'}"|"`date` >> ${log_file}
done



### STEP THREE 删除多余item（大于10）与临时文件 
start=($(grep -noe "<item>" ${rss_file}| awk -F : '{print $1}'))
end=$(grep -noe "<\/item>" ${rss_file}|tail -n 1|awk -F : '{print $1}')
if [ x${start[20]} != x ];then
sed -i "${start[20]},${end}d" ${rss_file}
fi
rm -f ${web_source_code}

#echo `date` >> ${log_file}
