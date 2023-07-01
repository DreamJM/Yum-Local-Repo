ARG CENTOS_VER=centos7.9.2009

FROM centos:${CENTOS_VER}

LABEL MAINTAINER="Draymond"

COPY prepare-local-repo /root/prepare-local-repo

# 配置国内仓储源加速
RUN rm -f /etc/yum.repos.d/*
COPY yum-sources /etc/yum.repos.d

# 安装离线库工具
RUN yum clean all && \
    yum makecache && \
    yum install -y createrepo

# 工作目录下的“conf”目录中为yum缓存配置，包括yum.list和yum-group.list，每行分别为yum install组件和yum groupinstall组件
# 容器运行完毕会在“out”目录下生成caltta-repo.tgz文件，将文件拷贝至需要离线安装的环境，解压并运行其下的create-local-repo.sh脚本，完成本地仓储配置（/root/caltta-local-repo），后续即可使用yum安装缓存的组件
WORKDIR /root/prepare-local-repo

ENTRYPOINT [ "sh", "prepare-local-repo.sh" ]