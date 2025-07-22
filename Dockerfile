FROM rockylinux:9

RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install createrepo unzip && \
    yum clean all && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscli*

COPY update_repo.sh /usr/local/bin/update_repo.sh
