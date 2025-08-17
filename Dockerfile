FROM alpine:latest

RUN apk update
RUN apk upgrade
RUN apk add cargo clang cmake curl git libc++ linux-headers makedoas python3 rsync rust samurai umount
RUN git clone https://github.com/cbpudding/maplelinux-bootstrap /maple