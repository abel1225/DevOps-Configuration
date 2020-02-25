java -server
 -XX:+HeapDumpOnOutOfMemoryError
 -XX:HeapDumpPath=/data/dump/heap/
 -Djava.io.tmpdir=/data/tmp/
 -Dserver.port=8103
 -Dcom.sun.management.jmxremote
 -Dcom.sun.management.jmxremote.port=5103
 -Dcom.sun.management.jmxremote.rmi.port=6103
 -Dcom.sun.management.jmxremote.authenticate=false
 -Dcom.sun.management.jmxremote.ssl=false
 -Dcom.sun.management.jmxremote.access.file=/usr/local/java/jdk1.8.0_131/jre/lib/management/jmxremote.access
 -Xmx2G -Xms2G -XX:+DisableExplicitGC -verbose:gc
 -Xloggc:/data/log/gc.%t.log
 -XX:+PrintHeapAtGC
 -XX:+PrintTenuringDistribution
 -XX:+PrintGCApplicationStoppedTime
 -XX:+PrintGCTaskTimeStamps
 -XX:+PrintGCDetails
 -XX:+PrintGCDateStamps
 -Dserver.connection-timeout=60000
 -Dserver.tomcat.accept-count=1000
 -Dserver.tomcat.max-threads=300
 -Dserver.tomcat.min-spare-threads=65
 -Dserver.tomcat.accesslog.enabled=false
 -Dserver.tomcat.accesslog.directory=/data/logs/
 -Dserver.tomcat.accesslog.prefix=access_log
 -Dserver.tomcat.accesslog.pattern=combine
 -Dserver.tomcat.accesslog.suffix=.log
 -Dserver.tomcat.accesslog.rotate=true
 -Dserver.tomcat.accesslog.rename-on-rotate=true
 -Dserver.tomcat.accesslog.request-attributes-enabled=true
 -Dserver.tomcat.accesslog.buffered=true
 -XX:NewRatio=4
 -XX:SurvivorRatio=30
 -XX:TargetSurvivorRatio=90
 -XX:MaxTenuringThreshold=8
 -XX:+UseCMSInitiatingOccupancyOnly
 -XX:CMSInitiatingOccupancyFraction=70
 -XX:ParallelGCThreads=24
 -XX:ConcGCThreads=24
 -XX:-UseGCOverheadLimit
 -XX:+UseParNewGC                                            --设置年轻代为并行收集。可以和CMS收集同时使用。JDK5.0以上，JVM会根据系统配置自行配置，所以无需再配置此值。
 -XX:+UseConcMarkSweepGC                                     --设置年老代为并发收集
 -XX:CMSFullGCsBeforeCompaction=1
 -XX:+CMSParallelRemarkEnabled
 -XX:+CMSScavengeBeforeRemark                                --开启或关闭在CMS重新标记阶段之前的清除（YGC）尝试,CMS并发标记阶段与用户线程并发进行，此阶段会产生已经被标记了的对象又发生变化的情况，若打开此开关，可在一定程度上降低CMS重新标记阶段对上述“又发生变化”对象的扫描时间，当然，“清除尝试”也会消耗一些时间，开启此开关并不会保证在标记阶段前一定会进行清除操作
 -XX:+ParallelRefProcEnabled
 -XX:+CMSPermGenSweepingEnabled                              --允许对持久代进行清理, 这个参数表示是否会清理持久代。默认是不清理的，因此我们需要明确设置这个参数来调试持久代内存溢出问题。这个参数在Java6中被移除了，因此你需要使用 -XX:+CMSClassUnloadingEnabled 如果你是使用Java6或者后面更高的版本。那么解决持久代内存大小问题的参数看起来会是下面这样子：-XX:MaxPermSize=128m -XX:+UseConcMarkSweepGC XX:+CMSClassUnloadingEnabled
 -XX:+CMSClassUnloadingEnabled                               --允许对类进行卸载,如果你启用了CMSClassUnloadingEnabled ，垃圾回收会清理持久代，移除不再使用的classes。这个参数只有在 UseConcMarkSweepGC 也启用的情况下才有用
 -XX:+UseCMSCompactAtFullCollection                          --打开对年老代的压缩。可能会影响性能，但是可以消除碎片
 -XX:CMSMaxAbortablePrecleanTime=6000
 -XX:CompileThreshold=10
 -XX:MaxInlineSize=1024
 -Dsun.net.client.defaultConnectTimeout=60000
 -Dsun.net.client.defaultReadTimeout=60000
 -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.ttl=300
 -Djsse.enableCBCProtection=false
 -Djava.security.egd=file:/dev/./urandom
 -Dfile.encoding=UTF-8
 -Dlog.path=/data/logs/
 -Dspring.profiles.active=online
 -jar  /data/deploy/app.jar


 调优总结

 　　　　-XX:+UseCMSCompactAtFullCollection：使用并发收集器时，开启对年老代的压缩

 　　　　-XX:CMSFullGCsBeforeCompaction=0：上面配置开启的情况下，这里设置多少次Full GC后，对年老代进行压缩

 　　　　-XX:MaxHeapFreeRatio=30

 　　　　响应时间优先的应用：年老代使用并发收集器，所以其大小需要小心设置，一般要考虑并发会话率和会话持续时间等一些参数。如果堆设置小了，可以会造成内存碎片、高回收频率以及应用暂停而使用传统的标记清除方式；如果堆大了，则需要较长的收集时

 　　间。最优化的方案，一般需要参考以下数据获得：减少年轻代和年老代花费的时间，一般会提高应用的效率

 　　　　吞吐量优先的应用：一般吞吐量优先的应用都有一个很大的年轻代和一个较小的年老代。原因是，这样可以尽可能回收掉大部分短期对象，减少中期的对象，而年老代尽存放长期存活对象。

 　　　　并发垃圾收集信息

 　　　　持久代并发收集次数

 　　　　传统GC信息

 　　　　花在年轻代和年老代回收上的时间比例

 　　　　响应时间优先的应用：尽可能设大，直到接近系统的最低响应时间限制（根据实际情况选择）。在此种情况下，年轻代收集发生的频率也是最小的。同时，减少到达年老代的对象。

 　　　　吞吐量优先的应用：尽可能的设置大，可能到达Gbit的程度。因为对响应时间没有要求，垃圾收集可以并行进行，一般适合8CPU以上的应用。

 　　　　年轻代大小选择

 　　　　年老代大小选择

 　　　　较小堆引起的碎片问题

 　　　　　　因为年老代的并发收集器使用标记、清除算法，所以不会对堆进行压缩。当收集器回收时，他会把相邻的空间进行合并，这样可以分配给较大的对象。但是，当堆空间较小时，运行一段时间以后，就会出现“碎片”，如果并发收集器找不到足够的空间，那么并发收集器将会停止，然后使用传统的标记、清除方式进行回收。如果出现“碎片”，可能需要进行如下配置：

 　　　　-XX:+UseCMSCompactAtFullCollection：使用并发收集器时，开启对年老代的压缩

 　　　　-XX:CMSFullGCsBeforeCompaction=0：上面配置开启的情况下，这里设置多少次Full GC后，对年老代进行压缩

 　　　　-XX:MaxHeapFreeRatio=30


一、取得GC信息
-verbose:gc -XX:+printGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps  -Xloggc:c:\gc.log

二、堆分配参数总结
-Xms：设置Java应用程序启动的初始堆大小，一般设置成和-Xmx一样可以减少minor GC次数
-Xmx：设置java应用程序能获得的最大堆大小，设置太小会增加GC次数，太大会增加GC时间
-Xss：设置线程栈的大小，与支持的线程数相关 这个就要依据你的程序，看一个线程 大约需要占用多少内存，可能会有多少线程同时运行等。一般不易设置超过1M
-XX:MinHeapFreeRatio：设置堆空间的最小空闲比例。当堆空间的空闲内存小于这个数值时，JVM变回扩展空间
-XX:MaxHeapFreeRatio：置堆空间的最大空闲比例。当堆空间的空闲内存大于这个数值时，JVM变回扩展空间
-Xmn：Sun官方推荐配置为整个堆的3/8
-XX:NewSize：设置新生代的大小
-XX:NewRatio：设置老年代和新生代的比例 等于老年代大小/新生代大小
-XX:SurviorRatio：设置新生代中eden区与survivior区的比例
-XX:PermSize：设置永久区的初始值 默认是物理内存的1/64
-XX:MaxPermSize：设置最大的永久区大小 默认是物理内存的1/4
-XX:TargetSurvivorRatio ：设置survivior区的可使用率，当survivior区的空间使用率达到这个数值时，会将对象送入老年代
-XX:+DisableExplicitGC:禁用显式GC
一般Xms、Xmx设置相同，PermSize、MaxPermSize设置相同，这样可以避免伸缩堆大小带来的性能损耗
三 、与串行回收器相关的参数
-XX：+UseSerialGC 在新生代和老年代使用串行收集器
-XX：PretenureSizeThreshold 设置大对象直接进入老年代的阀值，当对象超过这个值时，将直接在老年代分配，这个参数只对串行收集器有效
-XX：MaxTenuringThreshold 设置对象进入老年代的年龄的最大值，每一次minorGC后 对象的年龄就+1，任何大于这个年龄的对象，一定会进入老年代，默认是15
四、与并行GC相关的参数
-XX:+UseParNewGC ：在新生代使用并行收集器
-XX:+UseParallelOldGC：老年代使用并行回收收集器
-XX:ParallelGCThreads：设置用于垃圾回收的线程数，通常情况下可以和CPU数量相等。但在CPU数量比较多的情况下，设置相对较小
-XX:MaxGCPauserMillis 设置最大垃圾收集停顿时间。他的值是一个大于0的整数，在收集器工作时，会调整JAVA堆大小或则其他一些参数，尽可能地把停顿时间控制在MaxGCPauseMillls内
-XX:GCTimeRatio：设置吞吐量的大小，它的值是一个0到100的整数，系统花费不超过1/(1+n)的时间用于垃圾收集，默认99
-XX:+UseAdaptiveSizePolicy 自适应GC策略
五 、与CMS回收器相关的参数

1、启用CMS：-XX:+UseConcMarkSweepGC。

2。CMS默认启动的回收线程数目是  (ParallelGCThreads + 3)/4) ，如果你需要明确设定，可以通过-XX:ParallelCMSThreads=20来设定,其中ParallelGCThreads是年轻代的并行收集线程数

3、CMS是不会整理堆碎片的，因此为了防止堆碎片引起full gc，通过会开启CMS阶段进行合并碎片选项：-XX:+UseCMSCompactAtFullCollection，开启这个选项一定程度上会影响性能，

4.为了减少第二次暂停的时间，开启并行remark: -XX:+CMSParallelRemarkEnabled。如果remark还是过长的话，可以开启-XX:+CMSScavengeBeforeRemark选项，强制remark之前开始一次minor gc，减少remark的暂停时间，但是在remark之后也将立即开始又一次minor gc。

5.为了避免Perm区满引起的full gc，建议开启CMS回收Perm区选项：
-XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled

6.默认CMS是在tenured generation沾满68%的时候开始进行CMS收集，如果你的年老代增长不是那么快，并且希望降低CMS次数的话，可以适当调高此值：
-XX:CMSInitiatingOccupancyFraction=80
这里修改成80%沾满的时候才开始CMS回收。

7.年轻代的并行收集线程数默认是(cpu <= 8) ? cpu : 3 + ((cpu * 5) / 8)，如果你希望降低这个线程数，可以通过-XX:ParallelGCThreads= N 来调整
