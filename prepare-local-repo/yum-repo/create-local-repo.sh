#!/bin/sh

repo_base=/root

tar -zxvf createrepo.tgz
rpm -ivh createrepo/*.rpm

[[ -d $repo_base/yum-local-repo ]] && rm -rf $repo_base/yum-local-repo
tar -zxf yum-local-repo.tgz -C $repo_base

[[ -d /etc/yum.repos.d/bak ]] || mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/bak

cat > /etc/yum.repos.d/yum-local.repo << EOF
[yum-local]
name=Local Yum Repository
baseurl=file://${repo_base}/yum-local-repo/
gpgcheck=0
enabled=1
EOF

createrepo $repo_base/yum-local-repo
cp comps.xml $repo_base/yum-local-repo
createrepo -g comps.xml $repo_base/yum-local-repo
yum clean all
yum makecache
