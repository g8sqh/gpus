FROM biigle/gpu-server:arm64v8 as intermediate

# Use an image based on Debian as we want to install TensorFlow. This didn't work
# with Alpine Linux.
FROM arm64v8/php:7.2-cli
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
        libsm6 libxext6 libxrender1 zlib1g libhdf5-100 cython3 \
        build-essential python3-dev python3-pip python3-setuptools libfreetype6-dev \
        liblapack-dev gfortran libjpeg62-turbo-dev libpng-dev zlib1g-dev libhdf5-dev \
    && pip3 install wheel \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && pip3 install \
        --extra-index-url https://developer.download.nvidia.com/compute/redist/jp33 \
        tensorflow-gpu \
    && rm -r ~/.cache \
    && pip3 uninstall -y wheel \
    && apt-get purge -y \
        build-essential python3-dev python3-pip python3-setuptools libfreetype6-dev \
        liblapack-dev gfortran libjpeg62-turbo-dev libpng-dev zlib1g-dev libhdf5-dev \
    && apt-get -y autoremove \
    && rm -r /var/lib/apt/lists/* \
    && rm /tmp/*

# Build OpenCV from source (for ARM)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgtk2.0-0 libtbb2 libdc1394-22 libavcodec57 libavformat57 libswscale4 \
        python3-numpy \
        build-essential cmake libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev \
        libswscale-dev python3-dev libtbb-dev libjpeg-dev libpng-dev libtiff5-dev \
        libdc1394-22-dev \
    && curl -L https://github.com/opencv/opencv/archive/3.4.3.tar.gz -o 3.4.3.tar.gz \
    && tar -xzf 3.4.3.tar.gz && cd opencv-3.4.3 \
    && mkdir release && cd release \
    && cmake -DBUILD_TIFF=ON -DBUILD_opencv_java=OFF -DWITH_CUDA=OFF -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON -DWITH_VTK=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE .. \
    && make \
    && make install \
    && apt-get purge -y \
        build-essential cmake libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev \
        libswscale-dev python3-dev libtbb-dev libjpeg-dev libpng-dev libtiff5-dev \
        libdc1394-22-dev \
    && apt-get -y autoremove \
    && rm -r /var/lib/apt/lists/*

# Just copy from intermediate biigle/app so the installation of dependencies with
# Composer doesn't have to run twice.
COPY --from=intermediate /var/www /var/www

WORKDIR /var/www

# This is required to run php artisan tinker in the worker container. Do this for
# debugging purposes.
RUN mkdir -p /.config/psysh && chmod o+w /.config/psysh
