FROM biigle/gpu-server as intermediate

# Use an image based on Debian as we want to install TensorFlow. This didn't work
# with Alpine Linux.
FROM php:7.1
MAINTAINER Martin Zurowietz <martin@cebitec.uni-bielefeld.de>

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl libxml2-dev \
    && docker-php-ext-install pdo json mbstring pcntl \
    && rm -r /var/lib/apt/lists/*

# Set this library path to the Python modules are linked correctly.
# See: https://github.com/python-pillow/Pillow/issues/1763#issuecomment-204252397
ENV LIBRARY_PATH=/lib:/usr/lib
COPY .docker/requirements.txt /tmp/requirements.txt
# Install Python dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 libfreetype6 liblapack3 libstdc++6 libjpeg62-turbo libpng16-16 \
        libsm6 libxext6 libxrender1 zlib1g libhdf5-10 \
        build-essential python3-dev python3-pip python3-setuptools libfreetype6-dev \
        liblapack-dev gfortran libjpeg62-turbo-dev libpng-dev zlib1g-dev libhdf5-dev \
    && pip3 install wheel \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && pip3 uninstall wheel \
    && apt-get purge -y \
        build-essential python3-dev python3-pip python3-setuptools libfreetype6-dev \
        liblapack-dev gfortran libjpeg62-turbo-dev libpng-dev zlib1g-dev libhdf5-dev \
    && apt-get -y autoremove \
    && rm -r /var/lib/apt/lists/* \
    && rm /tmp/*

# Just copy from intermediate biigle/app so the installation of dependencies with
# Composer doesn't have to run twice.
COPY --from=intermediate /var/www /var/www

WORKDIR /var/www

# This is required to run php artisan tinker in the worker container. Do this for
# debugging purposes.
RUN mkdir -p /.config/psysh && chmod o+w /.config/psysh
