# CDN

## 目的

- 解决部分资源在防火墙外可能无法访问的问题
- 解决部分 CDN 服务可能会停止提供服务的问题

## 工作原理

通过 TravisCI 提供的[trigger API](https://docs.travis-ci.com/user/triggering-builds/)，在不提交 Pr 的情况下触发 Travis 执行任务，并且在 trigger 中携带参数，实现一定范围内的定制化操作。

具体任务：

1. 从参数中携带需要下载的静态文件的 URL 等信息
2. 下载文件并保存到仓库的指定位置
3. 提交文件到仓库
4. 将该仓库发布为 GitHub page

## 通过 API 触发 trigger

以下 `ajax` 请求基于 `axios`

```js
// 配置请求头部
let xhr = axios.create({
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    'Travis-API-Version': 3,
    Authorization: 'token xxxxxxxxxx' // token
  }
})
xhr({
  method: 'post',
  url: 'https://api.travis-ci.com/repo/wuyax%2Fcdn/requests',
  data: {
    request: {
      branch: 'master',
      config: {
        env: {
          GH_REF: 'github.com/wuyax/cdn.git', // repo addr
          GH_COMMIT: 'vue-select', //'commit message'
          D_URL: 'https://cdnjs.cloudflare.com/ajax/libs/vue-select/2.5.1/vue-select.js', // url
          D_VERSION: '2.5.1' // version
        }
      }
    }
  }
})
  .then(res => {
    console.log(res)
  })
  .catch(err => {
    console.log(err)
  })
```

> 说明： 请求头部的`token`你可以在你的[Travis CI Profile page](https://travis-ci.com/account/preferences)找到，请求地址 `url: 'https://api.travis-ci.com/repo/[username]%2F[reponame]/requests'` url 中的 `username` 替换成你自己的用户名， `reponame` 替换为你需要触发 build 的仓库名。
> 请求的`data`作为Travis的环境变量使用在CI服务中，因此每个字段都是必填的。

## 使用文件

下载文件的同时会根据文件类型创建不同的文件夹，文件夹创建规则如下：**/文件类型/文件名/版本/文件名**  
例如：下载的文件的URL是 `https://cdnjs.cloudflare.com/ajax/libs/vue-select/2.5.1/vue-select.js`,那么生成的文件结构为：`/js/vue-sekect/2.5.1/vue-select.js`，在项目中通过 script 标签引入该仓库中的文件，只需要通过 GitHub page 的方式访问特定文件就可以了。

例如：  
仓库地址： https://github.com/wuyax/cdn  
对应的 GitHub page 地址是： https://wuyax.github.io/cdn/ 那么你可以通过 `https://wuyax.github.io/cdn/js/vue-select/2.5.1/vue-select.js` 的方式来引用文件。

## 创建自己的CDN仓库

要想创建自己的CDN仓库，前期的准备工作是必须的：

- 在GitHub新建一个仓库
- 创建`.travis.yml`并编写必要的运行方式（你可以复制本项目中的，根据自己的使用需求作出适当的调整）
- 在 TravisCI 里开启对该仓库的监听

## TODO

重复提交的文件不触发 TravisCI 的`build`，这个可能需要在前端处理  
文件分类管理，虽说我们的 API 可以完全覆盖默认的`.travis.yml`的配置，最好还是让 API 做关键的事情

1. ~~通过接口传递多种信息，以变量的形式发送~~
  - 文件 url
  - penID
  - version
  - commit msg `OPTIONAL`

2. ~~触发 trigger 以后新建临时文件夹`/home/travis/temp`~~
3. ~~将文件下载到临时文件夹 `temp`~~
4. ~~下载成功解析文件类型和文件版本~~

- ~~根据文件名创建与文件同名文件夹，在文件夹下面创建版本号文件夹~~
  - `cd js` # 如果是 JS 文件切换到 `js` 目录， `css` 切换到 `css` 目录，其它类型切换到 `other`目录
  - `mkdir namexxx`
  - `cd namexxx`
  - `mkdir versionxxxx`
  - `cd versionxxxx`
- ~~复制到当前目录 `cp /home/travis/temp/jquery.min.js ./`~~
- ~~`cd ../..` // 切换到顶层目录~~

5. 下载成功/失败发送请求到指定服务器携带以下参数，

```js
// 下载成功发送的参数
{
  success: true,
  fileName: 'jquery', // 文件名第一个.前面的部分
  fileType: 'js', // 文件后缀
  version: '1.12', // 读取文件 v或者version 后面的字符串
  penID: 'xjnveivdj', // 传递的变量
  url: 'https://wuyax.github.io/cdn/js/jquery/1.12/jquery.min.js' // 拼接的字符串
}
// 失败发送的参数
{
  success: false,
  penID: 'xjnveivdj'
}
```

6. ~~开始 git 流程~~

  - git remote -v
  - git branch -v
  - git config user.name "\${U_NAME}"
  - git config user.email "\${U_EMAIL}"
  - git add -A
  - git commit -m "\${GH_COMMIT}"
  - git push "https://${GH_TOKEN}@${GH_REF}" master

## 缺陷

慢，是致命缺陷，同一时间触发多次 build 会出现任务队列的情况。
