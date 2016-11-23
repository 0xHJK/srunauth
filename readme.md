# srun auth

srun3000上网认证系统登录脚本，支持Linux和macOS

## 参数说明

+ -q 安静模式，不输出中间信息（默认全部输出）
+ -u 用户名
+ -p 密码
+ Commond 命令登录或者登出，login（默认）或 logout

## 使用方式

一般使用方式：

登录：`bash auth.sh -u [用户名] -p [密码]`

注销：`bash auth.sh -u [用户名] -p [密码] logout`


如果将账号密码写入脚本会更简单点：

登录：`bash auth.sh`

注销：`bash auth.sh logout`


如果将脚本重命名为auth放入环境变量（如 `/usr/local/bin` 目录）会更简单点：

登录：`auth`

注销：`auth logout`

如果~~你有很多账号~~，那么可以将账号密码写到文件中，程序会按行读取，直到成功登录，并记录状态信息。

*选择账号优先级为 命令行 > 变量 > 文件，当前者存在的时候，就不会尝试后者*

当然，你也可以修改一下，加入到系统定时任务，实现自动化 : )

## LICENSE

[MIT license](https://github.com/0xHJK/srunauth/blob/master/LICENSE)
