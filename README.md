# Free-BSD-xui

This is an xray panel based on serv00 free server installation x-ui for freebsd that supports multi-protocol and multi-user. This version supports FreeBSD non-root installation.


# Function introduction

- System status monitoring
- Supports multi-user and multi-protocol, web page visual operation
- Supported protocols: vmess, vless, trojan, shadowsocks, dokodemo-door, socks, http
- Support configuring more transmission configurations
- Traffic statistics, traffic limit, limit expiration time
- Customizable xray configuration templates
- Support https access panel (bring your own domain name + SSL certificate)
- For more advanced configuration items, see the panel for details

# Installation & Upgrade
Before installation, please prepare your username, password and two ports (panel access port and traffic monitoring port)!
```
wget -O x-ui.sh -N --no-check-certificate https://raw.githubusercontent.com/ehsanasekhi/am-serv00-x-ui/main/x-ui.sh && chmod +x x-ui.sh && ./x-ui.sh
```

## 手动安装&升级

1. 首先从 https://github.com/amclubs/am-serv00-x-ui/releases 下载最新的压缩包，一般选择 `amd64`架构
2. 然后将这个压缩包上传到服务器的 `/home/[username]`目录下，

> 如果你的服务器 cpu 架构不是 `amd64`，自行将命令中的 `amd64`替换为其他架构

```
cd ~
rm -rf ./x-ui
tar zxvf x-ui-freebsd-amd64.tar.gz
chmod +x x-ui/x-ui x-ui/bin/xray-freebsd-* x-ui/x-ui.sh
cp x-ui/x-ui.sh ./x-ui.sh
cd x-ui
crontab -l > x-ui.cron
echo "0 0 * * * cd $cur_dir/x-ui && cat /dev/null > x-ui.log" >> x-ui.cron
echo "@reboot cd $cur_dir/x-ui && nohup ./x-ui run > ./x-ui.log 2>&1 &" >> x-ui.cron
crontab x-ui.cron
rm x-ui.cron
nohup ./x-ui run > ./x-ui.log 2>&1 &
```

## SSL证书申请

建议使用Cloudflare 15年证书

## Tg机器人使用（开发中，暂不可使用）

此功能未经测试！

## 建议系统

- FreeBSD 14+

# 感谢
[parentalclash](https://github.com/parentalclash/x-ui-freebsd)、[vaxilu](https://github.com/vaxilu/x-ui)

  # 
 <center><details><summary><strong> [点击展开] 赞赏支持 ~🧧</strong></summary>
 *我非常感谢您的赞赏和支持，它们将极大地激励我继续创新，持续产生有价值的工作。*
  
 - **USDT-TRC20:** `TWTxUyay6QJN3K4fs4kvJTT8Zfa2mWTwDD`
  
 </details></center>

 #
 免责声明:
 - 1、该项目设计和开发仅供学习、研究和安全测试目的。请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
 - 2、使用本程序必循遵守部署服务器所在地区的法律、所在国家和用户所在国家的法律法规。对任何人或团体使用该项目时产生的任何后果由使用者承担。
 - 3、作者不对使用该项目可能引起的任何直接或间接损害负责。作者保留随时更新免责声明的权利，且不另行通知。
 
 
  
