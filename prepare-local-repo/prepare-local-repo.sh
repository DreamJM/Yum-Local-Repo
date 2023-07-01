#!/bin/sh

repo_dir=/root/yum-local-repo
tools_list=./conf/yum.list
group_list=./conf/yum-group.list

[ -d "$repo_dir" ] && rm -rf "$repo_dir"
mkdir $repo_dir

while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    continue
  fi
  echo "downloading ${line}"
  yum install --downloadonly --downloaddir=${repo_dir} ${line}
done < "$tools_list"

while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    continue
  fi
  echo "downloading group ${line}"
  yum groupinstall --downloadonly --downloaddir=${repo_dir} "${line}"
done < "$group_list"

echo "preparing repository..."
createrepo -pdo ${repo_dir} ${repo_dir} > /dev/null
createrepo --update ${repo_dir} > /dev/null
echo "repository index complete"

[ -f "yum-repo/yum-local-repo.tgz" ] && rm -f yum-repo/yum-local-repo.tgz
tar czf yum-repo/yum-local-repo.tgz -C $(dirname ${repo_dir}) $(basename ${repo_dir})
echo "repository package complete"

[ -f "out/yum-repo.tgz" ] && rm -f out/yum-repo.tgz
tar czf out/yum-repo.tgz yum-repo
echo "installation package complete"
