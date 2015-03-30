#########################################################################################
#
#  Provide secure connections between docker containers across an untrusted network.
#  https://github.com/SojournLabs/ambassador
#
#########################################################################################

# Usage (server mode):
#     docker run -t -i --rm -v /var/run/docker.sock:/var/run/docker.sock
#                           -v path/to/ca/certificate:/vapr/certstore/ca.crt:ro \
#                           -v path/to/server/certificate:/vapr/certstore/server.crt:ro \
#                           -v path/to/server/key:/vapr/keys/server.key:ro \
#                           -p p1 -p p2 -p p3 ... -p pn \
#                           sojournlabs/ambassador server container_name external_ip
# where container_name is the name of the container to expose and external_ip is the ip
# address of the host computer. p1 ... pn are arbitrary port numbers. n must be at least
# equal to the number of ports exposed by container.

# Usage (client mode):
#     docker run -t -i --rm -v /var/run/docker.sock:/var/run/docker.sock
#                           -v path/to/ca/certificate:/vapr/certstore/ca.crt:ro \
#                           -v path/to/client/certificate:/vapr/certstore/client.crt:ro \
#                           -v path/to/client/key:/vapr/keys/client.key:ro \
#                           sojournlabs/ambassador client container_name
# where contaicontainer_namener is the name of the container to connect to.


FROM	busybox
MAINTAINER	jonathan lung <auto+vapr@heresjono.com>
# Include the socat binary from the debian repository. Inserted using
#   docker run -t -i --rm -v `pwd`:/vapr/build sojournlabs/busyboxer socat socat
#   tar xvf socat.tar.gz && rm -f socat.tar.gz
ADD lib64 /lib64
ADD bin /bin
# The following file can be obtained using
#     curl -O https://raw.githubusercontent.com/SojournLabs/dockertools/master/bin/http.sh; chmod +x http.sh
ADD http.sh /bin/http.sh
# You may wish to compare the contents of etcdctl.sh and JSON.awk against a signed copy.
RUN . /bin/http.sh; HTTP_LATENCY=3 https_content raw.githubusercontent.com GET /SojournLabs/dockertools/master/bin/etcdctl.sh > /bin/etcdctl.sh; chmod +x /bin/etcdctl.sh
RUN . /bin/http.sh; HTTP_LATENCY=3 https_content raw.githubusercontent.com GET /step-/JSON.awk/master/JSON.awk | sed 's|/bin/awk|/usr/bin/awk|' > /bin/JSON.awk; chmod +x /bin/JSON.awk
ADD amb /bin/amb
ENTRYPOINT ["/bin/amb"]
