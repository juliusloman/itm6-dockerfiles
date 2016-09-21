FROM centos:7
MAINTAINER Julius Loman <lomo@kyberia.net>

ARG IMG_ITM_BASE 

ARG IMG_ITM_FP

ADD ms_install.txt ms_config.txt ms_run.sh /

# Add dependencies
RUN yum --setopt=tsflags=nodocs -y install tar libstdc++.i686 compat-libstdc++-33.i686 glibc.i686 libgcc.i686 nss-softokn-freebl hostname compat-libstdc++-33 compat-libstdc++-296 libXmu libXtst openmotif22 openmotif dejavu-fonts-common xauth libaio ksh &&  rm -rf /var/cache/yum/* && yum clean all && \
    mkdir -p /tmp/itm_install/base /tmp/itm_install/fp && \
    curl $IMG_ITM_BASE |tar -xzvf - -C /tmp/itm_install/base && \
    curl $IMG_ITM_FP |tar -xzvf - -C /tmp/itm_install/fp  --strip-components=1 && \
    cd /tmp/itm_install/base && \
    setarch $(uname -m) --uname-2.6 ./install.sh -q -h /opt/IBM/ITM -p /ms_install.txt && \
    cd /tmp/itm_install/fp && \
    setarch $(uname -m) --uname-2.6 ./install.sh -q -h /opt/IBM/ITM -p /ms_install.txt && \
    rm -rf /tmp/itm_install/ && \
    useradd itm && chown -R itm:itm /opt/IBM/ITM && \
    chmod +x /ms_run.sh && \
    setarch $(uname -m) --uname-2.6 /opt/IBM/ITM/bin/SetPerm -s TEMS && \
    setarch $(uname -m) --uname-2.6 /opt/IBM/ITM/bin/secureMain lock -g itm

CMD /ms_run.sh
