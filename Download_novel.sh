### 设置变量
# 获取最新章节信息网址
siteweb=$1

# 保存的小说文件
novel_file=$2

# 下载小说章节主页的文件名
web_source_code=`date +%s`

### STEP ONE 获取目标网址源码curl与章节名grep|sed
# 下载网页源码
curl -sk $siteweb -o $web_source_code

# <dd> <a href=\"\(.*\)\">.*<\/dd>正则获取章节内容网址，取前12行记录
target_web=($(grep "<dd>" ${web_source_code} | \
sed "s/<dd> <a href=\"\(.*\)\">.*<\/dd>/https:\/\/www.biqudu.com\1/" | \
tail -n +13))

# <dd> <a href=\".*\">\(.*\)<\/a><\/dd>正则获取章节名，取前12行记录
target_chapter=($(grep "<dd>" ${web_source_code} | \
sed  's/<dd> <a href=\".*\">\(.*\)<\/a><\/dd>/\1/'| \
tail -n +13|sed 's/ //g'))

b=''
p1=0
for((i=0;i<${#target_web[*]};i=i+1))
do
    content=$(curl -sk ${target_web[$i]%$'\r'}| grep -A 2 -e "<div id=\"content\">" | \
    tail -n 1)
    #echo $i
    echo -e ${target_chapter[$i]%$'\r'}  >> ${novel_file}
    echo -e ${content//<br\/>/"\n"}| sed 's/\r//g' >> ${novel_file}
    echo -e "\n\n\n" >> ${novel_file}
    p2=$p1
    p1=$((100*$(($i+1))/${#target_web[*]}))
    #echo p2:${p2} p1:${p1}
    if [ $p1 -gt $p2 -a $((${p1}%2)) -gt 0 ];then
        b=#$b
    fi
    printf "progress:[%-50s]%d%%\r" $b $p1    
done
echo  -ne "\nfinish!"




