1. 为什么需要innodb buffer pool？

在MySQL5.5之前，广泛使用的和默认的存储引擎是MyISAM。MyISAM使用操作系统缓存来缓存数据。InnoDB需要innodb buffer pool中处理缓存。所以非常需要有足够的InnoDB buffer pool空间。

2. MySQL InnoDB buffer pool 里包含什么？

数据缓存
InnoDB数据页面

索引缓存
索引数据

缓冲数据
脏页（在内存中修改尚未刷新(写入)到磁盘的数据）

内部结构
如自适应哈希索引，行锁等。

3. 如何设置innodb_buffer_pool_size?

innodb_buffer_pool_size默认大小为128M。最大值取决于CPU的架构。在32-bit平台上，最大值为2**32 -1,在64-bit平台上最大值为2**64-1。当缓冲池大小大于1G时，将innodb_buffer_pool_instances设置大于1的值可以提高服务器的可扩展性。

大的缓冲池可以减小多次磁盘I/O访问相同的表数据。在专用数据库服务器上，可以将缓冲池大小设置为服务器物理内存的80%。

3.1 配置缓冲池大小时，请注意以下潜在问题

物理内存争用可能导致操作系统频繁的paging

InnoDB为缓冲区和control structures保留了额外的内存，因此总分配空间比指定的缓冲池大小大约大10％。

缓冲池的地址空间必须是连续的，这在带有在特定地址加载的DLL的Windows系统上可能是一个问题。

初始化缓冲池的时间大致与其大小成比例。在具有大缓冲池的实例上，初始化时间可能很长。要减少初始化时间，可以在服务器关闭时保存缓冲池状态，并在服务器启动时将其还原。

innodb_buffer_pool_dump_pct：指定每个缓冲池最近使用的页面读取和转储的百分比。 范围是1到100。默认值是25。例如，如果有4个缓冲池，每个缓冲池有100个page，并且innodb_buffer_pool_dump_pct设置为25，则dump每个缓冲池中最近使用的25个page。
innodb_buffer_pool_dump_at_shutdown：默认启用。指定在MySQL服务器关闭时是否记录在InnoDB缓冲池中缓存的页面，以便在下次重新启动时缩短预热过程。
innodb_buffer_pool_load_at_startup：默认启用。指定在MySQL服务器启动时，InnoDB缓冲池通过加载之前保存的相同页面自动预热。 通常与innodb_buffer_pool_dump_at_shutdown结合使用。
增大或减小缓冲池大小时，将以chunk的形式执行操作。chunk大小由innodb_buffer_pool_chunk_size配置选项定义，默认值为128 MB。

缓冲池大小必须始终等于或者是innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances的倍数。
如果将缓冲池大小更改为不等于或等于innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances的倍数的值，
则缓冲池大小将自动调整为等于或者是innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances的倍数的值。

innodb_buffer_pool_size可以动态设置，允许在不重新启动服务器的情况下调整缓冲池的大小。 可以通过状态变量Innodb_buffer_pool_resize_status报告在线调整缓冲池大小操作的状态。

 执行语句

 show status like 'Innodb_buffer_pool_resize%';
3.2 配置示例

在以下示例中，innodb_buffer_pool_size设置为1G，innodb_buffer_pool_instances设置为1。innodb_buffer_pool_chunk_size默认值为128M。

1G是有效的innodb_buffer_pool_size值，因为1G是innodb_buffer_pool_instances = 1 * innodb_buffer_pool_chunk_size = 128M的倍数

 执行语句

show variables like 'innodb_buffer_pool%';
innodb_buffer_pool_size=(1024*1024)/innodb_buffer_pool_chunk_size/innodb_buffer_pool_instances


3.3 在线调整InnoDB缓冲池大小

         SET GLOBAL innodb_buffer_pool_size = 3221225472

3.4 监控在线缓冲池调整进度

        SHOW STATUS WHERE Variable_name='InnoDB_buffer_pool_resize_status';

4. 配置的innodb_buffer_pool_size是否合适？

当前配置的innodb_buffer_pool_size是否合适，可以通过分析InnoDB缓冲池的性能来验证。

可以使用以下公式计算InnoDB缓冲池性能：

Performance = innodb_buffer_pool_reads / innodb_buffer_pool_read_requests * 100

innodb_buffer_pool_reads：表示InnoDB缓冲池无法满足的请求数。需要从磁盘中读取。

innodb_buffer_pool_read_requests：表示从内存中读取逻辑的请求数。

例如，在我的服务器上，检查当前InnoDB缓冲池的性能

show status like 'innodb_buffer_pool_read%';


Innodb_buffer_pool_reads/Innodb_buffer_pool_read_requests*100 即 1700/940668*100=0.18072263540378
意味着InnoDB可以满足缓冲池本身的大部分请求。从磁盘完成读取的百分比非常小。因此无需增加innodb_buffer_pool_size值。

InnoDB buffer pool 命中率：

InnoDB buffer pool 命中率 = innodb_buffer_pool_read_requests / (innodb_buffer_pool_read_requests + innodb_buffer_pool_reads ) * 100

此值低于99%，则可以考虑增加innodb_buffer_pool_size。

5. InnoDB缓冲池状态变量有哪些？

可以运行以下命令进行查看：

show global status like '%innodb_buffer_pool_pages%';


说明：

Innodb_buffer_pool_pages_data
InnoDB缓冲池中包含数据的页数。 该数字包括脏页面和干净页面。 使用压缩表时，报告的Innodb_buffer_pool_pages_data值可能大于Innodb_buffer_pool_pages_total。
Innodb_buffer_pool_pages_dirty
显示在内存中修改但尚未写入数据文件的InnoDB缓冲池数据页的数量（脏页刷新）。

Innodb_buffer_pool_pages_flushed
表示从InnoDB缓冲池中刷新脏页的请求数。

Innodb_buffer_pool_pages_free
显示InnoDB缓冲池中的空闲页面

Innodb_buffer_pool_pages_misc
InnoDB缓冲池中的页面数量很多，因为它们已被分配用于管理开销，例如行锁或自适应哈希索引。此值也可以计算为Innodb_buffer_pool_pages_total - Innodb_buffer_pool_pages_free - Innodb_buffer_pool_pages_data。

Innodb_buffer_pool_pages_total
InnoDB缓冲池的总大小，以page为单位。

innodb_buffer_pool_reads
表示InnoDB缓冲池无法满足的请求数。需要从磁盘中读取。

innodb_buffer_pool_read_requests
它表示从内存中逻辑读取的请求数。

innodb_buffer_pool_wait_free
通常，对InnoDB缓冲池的写入发生在后台。 当InnoDB需要读取或创建页面并且没有可用的干净页面时，InnoDB首先刷新一些脏页并等待该操作完成。 此计数器计算这些等待的实例。 如果已正确设置innodb_buffer_pool_size，则此值应该很小。如果大于0，则表示InnoDb缓冲池太小。

innodb_buffer_pool_write_request
表示对缓冲池执行的写入次数。
