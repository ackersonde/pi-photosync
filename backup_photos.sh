#!/bin/bash
rsync -a /home/ubuntu/Pictures/ 192.168.178.28:/mnt/usb4TB/backups/photos/originals/
rsync -a /home/ubuntu/Pictures/ root@vault.ackerson.de:/mnt/hetzner_disk/backups/photos/
