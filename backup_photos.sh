#!/bin/bash
rsync -a /home/ubuntu/Pictures/ 192.168.178.28:/mnt/usb4TB/backups/photos/originals/
rsync -aP /home/ubuntu/Pictures/ vault:/mnt/hetzner_disk/backups/photos/
