
系统准备
centos 7.2



软件准备
1.下载 hadoop-2.8.5
2.yum install -y nfs-utils (nfs, rpcbind)
3.java 1.8




机器准备
2.三台虚拟机
hadoop-master, 192.168.200.131, namenode角色
hadoop-slave1, 192.168.200.135, datanode角色
hadoop-slave2, 192.168.200.136, datanode角色



3.机器账户准备(三台机器)
root(挂载nfs)
hadoop (启动namenode, datanode)
创建hadoop 组
groupadd hadoop
创建hadoop账户
useradd -m hadoop -g hadoop




4.master机器(hadoop账号)免密登录 hadoop-slave1(hadoop账号), hadoop-slave2(hadoop账号)
a. master机器上 ,ssh keygen -t rsa, 一路enter下去
b. 把公钥拷导slave上, 
ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-slave1
ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-slave2
c.测试 ssh hadoop-slave1是否可以登录






5.下载hadoop压缩包并解压(root账号), 到/opt/hadoop-2.8.5
a.修改拥有者, chown -R hadoop:hadoop /opt/hadoop-2.8.5
b.对拥有者修改 rwx 权限, chmod -R u+rwx /opt/hadoop-2.8.5





6.修改配置文件, core-site.xml(namenode, nfs), hdfs-site.xml(hdfs)
a.切换hadoop账号, su hadoop
b.cd etc/hadoop
c.mkdir /opt/hadoop-2.8.5/data/tmp /opt/hadoop-2.8.5/data/datanode /opt/hadoop-2.8.5/data/namenode (都是hadoop账号)
d.mkdir /opt/hdfsnfs, /tmp/.hdfs-nfs (nfs挂载使用 ,root账号， 再把所有者转到hadoop账号)

修改core-site.xml

<configuration>
<property>
<name>hadoop.tmp.dir</name>
<value>/opt/hadoop-2.8.5/data/tmp</value>
</property>
<property>
<name>fs.defaultFS</name>
<value>hdfs://hadoop-master:9000</value>
<description>namenode config</description>
</property>

<property>
<name>io.file.buffer.size</name>
<value>4096</value>
</property>
<property>
<name>hadoop.proxyuser.nfsserver.groups</name>
<value>*</value>
<description>allow all groups</description>
</property>
<property>
<name>hadoop.proxyuser.nfsserver.hosts</name>
<value>*</value>
<description>allow hosts</description>
</property>
<property>
<name>hadoop.proxyuser.root.groups</name>
<value>*</value>
</property>
<property>
<name>hadoop.proxyuser.root.hosts</name>
<value>*</value>
</property>

</configuration>


修改hdfs-site.xml

<configuration>
<property>
<name>dfs.namenode.name.dir</name>
<value>/opt/hadoop-2.8.5/data/namenode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>/opt/hadoop-2.8.5/data/datanode</value>
</property>
<property>
<name>dfs.replication</name>
<value>2</value>
</property>
<property>
<name>dfs.http.address</name>
<value>hadoop-master:50070</value>
</property>
<property>
<name>dfs.namenode.secondary.http-address</name>
<value>hadoop-slave2:50090</value>
</property>
<property>
<name>dfs.webhdfs.enabled</name>
<value>true</value>
</property>
<property>
<name>nfs.dump.dir</name>
<value>/tmp/.hdfs-nfs</value>
</property>
<property>
<name>nfs.exports.allowed.hosts</name>
<value>* rw</value>
</property>
<property>
<name>dfs.nfs.rtmax</name>
<value>1048576</value>
<description>This is the maximum size in bytes of a READ request
supported by the NFS gateway. If you change this, make sure you
also update the nfs mount's rsize(add rsize= # of bytes to the
mount directive).
</description>
</property>
<property>
<name>dfs.nfs.wtmax</name>
<value>65536</value>
<description>This is the maximum size in bytes of a WRITE request
supported by the NFS gateway. If you change this, make sure you
also update the nfs mount's wsize(add wsize= # of bytes to the
mount directive).
</description>
</property>
</configuration>


hadoop-env.sh 修改 JAVA_HOME



7.第一次启动需要格式化namenode

/opt/hadoop-2.8.5/bin/hadoop namenode -format



8.三台机器关闭 filewire 和 selinux



9.关闭系统nfs, rpcbind服务
service nfs stop
service rpcbind stop



10.用root账号登录master机器, 准备挂载nfs3 (启动有顺序)
/opt/hadoop-2.8.5/sbin/hadoop-daemon.sh --script /opt/hadoop-2.8.5/bin/hdfs start portmap
/opt/hadoop-2.8.5/sbin/hadoop-daemon.sh --script /opt/hadoop-2.8.5/bin/hdfs start nfs3


11.正式启动hadoop, namenode和datanode(hadoop账号)

./opt/hadoop-2.8.5/sbin/start-dfs.sh
（查看状态）http://192.168.200.131:50070/dfshealth.html#tab-overview

挂载硬盘(先要启动hadoop集群才能挂载,只挂载master,root账号):
mount -t nfs -o vers=3,proto=tcp,nolock,noacl,sync hadoop-master:/ /opt/hdfsnfs/


12.测试挂载结果

进入/opt/hdfsnfs/, 用文件命令，不支持随机写入


12.启动nginx 测试


http {
server {
listen 18090;
location ~ ^/file/ {
root d:\var\lib\jenkins\workspace\qa-seasun-management\static; 
gzip on;
gzip_min_length 1000;
gzip_comp_level 3;
gzip_types text/plain application/xml application/javascript application/x-javascript text/css text/javascript image/jpeg image/gif image/png;
}
}

}



13.测试能不能访问到文件