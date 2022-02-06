#!/bin/bash
# TODO if syncthing is Up to Date (not syncing!)
# then
cd /home/ubuntu/photoprism
docker-compose exec photoprism photoprism import
