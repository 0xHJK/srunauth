# srun auth

srun3000上网认证系统登录脚本，支持Linux和macOS

## 使用方式

一般使用方式：

登录：`bash auth.sh -u [用户名] -p [密码]`

注销：`bash auth.sh -u [用户名] -p [密码] logout`


如果将账号密码写入脚本会更简单点：

登录：`bash auth.sh`

注销：`bash auth.sh logout`

*如果同时指定参数也修改了脚本变量，以指定参数为主*


如果将脚本重命名为auth放入环境变量（如 `/usr/local/bin` 目录）会更简单点：

登录：`auth`

注销：`auth logout`

当然，你也可以修改一下，加入到系统定时任务，实现自动化 : )

## LICENSE

[MIT license](https://github.com/0xHJK/srunauth/blob/master/LICENSE)
