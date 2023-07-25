---
title: "Kodi-家庭影音系统解决方案"
date: 2023-07-22T06:11:06+08:00
draft: true
---



{{< toc >}}

# Kodi-家庭影院系统解决方案



## 项目介绍

---

**【项目名称】Kodi-家庭影院系统解决方案**

本项目旨在为家庭提供流畅高清视频资源的播放体验。为实现这一目标，利用阿里云盘作为资源存储平台，`Alist`提供`WebDAV`协议方便访问，使用`Rclone`进行网络文件映射，`Nastool`负责刮削元数据。最后通过`Kodi`媒体播放器在投影仪或电视上轻松播放视频，享受高效便捷的视听体验



**【视频介绍】视频传送门 🎬**

<a href="https://www.bilibili.com/video/BV1rh411T7aG/?spm_id_from=333.999.0.0" target="_blank">【斥资8元，历时2天半，搭建4K私人家庭影院，纵享10T高清资源，从此实现观影自由】 </a>



## 组件说明

---

- `Aliyunpan`：阿里云盘是一款速度快|不打扰|够安全|易于分享的网盘，你可以在这里存储管理和探索内容，尽情打造丰富的数字世界
- `Alist`：一个支持多种存储，支持网页浏览和 WebDAV 的文件列表程序，由 gin 和 Solidjs 驱动
- `Rclone`:  一个用于管理云存储上的文件的命令行程序，它是云供应商 Web 存储接口的功能丰富的替代方案。超过 70 种云存储产品支持 rclone，包括 S3 对象存储、企业和消费者文件存储服务以及标准传输协议
- `Nastool`: 一个专注于刮削媒体资源元数据的工具，能够自动添加详细描述和封面等信息，以优化资源管理和浏览效率
- `Kodi`：一款功能强大的媒体播放器，支持多种音视频格式，并提供丰富的插件和扩展功能。用户可将其安装在投影仪或电视上，从而轻松享受高品质的视频播放体验，丰富家庭娱乐生活



## 快速部署

### 环境说明

---

- 硬件环境：Centos 7.9 *1 | 2cores | 4G | 40G云磁盘

- 软件环境

  - Docker 24.0.4
  - Python 3.6.8
  - fusermount  2.9.2
  - rclone 1.63.1
  
  

### 数据流转

------

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-033412.jpg" alt="示例图片" width="75%" height="75%" />



{{< hint type=tip icon=gdoc_github title=数据流转说明 >}}
{{< /hint >}}



1. 从各种影视网站或者`Telegram`频道转存资源到阿里云盘；
2. `Alist`挂载阿里云盘提供`webdav`服务；
3. `rclone`工具使用`webdav`协议，将阿里云盘作为网络文件映射到服务器上，完成本地的读写；
4. `Nastool`启动后，控制台配置`TMDB`网站的`API Key`进行刮削，元数据直接远程落盘到阿里云盘；
5. `Kodi` 安装到电视或者投影仪，通过`Alist`提供的`webdav`协议，播放影视资源





{{< hint type=tip icon=gdoc_github title=阿里云盘容量说明 >}}
{{< /hint >}}

SVIP会员到期后，如不继续续费，将被收回特权容量;当收回容量时您盘中已存储的文件，小于当前可使用容量，则文件将不受任何影响，仍可正常使用。当收回容量时您盘中已存储的文件超出或等于当前可使用容量超出可使用容量部分的文件不会被删除但您将无法向盘中存储文件，即上传、转存等功能暂不可用，其他功能不受影响.





<font color=red>**阿里云盘白嫖方案**</font>


1. 开通SVIP(首次开通8元)后会赠送8T空间，在会员还未过期之前尽可能多的转存资源，会员过期文件不会删除，只是不能上传和转存
2. 阿里云盘签到，赠送SVIP、延期卡（延期赠送的8T容量）和影音卡，这些羊毛没道理不薅



{{< hint type=note icon=gdoc_github title=GitHub >}}
使用青龙面板定时任务平台可以实现阿里云盘自动签到，解放你的双手。点击进入传送门 👉🏻<a href="https://github.com/opsbear2/aliyundriveDailyCheck/tree/master" target="_blank">青龙面板阿里云盘自动签到</a>
{{< /hint >}}

---

### Alist挂载阿里云盘

服务器需要安装`docker`环境，参考：<a href="https://docs.docker.com/engine/install/centos/" target="_blank">docker官方文档</a>

**启动alist容器**

```shell
docker run -d \
--restart=always \
-v /data/alist:/opt/alist/data \
-p 5244:5244 \
--name="alist" \
xhofe/alist:latest
```



**检查alist容器状态**

```shell
docker ps -a | grep alist
0163adad6f08   xhofe/alist:latest            "/entrypoint.sh"          8 hours ago    Up 7 hours             0.0.0.0:5244->5244/tcp, :::5244->5244/tcp, 5245/tcp   alist
```

 

**查询初始密码**

```shell
docker exec -it alist ./alist admin
INFO[2023-07-21 19:55:09] reading config file: data/config.json
INFO[2023-07-21 19:55:09] load config from env with prefix: ALIST_
INFO[2023-07-21 19:55:09] init logrus...
INFO[2023-07-21 19:55:09] admin user's info:
username: admin
password: IcZOvMFKksJx #初始密码，登录控制台后修改新密码
```



**挂载阿里云盘**

---

1. 后台地址：http://ip:5244，登录控制台，初始密码参考`./alist admin`的password

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-040137.png" alt="示例图片" width="100%" height="80%" />

---

2. 修改密码

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-040650.png" alt="示例图片" width="100%" height="85%" />

---

3. 挂载阿里云盘，选择`阿里云盘OPEN`，添加刷新令牌，令牌获取方法参考： <a href="https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html" target="_blank">获取阿里云盘refresh_token</a>

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-041220.png" alt="示例图片" width="100%" height="85%" />

---

4. 挂载完成后，可以看到阿里云盘的文件，如下图所示

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-041758.png" alt="示例图片" width="100%" height="85%" />



### Rclone映射云盘文件

---

**安装Rclone环境**

官方提供了一键安装脚本，参考： <a href="https://rclone.org/install/" target="_blank">rclone官方文档</a>

```shell
curl https://rclone.org/install.sh | sudo bash
```

---

**配置Rclone**

配置文件路径：`/root/.config/rclone/rclone.conf`，点开查看配置步骤

{{< expand "配置详情" "..." >}}

```shell
rclone config # 配置rclone
Current remotes:

Name                 Type
====                 ====


e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> n # 新建远程挂载

Enter name for new remote.
name> your_remote_name # 挂载名称

Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
 1 / 1Fichier
   \ (fichier)
 2 / Akamai NetStorage
   \ (netstorage)
 3 / Alias for an existing remote
   \ (alias)
 4 / Amazon Drive
   \ (amazon cloud drive)
 5 / Amazon S3 Compliant Storage Providers including AWS, Alibaba, ArvanCloud, Ceph, China Mobile, Cloudflare, GCS, DigitalOcean, Dreamhost, Huawei OBS, IBM COS, IDrive e2, IONOS Cloud, Liara, Lyve Cloud, Minio, Netease, Petabox, RackCorp, Scaleway, SeaweedFS, StackPath, Storj, Tencent COS, Qiniu and Wasabi
   \ (s3)
 6 / Backblaze B2
   \ (b2)
 7 / Better checksums for other remotes
   \ (hasher)
 8 / Box
   \ (box)
 9 / Cache a remote
   \ (cache)
10 / Citrix Sharefile
   \ (sharefile)
11 / Combine several remotes into one
   \ (combine)
12 / Compress a remote
   \ (compress)
13 / Dropbox
   \ (dropbox)
14 / Encrypt/Decrypt a remote
   \ (crypt)
15 / Enterprise File Fabric
   \ (filefabric)
16 / FTP
   \ (ftp)
17 / Google Cloud Storage (this is not Google Drive)
   \ (google cloud storage)
18 / Google Drive
   \ (drive)
19 / Google Photos
   \ (google photos)
20 / HTTP
   \ (http)
21 / Hadoop distributed file system
   \ (hdfs)
22 / HiDrive
   \ (hidrive)
23 / In memory object storage system.
   \ (memory)
24 / Internet Archive
   \ (internetarchive)
25 / Jottacloud
   \ (jottacloud)
26 / Koofr, Digi Storage and other Koofr-compatible storage providers
   \ (koofr)
27 / Local Disk
   \ (local)
28 / Mail.ru Cloud
   \ (mailru)
29 / Mega
   \ (mega)
30 / Microsoft Azure Blob Storage
   \ (azureblob)
31 / Microsoft OneDrive
   \ (onedrive)
32 / OpenDrive
   \ (opendrive)
33 / OpenStack Swift (Rackspace Cloud Files, Blomp Cloud Storage, Memset Memstore, OVH)
   \ (swift)
34 / Oracle Cloud Infrastructure Object Storage
   \ (oracleobjectstorage)
35 / Pcloud
   \ (pcloud)
36 / PikPak
   \ (pikpak)
37 / Put.io
   \ (putio)
38 / QingCloud Object Storage
   \ (qingstor)
39 / SMB / CIFS
   \ (smb)
40 / SSH/SFTP
   \ (sftp)
41 / Sia Decentralized Cloud
   \ (sia)
42 / Storj Decentralized Cloud Storage
   \ (storj)
43 / Sugarsync
   \ (sugarsync)
44 / Transparently chunk/split large files
   \ (chunker)
45 / Union merges the contents of several upstream fs
   \ (union)
46 / Uptobox
   \ (uptobox)
47 / WebDAV
   \ (webdav)
48 / Yandex Disk
   \ (yandex)
49 / Zoho
   \ (zoho)
50 / premiumize.me
   \ (premiumizeme)
51 / seafile
   \ (seafile)
Storage> 47 # 选择47 webdav协议

Option url.
URL of http host to connect to.
E.g. https://example.com.
Enter a value.
url> http://127.0.0.1:5244 # 填写webdav的地址（alist的地址）

Option vendor.
Name of the WebDAV site/service/software you are using.
Choose a number from below, or type in your own value.
Press Enter to leave empty.
 1 / Fastmail Files
   \ (fastmail)
 2 / Nextcloud
   \ (nextcloud)
 3 / Owncloud
   \ (owncloud)
 4 / Sharepoint Online, authenticated by Microsoft account
   \ (sharepoint)
 5 / Sharepoint with NTLM authentication, usually self-hosted or on-premises
   \ (sharepoint-ntlm)
 6 / Other site/service or software
   \ (other)
vendor> 6 # 选择6其他

Option user.
User name.
In case NTLM authentication is used, the username should be in the format 'Domain\User'.
Enter a value. Press Enter to leave empty.   # 默认回车
user>

Option pass.
Password.
Choose an alternative below. Press Enter for the default (n).
y) Yes, type in my own password
g) Generate random password
n) No, leave this optional password blank (default)
y/g/n> y # 若alist设置了密码，选择y
Enter the password: # 输入密码
password:
Confirm the password: # 再次输入密码
password:

Option bearer_token.
Bearer token instead of user/pass (e.g. a Macaroon).
Enter a value. Press Enter to leave empty.
bearer_token>

Edit advanced config?
y) Yes
n) No (default)
y/n> n # 选择不编辑配置文件，或者直接回车

Configuration complete.
Options:
- type: webdav
- url: http:/127.0.0.1:5244
- vendor: other
- pass: *** ENCRYPTED ***
Keep this "your_remote_name" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> y # 确认配置，选择y

Current remotes:

Name                 Type
====                 ====
alist                webdav
webdav               webdav
your_remote_name     webdav

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q # 保存退出
```

{{< /expand >}}



**挂载磁盘到本地卷**

安装`fuse`依赖

```shell
 yum install -y fuse
 ln -s /usr/bin/fusermount /usr/bin/fusermount3
```



创建挂载目录&挂载

```shell
mkdir -p /data1/aliyunpan 

rclone mount alist: /data1/aliyunpan \
--use-mmap \
--umask 000 \
--allow-other \
--allow-non-empty \
--dir-cache-time 24h \
--cache-dir=/home/cache \
--vfs-cache-mode full \
--buffer-size 512M \
--vfs-read-chunk-size 16M \
--vfs-read-chunk-size-limit 64M \
--vfs-cache-max-size 10G \
--daemon
```



查看本地磁盘，目录结构和阿里云盘一致，在linux终端可以正常读写文件，至此rclone配置完成

```shell
df -h |grep alist
alist:          1.0P     0  1.0P    0% /data1/aliyunpan

cd /data1/aliyunpan

tree -L 2
.
└── bear2
    ├── Books
    ├── Cartoon
    ├── Cartoon_temp
    ├── Movies
    ├── Movies_temp
    ├── Tech
    ├── tmp
    ├── Tools
    ├── TV
    └── TV_temp

11 directories, 0 files
```



### Nastool刮削元数据

**安装`Nastool`**

```shell
docker run -d \
    --name nas-tools \
    --hostname nas-tools \
    -p 9091:3000     \
    -v /data1/nastool/config:/config/  \
    -v /data1/aliyunpan/bear2:/media/  \ # 媒体资源目录，即rclone挂载云盘的目录
    -e NASTOOL_AUTO_UPDATE=false  \
    --add-host api.themoviedb.org:52.84.18.87 \ # tmdb自定义解析
		--add-host image.tmdb.org:84.17.46.53 \ # tmdb自定义解析
		--add-host www.themoviedb.org:52.84.125.129 \ # tmdb自定义解析
    --restart unless-stopped \
    nastool/nas-tools:latest
```



**查看容器运行状态**

```shell
docker ps -a |grep nastool
5d3aed28c426   nastool/nas-tools:latest      "/init"                   13 hours ago   Up 12 hours             0.0.0.0:9091->3000/tcp, :::9091->3000/tcp             nas-tools
```



**控制台配置**

1. 后台地址：http://ip:9091 ，初始账号：admin，初始密码：password，登录后修改密码

![image-20230722085620358](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-085620.png)

---

2. 设置TMDB刮削，需要注册TMDB账号，申请一个`API KEY` ，用来刮削元数据。申请方法参考： <a href="https://zhuanlan.zhihu.com/p/584568064" target="_blank">TMDB申请API KEY</a>

![image-20230722090025577](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-090025.png)

---

{{< hint type=tip icon=gdoc_github title=名词解释 >}}
{{< /hint >}}

> 刮削：本质上是一种基于文件名与目录结构匹配的，电影、剧集的相关图片剧情简介等信息的获取、展示过程，而这些海报、剧情简介被称为元数据



例如，有一部电影 `复仇者联盟4`，你要看到它的海报、剧情介绍。可是你手上现在只有一个mp4文件。要想获得上述信息，肯定要去某些地方找到海报、介绍，然后保存到存储或者本地，然后以某种方式予以展示，例如放到`emby`中展示海报墙

![image-20230722091219984](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-091220.png)

---



3.添加资源目录，配置定时同步



{{< hint type=tip icon=gdoc_github title=刮削过程说明 >}}
{{< /hint >}}

1. 转存一部新的电影放到 temp临时目录里，nastool会检测到目录有新增文件
2. 随后去 TDMB 网站刮削该资源的海报以及剧情简介等元数据信息
3. 刮削完成后连同原始视频文件+元数据 以`移动` 的方式存放到 Movies正式目录
4. 在移动的过程中，nastool会自动创建目录，重命名文件，这样就完成了一次资源刮削
   

![image-20230722092400195](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-092400.png)

---



4. 配合`定时目录同步`插件来进行实时刮削，时间配置遵循`crontab`

![image-20230722093217690](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-093217.png)

---



{{< hint type=warning icon=gdoc_github title=文件同步延迟问题 >}}
{{< /hint >}}

<font color=red>在云盘里新加资源后，`rclone`不能实时同步到本地磁盘，可以使用`sync`参数进行同步，简单方案可以直接重载磁盘</font>

```shell
# 卸载云盘
fusermount -qzu /data1/aliyunpan

# 挂载云盘
rclone mount alist: /data1/aliyunpan --use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --buffer-size 512M --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 64M --vfs-cache-max-size 10G --daemon
```

为方便重载磁盘，已将操作过程封装成脚本

```shell
sh rclone_tool.sh 
Usage: sh rclone_tool.sh [mount|umount|reload|check]
```



{{< expand "展开查看 " rclone_tool.sh"..." >}}

```shell
#!/bin/bash

# aliyunpan挂载工具

# 使用帮助
usage(){
    echo -e "\033[34mUsage: sh $0 [mount|umount|reload|check]\033[0m"
}

# 挂载云盘
mount(){
    /usr/bin/rclone mount alist: /data1/aliyunpan --use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --buffer-size 512M --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 64M --vfs-cache-max-size 10G --daemon
}

# 卸载云盘
umount(){
    /usr/bin/fusermount  -qzu /data1/aliyunpan
}

# 检查云盘挂载状态
check(){
    mount_status=$(df -h |grep alist | awk '{print $1}')
    # echo -e "mount_status:$mount_status"
    if [ -z $mount_status ];then
        echo -e "\033[33m>>> aliyunpan has been uninstalled, please check the system disk mount status \033[0m"
    else
        echo -e "\033[32m>>> aliyunpan has been mounted \033[0m"
    fi
}


case $1 in 
    mount) 
        mount && check ;;
    umount) 
        umount && check ;;
    reload) 
        umount && check && mount && check;;
    check)
        check ;;
    *)  
        usage ;;
esac
```

{{< /expand >}}



<font color=red>同样Nastool容器中的资源目录也有缓存，需要重启容器加载资源文件</font>

```shell
sh nastool_manage.sh
Usage: sh nastool_manage.sh [stop|start|check]
```



{{< expand "展开查看 " nastool_manage.sh"..." >}}

```shell
#!/bin/bash

# nastool管理工具

usage(){
    echo -e "\033[33mUsage: sh $0 [stop|start|check]\033[0m"
}

stop(){
    echo -e "\033[33m>>> nastool is stopping, wait a minute\033[0m"
    docker ps -a |grep nas-tools-v2 | awk  '{print $NF}' | xargs  docker stop >/dev/null
}

start(){
    docker ps -a |grep nas-tools-v2 | awk  '{print $NF}' | xargs  docker start >/dev/null
}

check(){
    netstat -nltp |grep 9092 >/dev/null && echo -e "\033[32m>>> nastool is running\033[0m" || echo -e "\033[33m>>> nastool has stopped\033[0m"
}

case $1 in
    stop)
        stop && check ;;
    start)
        start && check;;
    check)
        check;;
    *)
        usage;
esac
```

{{< /expand >}}


<font color=red>调用刷新缓存脚本</font>
{{< expand "展开查看 " refresh.sh"..." >}}
```shell
#!/bin/bash

# 阿里云盘新增资源后,刷新rclone挂载本地网盘,重启nastool容器刷新文件缓存

# 关闭nastool容器
sh /data1/nastool/bin/nastool_manage.sh stop

# 重载rclone
sh /data1/rclone/rclone_tool.sh reload

# 启动nastool容器
sh /data1/nastool/bin/nastool_manage.sh start
```
{{< /expand >}}
5. 控制台右上角，打开【实时日志】查看刮削记录

![image-20230722112113333](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-112113.png)

---



6. 在Alist后台查看刮削结果，可以看到三部【猩球崛起】资源都移动到Movie正式目录里，且按照地区进行分类。进入电影目录里面，会看到刮削的元数据

<img src="https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-112616.png" alt="示例图片" width="70%" height="70%" />

---



<table><tr><td bgcolor=yellow>至此刮削元数据过程结束，总结：Nastool刮削的前提是Alist挂载云盘提供webdav协议、Rclone通过webday协议映射网络文件到本地，保证刮削的元数据直接存储到阿里云盘</td></tr></table>



### Kodi播放高清视频

**安装Kodi**

Kodi 支持多种版本，根据实际情况进行安装，以下是Windows的安装流程

下载传送门👉🏻 <a href="https://kodi.tv/download/windows" target="_blank">Kodi-windows下载</a>，更多版本下载✋🏻 <a href="https://kodi.tv/download/" target="_blank">Kodi官方下载源</a>

1. 下载本地解压，安装
2. 调整语言为简体中文，修改之前要修改字体为`Arial`，负责会乱码，参考以下：
   1. <a href="https://www.touying.com/mip/t-38157-1.html" target="_blank">Kodi修改中文面板</a>
   2.  <a href="http://www.kodiplayer.cn/course/2991.html" target="_blank">Kodi显示乱码解决</a>
3. 添加视频，选择`webdav`协议，参考：  <a href="http://www.kodiplayer.cn/course/2961.html" target="_blank">Kodi通过webdav协议添加视频</a>
   1. 以`Alist`为例，在【添加网络位置】面板的需要注意，协议选择<font color=red>WebDav服务器（HTTP）</font>
   2. 服务器地址：`http://ip`
   3. 远程路径：`/dav`  # 固定值，和你挂载的目录无关
   4. 端口：`5244`
   5. 用户名&密码，同`Alist`
4. 添加资源到资料库，用于展示海报墙，参考： <a href="http://www.kodiplayer.cn/course/2866.html" target="_blank">Kodi添加海报墙</a>
5. 至此家庭影院系统搭建完毕，你可以在你设备上通过Kodi来观看4K高清资源了👏🏻



更多问题，请参考： <a href="http://www.kodiplayer.cn/" target="_blank">Kodi中文网</a>



## 其他

<font face="黑体" color=green size=5>资源储备展示😄</font>



- 阿里云盘，10T资源，会员过期根本不用担心，青龙面板自动签到薅羊毛 👉🏻 <a href="https://github.com/opsbear2/aliyundriveDailyCheck/tree/master" target="_blank">青龙面板阿里云盘自动签到</a>

![image-20230722131020570](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-131020.png)



- 影视资源
  - 剧集 59
  - 电影 152

![image-20230722132000385](https://cdn.jsdelivr.net/gh/opsbear2/ImagesForBlog@master/default/2023-07-22/20230722-132000.png)


