# 存储层部署与使用


- [存储层部署与使用](#存储层部署与使用)
  - [**Part1:TiDB部署**](#part1tidb部署)
    - [1.软硬件配置需求](#1软硬件配置需求)
    - [2.在中控机上部署 TiUP 组件](#2在中控机上部署-tiup-组件)
      - [2.1 执行如下命令安装 TiUP 工具：](#21-执行如下命令安装-tiup-工具)
      - [2.2 声明全局环境变量](#22-声明全局环境变量)
      - [2.3 安装 TiUP cluster 组件](#23-安装-tiup-cluster-组件)
    - [3. 设置集群拓扑并部署](#3-设置集群拓扑并部署)
      - [3.1 集群拓扑设置](#31-集群拓扑设置)
      - [3.2 检查集群存在的潜在风险](#32-检查集群存在的潜在风险)
      - [3.3 部署 TiDB 集群](#33-部署-tidb-集群)
      - [3.4.  替换TiKV实现](#34--替换tikv实现)
  - [**Part2: client-go**](#part2-client-go)


## **Part1:TiDB部署**

> 此阶段部署TiDB集群，内部包含TiKV集群和一个SQL Server(TiDB server)。使用时可以绕过TiDB server，直接使用TiKV集群进行键值存储；也可以通过TiDB server实现SQL访问。如同时需要键值存储和SQL存储，建议部署两个TiDB集群分别提供对应功能。

### 1.软硬件配置需求

[TiDB 软件和硬件环境建议配置 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/hardware-and-software-requirements)

[TiDB 环境与系统配置检查 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/check-before-deployment)

### 2.在中控机上部署 TiUP 组件

>  TiUP 组件是集群部署与管理工具。

#### 2.1 执行如下命令安装 TiUP 工具：

```sh
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```

#### 2.2 声明全局环境变量

```shell
source .bash_profile
```

检查

```shell
which tiup
```

#### 2.3 安装 TiUP cluster 组件

```sh
tiup cluste
```

如果已经安装，则更新 TiUP cluster 组件至最新版本：

```sh
tiup update --self && tiup update cluster
```

检查

```sh
tiup --binary cluster
```



### 3. 设置集群拓扑并部署

#### 3.1 集群拓扑设置

>  需要结合具体系统环境与业务需求进行配置,为了方便功能测试开发，这里提供一个经过测试的单机三节点配置文件，修改对应用户后（ssh的用户名）可以直接部署。

[TIKV_Deploy_Assets/topology.yaml](./TIKV_Deploy_Assets/topology.yaml)



#### 3.2 检查集群存在的潜在风险

> -- user参数需要与拓扑配置文件中保持一致，并保证不同节点间此用户的ssh连接。

```sh
tiup cluster check ./topology.yaml --user root [-p] [-i /home/root/.ssh/gcp_rsa]
```

自动修复集群存在的潜在风险

```shell
tiup cluster check ./topology.yaml --apply --user root [-p] [-i /home/root/.ssh/gcp_rsa]
```

#### 3.3 部署 TiDB 集群

```shell
tiup cluster deploy tidb-test v5.4.0 ./topology.yaml --user root [-p] [-i /home/root/.ssh/gcp_rsa]
```

> - `tidb-test` 为部署的集群名称。
> - `v5.4.0` 为部署的集群版本，可以通过执行 `tiup list tidb` 来查看 TiUP 支持的最新可用版本

执行如下命令检查 `tidb-test` 集群情况：

```shell
tiup cluster display tidb-test
```

启动集群

```shell
tiup cluster start tidb-test
```

#### 3.4.  替换TiKV实现

> 此部分待中科大部分后续调优，后续提供脚本支持一键替换，不影响任何接口和上层实现。因此可以先基于上述部署的集群进行开发测试。

替换脚本[TIKV_Deploy_Assets/replace_tikv.sh](./TIKV_Deploy_Assets/replace_tikv.sh)



## **Part2: client-go**

> 通过对原生的client-go进行修改，不仅包含原有的TiKV接口，同时支持包括自定义键值存储、图存储的相关功能。