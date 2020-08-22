# Shairport Sync

Shairport Sync is an Apple AirPlay audio player. For more information, please visit its [GitHub repository](https://github.com/mikebrady/shairport-sync).

## Dockerized build

This build is intended for headless server with:
* Local D-Bus control disabled
* Use of host's Avahi via `system` D-Bus server
* Pulse Audio output via system-wide daemon (https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/SystemWide)

## Running

* See start.sh
* Update shairport-sync.conf
* Remember to run container as user that have access to PulseAudio

`start.sh` will run Shairport Sync as a daemon in a Docker container, accessing the computer's PulseAudio infrastructure.

## Options

Please go to the [GitHub repository](https://github.com/mikebrady/shairport-sync) for details of the options.

## Configuration File

`shairport-sync.conf` from repo root is mounted at `/etc/shairport-sync.conf` in the container by start.sh.

Lots more information at the [GitHub repository](https://github.com/mikebrady/shairport-sync).
