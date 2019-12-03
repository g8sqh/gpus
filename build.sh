#!/usr/bin/env bash

docker-compose build

read -p "Publish the images to GitHub? [y/N]" -n 1 -r
# Check if the current HEAD belongs to a version.
git describe --tags --exact-match &> /dev/null
if [ $? -eq 0 ]; then
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        VERSION=$(git describe --tags)
        docker tag \
            docker.pkg.github.com/biigle/gpus/gpus-app:latest \
            docker.pkg.github.com/biigle/gpus/gpus-app:$VERSION
        docker tag \
            docker.pkg.github.com/biigle/gpus/gpus-worker:latest \
            docker.pkg.github.com/biigle/gpus/gpus-worker:$VERSION
        docker tag \
            docker.pkg.github.com/biigle/gpus/gpus-web:latest \
            docker.pkg.github.com/biigle/gpus/gpus-web:$VERSION

        docker push docker.pkg.github.com/biigle/gpus/gpus-app:$VERSION
        docker push docker.pkg.github.com/biigle/gpus/gpus-worker:$VERSION
        docker push docker.pkg.github.com/biigle/gpus/gpus-web:$VERSION

        docker rmi docker.pkg.github.com/biigle/gpus/gpus-app:$VERSION
        docker rmi docker.pkg.github.com/biigle/gpus/gpus-worker:$VERSION
        docker rmi docker.pkg.github.com/biigle/gpus/gpus-web:$VERSION
    fi
fi

# Update the "latest" images if the current HEAD is on master.
if [ "$(git rev-parse --abbrev-ref HEAD)" == "master" ]; then
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker push docker.pkg.github.com/biigle/gpus/gpus-app:latest
        docker push docker.pkg.github.com/biigle/gpus/gpus-worker:latest
        docker push docker.pkg.github.com/biigle/gpus/gpus-web:latest
    fi
fi

docker image prune
