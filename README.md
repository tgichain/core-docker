# TGIC节点搭建(Docker)

基于`docker-compose`配置,手动安装请参考[这里](https://github.com/tgichain/core)。

## 使用前准备

### 修改配置

修改`devent.env`里面的配置即可

* `CORE_DB_USERNAME`: 数据库帐号
* `CORE_DB_PASSWORD`: 数据库密码

### 启动/关闭锻造

默认会启动锻造，如果不需要锻造，可以注释掉`entrypoint.sh`里面的代码

```shell
if [ "$MODE" = "forger" ] && [ -n "$SECRET" ] && [ -n "$CORE_FORGER_PASSWORD" ]; then
    export CORE_FORGER_BIP38=$(grep bip38 /home/node/.config/ark-core/$NETWORK/delegates.json | awk '{print $2}' | tr -d '"')
    export CORE_FORGER_PASSWORD
    sudo rm -rf /run/secrets/*
    tgic core:start --no-daemon
elif [ "$MODE" = "forger" ] && [ -z "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    echo "set SECRET and/or CORE_FORGER_PASWORD if you want to run a forger"
    exit
    elif [ "$MODE" = "forger" ] && [ -n "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    tgic core:start --no-daemon
fi
```



## 运行容器

```shell
sudo docker-compose up -d 
```

默认会启动两个容器

* `tgic-core-devnet`

* `tgic-core-postgres`

查看容器内的日志

```shell
sudo docker exec -it tgic-core-devnet pm2 logs  
```



## 维护容器

### 停止容器

```
docker-compose stop 
```

### 删除容器 

```
 docker-compose rm 
```



