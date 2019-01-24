# CDN

## 目的

- 解决部分资源在防火墙外可能无法访问的问题
- 解决部分 CDN 服务可能会停止提供服务的问题

## 工作原理

通过 TravisCI 提供的[trigger API](https://docs.travis-ci.com/user/triggering-builds/)，在不提交 Pr 的情况下触发 Travis 执行任务，并且在 trigger 中携带参数，实现一定范围内的定制化操作。
具体任务：  
1. 从参数中携带需要下载的静态文件的URL
2. 下载文件
3. 提交文件到仓库的制定位置
4. 将该仓库发布为GitHub page

## 通过API触发trigger

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
      message: 'this commit is from TravisCI trigger API',
      branch: 'master',
      config: {
        script: `curl -O ${this.url}`
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

> 说明： 请求头部的`token`你可以在你的[Travis CI Profile page](https://travis-ci.com/account/preferences)找到，`url: 'https://api.travis-ci.com/repo/[username]%2F[reponame]/requests'` url中的username替换成你自己的用户名，reponame替换为你需要触发build的仓库名。

## 使用文件
在项目中通过script标签引入该仓库中的文件，只需要通过GitHub page的方式访问特定文件就可以了。
例如：  
仓库地址： https://github.com/wuyax/cdn  
对应的GitHub page地址是： https://wuyax.github.io/cdn/ 那么你可以通过 https://wuyax.github.io/cdn/js/xxxx.js的方式来引用文件。

## 注意事项
要想让这些操做有效，前期的准备工作是必须的：
- 新建一个仓库
- 创建`.travis.yml`并编写必要的运行方式
- 在TravisCI里开启对该仓库的监听

## TODO
1. 重复提交的文件不触发TravisCI的`build`，这个可能需要在前端处理
2. 文件分类管理，虽说我们的API可以完全覆盖默认的`.travis.yml`的配置，最好还是让API做关键的事情

## 缺陷
慢，是致命缺陷，同一时间触发多次build会出现任务队列的情况。