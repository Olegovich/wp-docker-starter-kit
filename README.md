# wp-docker-starter-kit

> Стартовая сборка, только для локальной разработки под Linux (Ubuntu).

## Развертывание нового проекта:
1. Установить docker. После установки проверить версию:
    ```bash
    docker version
    ```
    
2. Установить docker-compose. После установки проверить версию:
    ```bash
    docker-compose version
    ```
    
3. Добавить управление докером __not-root__ юзеру:
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```
    
    Перезагрузить систему, чтобы применились изменения.

4. Создать локальный домен в файле хостов __/etc/hosts__
    ```bash
    127.0.0.1 wp-starterkit.local
    ```

5. Клонировать репо для работы с проектом:
    ```bash
    git clone git@github.com:Olegovich/wp-docker-starter-kit.git
    ```

6. Удалить папку __.git__ из корня проекта, чтобы отвязаться от репозитория стартера.

7. Сгенерировать в проекте ssl-сертификат через библиотеку __mkcert__:
    
    - Ставим глобально утилиту __libnss3-tools__
        ```bash
        sudo apt install libnss3-tools
        ```
   
    - Скачиваем latest-версию файла для __linux-amd64__ - <https://github.com/FiloSottile/mkcert/releases>
        
        Например, для скачивания версии 1.4.4 - <https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64>
    
    - Перемещаем файл из папки загрузок -> в __/usr/local/bin__ (заменить X.X.X на версию скачанного файла)
        ```bash
        sudo mv mkcert-vX.X.X-linux-amd64 /usr/local/bin
        ```
    
    - Далее в терминале из папки __/usr/local/bin__, делаем файл исполняемым и создаем на него symlink:
        ```bash
        chmod +x mkcert-vX.X.X-linux-amd64
        sudo ln -s mkcert-vX.X.X-linux-amd64 mkcert
        ```
    
    - Установливаем локальный центр сертификации (CA):
        ```bash
        mkcert -install
        ```
    
    - Далее в терминале из папки проекта __/docker/nginx/ssl__, генерируем 2 файла сертификата:
        ```bash
        mkcert -key-file wp-starterkit.local.key -cert-file wp-starterkit.local.crt wp-starterkit.local
        ```

8. Затем, чтобы пофиксить ошибку REST-API в WP (которая появится после запуска сайта), нужно создать сеть в докере 
и взять оттуда __Gateway IP__, который будем передавать в докер-контейнер:
    ```bash
    docker network create starterkit-wp-network
    docker network inspect starterkit-wp-network
    ```

    Пример вывода информации о сети:
    
    ```bash
    "Name": "starterkit-wp-network",
    ...
    "IPAM": {
        "Driver": "default",
        "Options": {},
        "Config": [
            {
                "Subnet": "172.21.0.0/16",
                "Gateway": "172.21.0.1"
            }
        ]
    },
    ```
   
    Копируем ip-адрес из "Gateway" и вставляем в файл проекта __/docker/.env.example__ в параметр __WP_EXTRA_HOST_IP__ 
    (вместо текущего значения __XXX.XX.X.X__)
    
9. Далее можно развертывать проект из папки __/www__:
    ```bash
    bash run.sh
    ```
    
10. После успешного развертывания, сайт будет доступен по ссылке <https://wp-starterkit.local/> 

11. После быстрой установки WP, нужно зайти в админке в настройки __Permalinks__, 
и выбрать "Post name".

    > Если не изменить Permalinks - не будет работать структура урлов REST-API в формате /wp-json 
    https://developer.wordpress.org/rest-api/extending-the-rest-api/routes-and-endpoints/

---

## Работа с готовым проектом:
После перезагрузки системы или после остановки контейнеров - достаточно запустить контейнеры из папки __/docker__:

```bash
docker-compose start
```

И дальше работать с сайтом по ссылке <https://wp-starterkit.local/>

Для остановки контейнеров:

```bash
docker-compose stop
```

---

## Для полного перезапуска проекта:
1. Перейти в папку __/docker__ и выполнить команды:
    ```bash
    docker-compose down
    docker image rm $(docker images -q starterkit-wp_mysql) $(docker images -q starterkit-wp_nginx) $(docker images -q starterkit-wp_wordpress)
    docker volume rm starterkit-wp_mysql
    docker network rm starterkit-wp-network
    rm -rf ../www/html
    ```
   
   ```bash
   docker network create starterkit-wp-network
   docker network inspect starterkit-wp-network
   ```

2. Скопировать ip-адрес из "Gateway" и вставить в файл проекта __/docker/.env__ в параметр __WP_EXTRA_HOST_IP__ 
(т.е. заменяем предыдущий ip-адрес, который будет отличаться от нового).

3. Развернуть проект из папки __/www__:
   ```bash
   bash run.sh
   ```
