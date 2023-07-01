本项目主要用于CentOS7.9的离线本地仓库的准备。  
在离线环境中经常需要进行相关工具或安全补丁RPM包安装，然而包之间存在大量依赖，离线环境下又无法直接使用yum。  
本项目基础思想是使用干净的CentOS系统环境，通过*yum*下载并缓存相应组件及其依赖的RPM库，再通过*createrepo*创建本地仓储。将本地仓储包传至目标离线环境进行本地仓储安装，从而支持通过yum安装相关工具以及补丁。
# 离线库准备
`prepare-local-repo`目录下为离线库的相关脚本，其中`conf`目录中包含了两个文件用户配置需要下载缓存的离线工具：
* [yum.list](./prepare-local-repo/conf/yum.list)：每行写入要缓存的工具名，自动通过`yum install`命令下载缓存
* [yum-group.list](./prepare-local-repo/conf/yum-group.list)：每行写入要缓存的工具组名，自动通过`yum groupinstall`命令下载缓存（目前只支持centos原生工具组，例如`Development Tools`，如需额外支持，需扩展[comps.xml](./prepare-local-repo/yum-repo/comps.xml)）

离线库准备包括两种方式：原生CentOS7环境和Docker环境（推荐）。
## 原生CentOS7环境
1. 将项目下的prepare-local-repo目录放至纯净的CentOS7环境的任意目录下
2. CentOS7环境中需要提前安装好`createrepo`工具:
   ```
   # yum install -y createrepo
   ```
3. 修改conf目录下的yum.list和yum-group.list，确认需要下载缓存的RPM工具
4. 在prepare-local-repo目录下运行`./prepare-local-repo.sh`
5. 在其下out目录会生成打包好的离线仓储：**yum-repo.tgz**
## Docker环境
Docker环境与原生CentOS7环境的脚本均一致，只是使用CentOS的Docker镜像作为运行环境，相对来说更加纯净且易于维护
### 镜像构建
将项目下载至已安装好Docker的机器上，并在项目根目录运行：
```
# docker build -t yum-local-repo:7.9.2009 .
```
默认使用CentOS7.9.2009系统镜像，如需替换可指定`CENTOS_VER`参数，例如：
```
# docker build --build-arg CENTOS_VER=centos7.7.1908 -t yum-local-repo:7.7.1908 .
```
### 离线包生成
1. 在宿主机上准备好配置和离线安装包生输出目录，例如:`/root/yum-repo/conf`和`/root/yum-repo/out`
2. 配置目录下准备好yum.list和yum-group.list
3. 执行命令开始构建
   ```
   # docker run -v /root/yum-repo/conf:/root/prepare-local-repo/conf -v /root/yum-repo/out:/root/prepare-local-repo/out --rm yum-local-repo:7.9.2009
   ```
4. 然后在离线安装包生输出目录中即可找到**yum-repo.tgz**

# 离线包使用
得到**yum-repo.tgz**离线包后，将安装包拷贝至目标环境，解压运行其下的create-local-repo脚本，即可完成本地仓储的配置：
* 本地仓储目录位于/root/yum-local-repo
* 创建本地仓储的过程中，会将`/etc/yum.repos.d/`目录下所有CentOS开头的仓储配置全部删除（备份至`/etc/yum.repos.d/bak`目录）  

本地仓储构建完毕之后，即可使用`yum install`命令安装相关工具包
