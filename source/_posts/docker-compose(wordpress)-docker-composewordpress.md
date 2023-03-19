---
title: docker-compose(wordpress)
description: docker-compose(wordpress)
categories:
  - 演示
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/compose.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/compose.jpg'
businesscard: true
comments: 'yes'
url: /archives/docker-composewordpress
abbrlink: 265f6511
date: 2022-08-12 13:14:44
updated: 2022-08-12 13:18:31
tags:
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
docker-compose
{% endnote %}
{% endwow %}

```shell
version: '1'
services: 

  mysql: 
    image: mysql:5.6
    restart: always
    volumes: 
      - "./data:/var/lib/mysql"
    environment: 
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: password
    expose: 
      - "3306"

  wordpress: 
    image: wordpress:latest
    restart: always
    depends_on:
      - mysql 
    links: 
      - mysql
    environment: 
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress
    ports: 
      - "80:80"
 ```
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
