# syntax=docker/dockerfile:experimental

ARG GS_MGMT_BUILDER_IMAGE=sysrepo-builder:latest
ARG GS_MGMT_BASE=ubuntu:20.04

FROM $GS_MGMT_BUILDER_IMAGE as builder

RUN rm -rf /usr/local/lib/python3.7

ARG http_proxy
ARG https_proxy

FROM $GS_MGMT_BASE

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
            apt update && apt install -qy python3 vim curl python3-distutils libgrpc++1

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python
RUN ldconfig

RUN pip install prompt_toolkit pyang

ADD onlp/libonlp.so /lib/x86_64-linux-gnu/
ADD onlp/libonlp-platform.so /lib/x86_64-linux-gnu/
ADD onlp/libonlp-platform-defaults.so /lib/x86_64-linux-gnu/
RUN ln -s libonlp-platform.so /lib/x86_64-linux-gnu/libonlp-platform.so.1

COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin/sysrepocfg /usr/local/bin/sysrepocfg
COPY --from=builder /usr/local/bin/sysrepoctl /usr/local/bin/sysrepoctl
COPY --from=builder /usr/lib/python3 /usr/lib/python3

RUN apt update && apt install -qy make

RUN ldconfig

# vim:filetype=dockerfile