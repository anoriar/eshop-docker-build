FROM php:7.1-fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        graphviz \
        ssh-client \
        libpq-dev \
        libmemcached-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        curl \
        libmagickwand-dev \
        cron \
        supervisor \
        nano \
        libxml2-dev \
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/include \
        --with-freetype-dir=/usr/include \
    && docker-php-ext-install -j$(nproc) \
        mcrypt \
        opcache \
        gd \
        mysqli \
        pdo_mysql \
        soap \
    && pecl install \
        memcached \
        imagick \
        xdebug-2.7.1 \
    && docker-php-ext-enable \
        memcached \
        imagick \
        xdebug \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/*


# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin && \
        echo "alias composer='composer'" >> /root/.bashrc && \
        composer

RUN usermod -u 1000 www-data

# Cron
COPY cron/crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab
RUN crontab /etc/cron.d/crontab
RUN touch /var/log/cron.log

#Supervisor
COPY supervisord.conf /etc/supervisor
COPY ./supervisor/* /etc/supervisor/conf.d

# Sendmail
RUN apt-get update &&\
    apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git &&\
    rm -rf /var/lib/apt/lists/*
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail


WORKDIR /home/bitrix

EXPOSE 9000

ARG GELF_HOST
ARG GELF_PORT

ENV GELF_HOST=${GELF_HOST}
ENV GELF_PORT=${GELF_PORT}


#CMD ["php-fpm"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
