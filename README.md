# Let's Encryptで申請時に一時的にFirewallの制限を緩める

## 使用環境

- AlmaLinux 9.6

## Ansibleの構成

Ansibleでまとめました。

```bash
[root@test LetsEncrypt]# tree -L 4
.
├── ansible.cfg
├── inventory.ini
├── README.md
├── roles
│   ├── apache # Apache設定
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   │   ├── custom_nginx.conf
│   │   │   └── custom_nginx_host.conf
│   │   └── vars
│   │       └── main    
│   ├── certbot # Let's Encrypt
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   │   ├── post_hook.sh
│   │   │   └── pre_hook.sh
│   │   └── vars
│   ├── common # パッケージインストール
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main
│   │           └── main  
│   ├── firewall # 海外IP制限スクリプト
│   │   ├── tasks
│   │   │   └── main.yml
│   │   ├── templates
│   │   │   ├── lock.sh
│   │   │   └── unlock.sh
│   │   └── vars
│   │       └── main
│   └── nginx # nginx設定
│       ├── handlers
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       │   └── custom-proxy.conf
│       └── vars
│           └── main
└── site.yml

27 directories, 18 files
[root@test LetsEncrypt]# 
```

## 手順

1. リポジトリをダウンロード

2. `dnf install ansible`

3. `ansible-playbook -i inventory.ini site.yml`

4. Route53のホストゾーンで、Aレコードを追加
> [!NOTE]
> VPSのIPを値に
   
5. 鎖国中で一度実施
> [!NOTE]
> 本来なら失敗するはず。

```bash
certbot certonly --standalone \
  -d XXXX.com -d www.XXXX.com \
  --non-interactive --agree-tos -m XXXX@gmail.com
```

6. pre, postフックありで再度実施
> [!NOTE]
> 出力に実行されている様子が表示されます。

```bash
certbot certonly --standalone \
  -d XXXX.com -d www.XXXX.com \
  --pre-hook "/etc/letsencrypt/renewal-hooks/pre/pre_hook.sh" \
  --post-hook "/etc/letsencrypt/renewal-hooks/post/post_hook.sh" \
  --non-interactive --agree-tos -m XXXX@gmail.com
```

7. `roles/nginx/tasks/main.yml`内のコメントアウトを外して再度

```bash
ansible-playbook -i inventory.ini site.yml
```

## 簡易フロー
```bash
パッケージのインストール
↓
apacheのポートを8080に変更
↓
virhost変更
↓
apache起動
↓
nginx起動
↓
カスタムproxy.confを作成
↓
nginxリスタート
↓
鎖国
↓
WebRoot用ディレクトリ作成
↓
firewallにHTTP、HTTPSアクセス許可
↓
certbotのpre,post hook用ディレクトリの作成
↓
pre,post_hook.shのコピー
↓
手動certbot実行
↓
pre hookで鎖国解除
↓
証明書発行
↓
post hookで再び鎖国
↓
nginxリスタート
↓
終わり
```

![prehook](スクリーンショット%202026-08-29%20001349.png)
![posthook](スクリーンショット%202026-08-29%20001404.png)
![posthook](スクリーンショット%202026-08-29%20001524.png)
![posthook](スクリーンショット%202026-08-29%20001540.png)
