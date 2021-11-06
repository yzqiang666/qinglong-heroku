FROM node:lts-alpine
LABEL maintainer="whyour"
ARG QL_URL=https://github.com/whyour/qinglong.git
ARG QL_BRANCH=master
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    QL_DIR=/ql
WORKDIR ${QL_DIR}
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash coreutils moreutils gitcurl wget tzdat perl openssl nginx python3 jqopenssh tmux \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && touch ~/.bashrc \
    && mkdir /run/nginx \
    && git clone -b ${QL_BRANCH} ${QL_URL} ${QL_DIR} \
    && git clone -b ${QL_BRANCH} https://github.com/yzqiang666/qinglong-heroku.git /ql/start \
    && git config --global user.email "qinglong@@users.noreply.github.com" \
    && git config --global user.name "qinglong" \
    && git config --global pull.rebase true \
    && cd ${QL_DIR} \
    && cp -f .env.example .env \
    && chmod 777 ${QL_DIR}/shell/*.sh \
    && chmod 777 ${QL_DIR}/docker/*.sh \
    && chmod 777 ${QL_DIR}/start/*.sh \
    && npm install -g pnpm \
    && pnpm install -g pm2 \
    && pnpm install -g ts-node typescript tslib \
    && rm -rf /root/.npm \
    && pnpm install --prod \
    && rm -rf /root/.pnpm-store \
    && git clone -b ${QL_BRANCH} https://github.com/whyour/qinglong-static.git /static
    
ADD docker-entrypoint.sh /ql/start/docker-entrypoint.sh
#ENTRYPOINT ["./docker/docker-entrypoint.sh"]
#ENTRYPOINT ["sh", "-c", "./docker/docker-entrypoint.sh"]
CMD ["/ql/start/docker-entrypoint.sh"]
