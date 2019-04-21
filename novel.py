# -*- coding: utf-8 -*- 
import urllib2
import re
import MySQLdb
import sys
import datetime
import pymysql

def get_source_code( url ):
    request = urllib2.Request(url)
    request.add_header("user-agent","Mozilla/5.0")
    response = urllib2.urlopen(request)
    return response.read()

novel = []

table = sys.argv[1]

novel_main_url = sys.argv[2]

print table,novel_main_url

#novel_main_url = "https://www.biquge5200.cc/2_2599/"

#novel_main_url = "https://www.biquge5200.cc/52_52787/"

novel_main_content = get_source_code(novel_main_url)

chapter_header = re.finditer(r"<dd><a href=\'(.*?)\' >(.*?)<\/a><\/dd>",novel_main_content)

for chapter in chapter_header :
    chapter_name = chapter.group(2)
    chapter_website = chapter.group(1)
    chapter_content = re.search(r"<div id=\"content\">(.*?)<\/div>" \
        ,get_source_code(chapter_website),re.S).group(1)
    #chapter_index = chapter_name[2:chapter_name.find(u"章".)]
    #\xd5\xc2->章
    #chapter_index = chapter_name[2:chapter_name.find("\xd5\xc2")] 
    #print chapter_website
    chapter_index = re.search(r".*\/(\d+?).html",chapter_website).group(1)
    chapter_temp = {
        "index":chapter_index
        ,"chapter":chapter_name.decode("gbk")
        ,"website":chapter_website.decode("gbk")
        ,"content":chapter_content.decode("gbk")
        ,"date":datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    }
    novel.append(chapter_temp)


#print novel[0]["index"]
#db = MySQLdb.connect("192.168.2.104","novel","novel@123","novel",port=3308)

db = MySQLdb.connect("192.168.2.104","novel","novel@123","novel",port=3308,charset='utf8')

cursor = db.cursor()

for each in novel :
    try :
        #print table,each["index"],each["chapter"],each["website"],pymysql.escape_string(each["content"])
        #print "insert into %s(chapter_index,chapter_name,chapter_website,chapter_content) \
        #values (%s,%s,%s,%s)"%(table,each["index"],each["chapter"],each["website"],pymysql.escape_string(each["content"]))
        sql= "insert into %s(chapter_index,chapter_name,chapter_website,chapter_content,update_time) \
        values "%table
        cursor.execute(sql+"(%s,%s,%s,%s,%s)",(each["index"],each["chapter"],each["website"],each["content"],each["date"]))
        db.commit()
    except BaseException,args:
        print repr(args)
        db.rollback()
db.close()




'''

#print response.read()
#print response.read()
#print len(response.read())
t=response.read()
#print t
reobj = re.finditer(r"<dd><a href=\'(.*?)\' >(.*?)<\/a><\/dd>",t)

    #<a href=\"(.*)?\">\(.*\)<\/a>
for each in reobj :
    print each.group(1)+':'+each.group(2)

if reobj:
    print reobj.group(1)
    print "11
    


content_url = 'https://www.biquge5200.cc/2_2599/163240148.html'

content = urllib2.urlopen(content_url)

text = content.read()

#print text

reobj_text = re.search(r"<div id=\"content\">(.*?)<\/div>",text,re.S)

if reobj_text:
    print reobj_text.group(1)   



'''



'''
CREATE TABLE `TDTSG` (
  `chapter_name` varchar(50) NOT NULL COMMENT '章节名',
  `chapter_index` int(11) NOT NULL COMMENT '章回数',
  `chapter_website` varchar(500) NOT NULL COMMENT '章节网站',
  `chapter_content` varchar(5000) NOT NULL COMMENT '章节内容',
  PRIMARY KEY (`chapter_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
'''