FROM python:3.8-alpine

ADD https://github.com/rastern/vmt-connect/archive/v3.2.1.tar.gz /tmp/vmtconnect.tar.gz
ADD https://github.com/turbonomic/vmt-plan/releases/download/v2.0.4/vmtplan-2.0.4-py3-none-any.whl /tmp/vmtplan-2.0.4-py3-none-any.whl

RUN pip install /tmp/vmtconnect.tar.gz && \
    pip install /tmp/vmtplan-2.0.4-py3-none-any.whl && \
    pip install umsg && \
    pip install dateutils && \
    pip install pyyaml

RUN rm -rf /tmp/*
