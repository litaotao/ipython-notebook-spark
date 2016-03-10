
# ipython-notebook-spark

## `build your spark application in ipython`
  
## 1. 致谢   
首先我忠心地感谢Ipython，Spark的开源作者，真心谢谢你们开发这么方便，好用，功能强大的项目，而且还无私地奉献给大众使用。刚刚很轻松地搭建了一个机遇Ipython Notebook的Spark客户端，真的感受到 The power of technology, the power of open source.  
下面是这两个项目的github地址：  

- [Ipython](https://github.com/ipython/ipython)  
- [Spark](https://github.com/apache/spark)  

同时，这篇文章在刚开始的部分，参考了很多 [这篇博客](http://blog.cloudera.com/blog/2014/08/how-to-use-ipython-notebook-with-apache-spark/)的内容，感谢这么多人能无私分享如此高质量的内容。   
但是，这篇文章不是简单记录怎么做，我尽量做到量少质高，所以有些地方会说得比较详细，其中也会提到在解决遇到的问题上的一些方法和思路。

## 2. 原理

Ipython 支持自定义的配置文件，而且配置文件可以极其灵活的定义，具体我们来看如何创建一个配置文件，并且指定一个配置文件启动 ipython。

## 3. 配置Ipython  

### 3.1 ipython 配置名profile介绍
- profile 命令说明    

　　profile是ipython的一个子命令，其中profile又有两个子命令，分别是create和list，顾名思义，create就是创建一个配置文件，list就是列出当前配置文件。如下：  

    root@ubuntu2[13:54:01]:~/Desktop#ipython profile
    No subcommand specified. Must specify one of: ['create', 'list']

    Manage IPython profiles

    Profile directories contain configuration, log and security related files and
    are named using the convention 'profile_<name>'. By default they are located in
    your ipython directory.  You can create profiles with `ipython profile create
    <name>`, or see the profiles you already have with `ipython profile list`

    To get started configuring IPython, simply do:

    $> ipython profile create

    and IPython will create the default profile in <ipython_dir>/profile_default,
    where you can edit ipython_config.py to start configuring IPython.

    Subcommands
    -----------

    Subcommands are launched as `ipython cmd [args]`. For information on using
    subcommand 'cmd', do: `ipython cmd -h`.

    create
        Create an IPython profile by name
    list
        List available IPython profiles

- profile子命令list说明    

　　本想list命令应该很简单的，和linux下的ls差不多嘛，但我自己看了下，其中还是有些细节值得推敲的。其中这项 `Available profiles in /root/.config/ipython:` 是说目前有两个配置文件在那个目录下面，pyspark是我自己创建的了。在参考的[这篇文章](http://blog.cloudera.com/blog/2014/08/how-to-use-ipython-notebook-with-apache-spark/)中，作者说创建的配置文件会放到 ` ~/.ipython/profile_pyspark/` 下，其实这并不是一定的，具体放在哪个目录下面，可以根据profile list的命令来查看。如此看来，我们在这台机器上创建的配置文件应该是放在目录 `/root/.config/ipython` 下面的。

    root@ubuntu2[14:09:12]:~/Desktop#ipython profile list

    Available profiles in IPython:
        pysh
        math
        sympy
        cluster

        The first request for a bundled profile will copy it
        into your IPython directory (/root/.config/ipython),
        where you can customize it.

    Available profiles in /root/.config/ipython:
        default
        pyspark

    To use any of the above profiles, start IPython with:
        ipython --profile=<name>  

- profile子命令create说明    

　　简单介绍下create子命令的用法。

    root@ubuntu2[09:25:57]:~/Desktop#ipython profile help create
    Create an IPython profile by name

    Create an ipython profile directory by its name or profile directory path.
    Profile directories contain configuration, log and security related files and
    are named using the convention 'profile_<name>'. By default they are located in
    your ipython directory. Once created, you will can edit the configuration files
    in the profile directory to configure IPython. Most users will create a profile
    directory by name, `ipython profile create myprofile`, which will put the
    directory in `<ipython_dir>/profile_myprofile`.

### 3.2 创建新的Ipython配置文件    
- 创建配置文件     

　　因为我之前已经配置过一个pyspark的配置文件了，这里我们创建一个测试用的配置文件，pytest。运行一下命令后，会在 `/root/.config/ipython` 下生成一个 pytest的目录。

    root@ubuntu2[14:54:14]:~/Desktop#ipython profile create pytest
    [ProfileCreate] Generating default config file: u'/root/.config/ipython/profile_pytest/ipython_config.py'
    [ProfileCreate] Generating default config file: u'/root/.config/ipython/profile_pytest/ipython_notebook_config.py'

    root@ubuntu2[15:00:57]:~/Desktop#ls ~/.config/ipython/profile_pytest/
    ipython_config.py  ipython_notebook_config.py  log  pid  security  startup

### 3.3 编辑配置文件
- 编辑ipython_notebook_config.py   

需要更改的只有下面三项：

- `c.NotebookApp.ip`: 启动服务的地址，设置成 '*' 可以从同一网段的其他机器访问到；
- `c.NotebookApp.open_browser`: 设置成 'False'，表示启动 ipython notebook 的时候不会自动打开浏览器；
- `c.NotebookApp.password`: 设置 ipython notebook 的登陆密码，怎么设置看下面；

```
    c.NotebookApp.ip = '*'
    c.NotebookApp.open_browser = False    
    c.NotebookApp.password = "sha1:c6b748a8e1e2:4688f91ccfb9a8e0afd041ec77cdda99d0e1fb8f"
```

- 设置访问密码   
　　如果你的notebook server是需要访问控制的，简单的话可以设置一个访问密码。

    + 生成密码
    ```
    In [4]: from IPython.lib import passwd

    In [5]: passwd()
    Enter password:
    Verify password:
    Out[5]: 'sha1:e819609871c8:1039dbc5a1392fc230d371d1ce19511490978685'

    In [6]:
    ```
    + 编辑配置文件，设置密码：`c.NotebookApp.password = "sha1:c6b748a8e1e2:4688f91ccfb9a8e0afd041ec77cdda99d0e1fb8f"`

- 设置启动文件  
　　这一步算是比较重要的了，也是我在配置这个notebook server中遇到的比较难解的问题。这里我们首先需要创建一个启动文件，并在启动文件里设置一些spark的启动参数。如下：

```
root@ubuntu2[09:52:14]:~/Desktop#touch ~/.config/ipython/profile_pytest/startup/00-pytest-setup.py
root@ubuntu2[10:08:44]:~/Desktop#vi ~/.config/ipython/profile_pytest/startup/00-pytest-setup.py   

import os
import sys

spark_home = os.environ.get('SPARK_HOME', None)
if not spark_home:
    raise ValueError('SPARK_HOME environment variable is not set')
sys.path.insert(0, os.path.join(spark_home, 'python'))
sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.8.2.1-src.zip'))
# execfile(os.path.join(spark_home, 'python/pyspark/shell.py'))
```

　　上面的启动配置文件也还简单，即拿到spark_home路径，并在系统环境变量path里加上两个路径，然后再执行一个shell.py文件。不过，在保存之前还是先确认下配置文件写对了，比如说你的SPARK_HOME配置对了，并且下面有python这个文件夹，并且python/lib下有py4j-0.8.1这个文件。我在检查的时候就发现我的包版本是py4j-0.8.2.1的，所以还是要改得和自己的包一致才行。   
　　这里得到一个经验，在这种手把手，step by step的教程中，一定要注意版本控制，毕竟各人的机器，操作系统，软件版本等都不可能完全一致，也许在别人机器上能成功，在自己的机器上不成功也是很正常的事情，毕竟细节决定成败啊！所以在我这里，这句我是这样写的： `sys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.8.2.1-src.zip'))`    
　　注意，上面的最后一行 `execfile(os.path.join(spark_home, 'python/pyspark/shell.py'))` 被注释掉了，表示在新建或打开一个notebook时并不去执行shell.py这个文件，这个文件是创建SparkContext的，即如果执行改行语句，那在启动notebook时就会初始化一个sc，但这个sc的配置都是写死了的，在spark web UI监控里的appName也是一样的，很不方便。而且考虑到并不是打开一个notebook就要用到spark的资源，所以最好是要用户自己定义sc了。   
　　python/pyspark/shell.py的核心代码：   
```
sc = SparkContext(appName="PySparkShell", pyFiles=add_files)
atexit.register(lambda: sc.stop())
```


## 4. Ok，here we go　　
　　到这里差不多大功告成了，可以启动notebook server了。不过在启动之前，需要配置两个环境变量参数，同样，这两个环境变量参数在也是根据个人配置而定的。  

```
# for the CDH-installed Spark
export SPARK_HOME='/usr/local/spark-1.2.0-bin-cdh4/'

# this is where you specify all the options you wou
ld normally add after bin/pyspark
  export PYSPARK_SUBMIT_ARGS='--master spark://10.21.208.21:7077 --deploy-mode client'
```

　　ok，万事具备，只欠东风了。让我们来尝尝鲜吧：

```
root@ubuntu2[10:40:50]:~/Desktop#ipython notebook --profile=pyspark
2015-02-01 10:40:54.850 [NotebookApp] Using existing profile dir: u'/root/.config/ipython/profile_pyspark'
2015-02-01 10:40:54.858 [NotebookApp] Using MathJax from CDN: http://cdn.mathjax.org/mathjax/latest/MathJax.js
2015-02-01 10:40:54.868 [NotebookApp] CRITICAL | WARNING: The notebook server is listening on all IP addresses and not using encryption. This is not recommended.
2015-02-01 10:40:54.869 [NotebookApp] Serving notebooks from local directory: /root/Desktop
2015-02-01 10:40:54.869 [NotebookApp] The IPython Notebook is running at: http://[all ip addresses on your system]:8880/
2015-02-01 10:40:54.869 [NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

　　在浏览器输入driver:8880即可访问notebook server了，首先会提示输入密码，密码正确后就可以使用了。
![notebook-spark-1](http://litaotao.github.io/images/notebook-spark-1.jpg)
![notebook-spark-2](http://litaotao.github.io/images/notebook-spark-2.jpg)


## 5. 总结
　　下面是简单的步骤总结：

- 建立环境变量配置文件：ipython_notebook_spark.bashrc    

```
export SPARK_HOME="/usr/local/spark-1.2.0-bin-cdh4/"
export PYSPARK_SUBMIT_ARGS="--master spark://10.21.208.21:7077 --deploy-mode client"
```
- 配置Ipython notebook server
    + ipython profile create pyspark
    + 编辑ipython_notebook_config.py   
    + [可选]配置ipython notebook登录密码
    + 设置启动文件
- 设置启动脚本    
