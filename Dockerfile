# QLC+ (graphic app) Docker Container
# https://www.qlcplus.org

# Maintainer NOTE: I couldn't find an official Dockerfile for QLC, but I found a random
# example and copied it from https://github.com/jessfraz/dockfmt/issues/6
# which seems to reference https://github.com/djarbz/qlcplus but that appears to be a private repo :shrug:
#
# Also, looks like with phusion, there's a few better ways we could be doing this. use latest instructions from http://phusion.github.io/baseimage-docker/
# for CMD and setuser

# NOTE: QT has an option to run in headless or VNC mode too, you have to select the output plugin. Test if it takes less memory (or, if we care)
# The command we have to run is: (It's a QT plugin doing the work here)
# qtapp -platform vnc:mode=websocket

# pick version# From https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
FROM phusion/baseimage:bionic-1.0.0

LABEL maintainer="Dominic Cerquetti binary1230+maintainer@gmail.com"

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="binary1230/qlcplus"
LABEL org.label-schema.description="QLC+ Docker with GUI"
LABEL org.label-schema.url="https://www.qlcplus.org"
LABEL org.label-schema.vcs-url="https://github.com/binary1230/qlcplus-docker"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="binary1230"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run -it --rm --name QLCplus --device /dev/snd -p 9999:80 --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' --env=DISPLAY=unix${DISPLAY} binary1230/qlcplus"
LABEL org.label-schema.docker.cmd.devel="docker run -it --rm --name QLCplus binary1230/qlcplus:4.12.3 xvfb-run qlcplus"

VOLUME /QLC

WORKDIR /QLC

ENV QLC_DEPENDS="\
                libasound2 \
                libfftw3-double3 \
                libftdi1 \
                libqt5core5a \
                libqt5gui5 \
                libqt5multimedia5 \
                libqt5multimediawidgets5 \
                libqt5network5 \
                libqt5script5 \
                libqt5widgets5 \
                libusb-0.1-4"

# XVFB is used to fake an X server for testing and headless mode.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               ${QLC_DEPENDS} \
               xvfb \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://github.com/mcallegari/qlcplus/releases/tag/QLC+_4.12.3
ARG QLC_VERSION=4.12.3

ADD https://www.qlcplus.org/downloads/${QLC_VERSION}/qlcplus_${QLC_VERSION}_amd64.deb /opt/qlcplus.deb

RUN dpkg -i /opt/qlcplus.deb

# https://www.qlcplus.org/docs/html_en_EN/commandlineparameters.html
CMD ["/usr/bin/qlcplus","--operate","--web","--open /QLC/default_workspace.qxw" ]