# 修改相关配置文件, 开启docker远程api
将/usr/lib/systemd/system/docker.service配置文件中
ExecStart=/usr/bin/dockerd
修改成：
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock

注： mac OS由于没有docker.service文件，所以需要执行命令 brew install socat，用来辅助docker开启远程api模块。
安装完成之后首先需要在~/.bash_profile中提示信息插入到文件中，然后执行source ~/.bash_profile
export LDFLAGS="-L/usr/local/opt/readline/lib"
export CPPFLAGS="-I/usr/local/opt/readline/include"

然后执行
socat -d TCP-LISTEN:2375,range=127.0.0.1/32,reuseaddr,fork UNIX:/var/run/docker.sock

并保持Terminal不关闭。查看是否开启docker remote API是否成功，可以在浏览器输入http://ip:2375/version，注意要开启服务器端口。

# 项目适应性改造
一共有三种方式部署docker，前两种为maven配合dockerfile，后一种则是直接通过dockerfile构建。
### maven中直接配置插件，将dockerfile中的信息填入插件，不需要dockerfile
<plugin>
　　　<groupId>com.spotify</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>1.0.0</version>
    <configuration>
     　　<imageName>irh/${project.artifactId}</imageName>
     　　<dockerHost>http://127.0.0.1:2375 </dockerHost>  #修改成自己docker所在服务器ip
     　　<baseImage>java:8</baseImage>
      　 <entryPoint>["java", "-jar","/irh-registry-1.0-SNAPSHOT-execute.jar"]</entryPoint> 
         　　<resources>
            　　<resource>
            　　　　<targetPath>/</targetPath>
                　　<directory>${project.build.directory}</directory>
                　　<include>${project.build.finalName}.jar</include> 
　　　　　　　　　</resource> 
　　　　　　　</resources> 
　　　</configuration>
</plugin>

### maven配合dockerfile文件
##### pom.xml文件
<plugin>
<groupId>com.spotify</groupId>
<artifactId>docker-maven-plugin</artifactId>
<version>1.0.0</version>
<configuration>
<imageName>irh/${project.artifactId}</imageName>
<dockerHost>http://127.0.0.1:2375</dockerHost>
<dockerDirectory>${project.basedir}/src/main/docker</dockerDirectory>   #dockerfile在项目中的位置
<resources>
<resource>
<targetPath>/</targetPath>
<directory>${project.build.directory}</directory>
<include>irh-registry-1.0-SNAPSHOT-execute.jar</include>
</resource>
</resources>
</configuration>
</plugin>

##### Dockerfile文件
# Docker image for springboot file run
# 基础镜像使用java
FROM java:8
# VOLUME 指定了临时文件目录为/tmp。
# 其效果是在主机 /var/lib/docker 目录下创建了一个临时文件，并链接到容器的/tmp
VOLUME /tmp
# 将jar包添加到容器中并更名为app.jar
ADD irh-registry-1.0-SNAPSHOT-execute.jar app.jar
# 运行jar包
RUN bash -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar","--spring.prifiles.active=$ENVIR"]

# 部署
在项目根目录执行 mvn package docker:build
查看docker中的镜像：执行 docker run -d -p 本机端口:项目端口 --name=运行后容器名称 镜像id即可创建容器并启动。

# 动态传递参数
构建的Spring boot项目中，可能存在多个环境，本地环境和线上环境，这个时候可以通过在通过镜像构建容器时传递对应的参数就可以实现在不同环境下部署
主要就是新增了一个名为「ENVIR」的参数，并在「ENTRYPOINT」后面赋值给一个「--spring.prifiles.active」。删除之前存在的使用maven构建；先删除容器，再删除镜像然后执行命令

然后执行命令
docker run -d -p --name 自定义名称  -e Dockerfile中定义的变量名="XXX" 镜像id

有多个变量则重复使用 「 -e 变量名=赋值 」。

