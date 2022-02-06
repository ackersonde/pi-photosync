#!/bin/bash
# TODO if syncthing is Up to Date (not syncing!)
# then
docker-compose -f /home/ubuntu/photoprism/docker-compose.yml exec -i photoprism photoprism import
