#!/bin/sh

PA_SOCKET="$(LC_ALL=C pactl info | grep 'Server String' | cut -f 3 -d' ')"

docker stop shairport-sync >/dev/null 2>&1
docker rm shairport-sync >/dev/null 2>&1

docker run -d \
    --env PULSE_SERVER=unix:/tmp/pulseaudio.socket \
    --env PULSE_COOKIE=/tmp/pulseaudio.cookie \
    --volume $PA_SOCKET:/tmp/pulseaudio.socket \
    --volume $PWD/pulseaudio.client.conf:/etc/pulse/client.conf \
    --volume /var/run/pulse/native:/var/run/pulse/native \
    --security-opt apparmor=unconfined \
    --volume $PWD/shairport-sync.conf:/etc/shairport-sync.conf \
    --user $(id -u):$(id -g) \
    --net host \
    --name shairport-sync \
    synclpz/shairport-sync:latest -a 'Shairport Player' -o pa -- application_name='Shairport Player'