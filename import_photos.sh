#!/bin/bash
# TODO if syncthing is Up to Date (not syncing!)
# e.g. docker exec -i syncthing syncthing cli --home=/var/syncthing/config show connections
# then:
docker-compose -f /home/ubuntu/photoprism/docker-compose.yml exec -i photoprism photoprism import
