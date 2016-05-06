#!/usr/bin/env bash

rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
