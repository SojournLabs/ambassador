# ambassador
A secure ambassador for Docker containers by Sojourn Labs. This repository contains a `Dockerfile` for building a [Docker](http://www.docker.com) image that implements the [ambassador pattern](https://docs.docker.com/articles/ambassador_pattern_linking/) and wrapper scripts. This particular ambassador implementation includes automatic configuration using the Docker API and `etcd`. Communication is encrypted using OpenSSL. Thus, in order to use this, each host machine must have client and/or server certificates as appropriate.

Docker image
============
Server
------
To activate the server, call the ambassador image with the `server` argument:

    docker run -t -i --rm -v /var/run/docker.sock:/var/run/docker.sock
                          -v path/to/ca/certificate:/vapr/certstore/ca.crt:ro \
                          -v path/to/server/certificate:/vapr/certstore/server.crt:ro \
                          -v path/to/server/key:/vapr/keys/server.key:ro \
                          -p p1 -p p2 -p p3 ... -p pn \
                          sojournlabs/ambassador server container_name external_ip
where `container_name` is the name of the container to expose and `external_ip` is the ip address of the host computer. `p1` ... `pn` are arbitrary port numbers. `n` must be at least equal to the number of ports exposed by container.

Client
------
To activate the client, call the ambassador image with the `client` argument:

    docker run -t -i --rm -v /var/run/docker.sock:/var/run/docker.sock
                          -v path/to/ca/certificate:/vapr/certstore/ca.crt:ro \
                          -v path/to/client/certificate:/vapr/certstore/client.crt:ro \
                          -v path/to/client/key:/vapr/keys/client.key:ro \
                          sojournlabs/ambassador client container_name

where *container_name* is the name of the container to connect to.


Wrappers
========
The wrappers were intended to be used with [vapr](https://github.com/SojournLabs/vapr) but can easily be used independently.
Server
------
To start the server, run

    TLS_KEY=path/to/key ./server container_name external_ip
    
where `container_name` is the name of the container with services to be made public.

Client
------
To start the client, run

    TLS_KEY=path/to/key ./client container_name
    
where `container_name` is the name of the container with services to be made public.