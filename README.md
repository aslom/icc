
# IBM Container Client as self-contained container for client side usage

Contains in one docker image all required software described in
https://www.ng.bluemix.net/docs/containers/container_cli_ov.html#container_cli_ov

Uses data container to encapsulate state of client side tools in data container so you can easily switch environenets without modifying your real $HOME/.docker or $HOME/.ice directories

## Installation

### Create or update wrapper script for the latest version

```
docker pull aslom/icc
docker run aslom/icc cat /icc.sh > icc.sh
```

### Create script to use specific version of client

```
docker run aslom/icc:VVERSION cat /icc.sh > icc.sh
```

### Setup your environment variables

```
export ICC_ENV=foo_prod
docker run aslom/icc cat /env-skel.sh > foo_prod_env.sh
```

Edit foo_prod_env.sh

### Create data container

```
./icc.sh create-data-env
```

### Login into IBM Bluemix Cloud Foundry

```
./icc.sh cf login
```

### Login into IBM Bluemix Container service

```
LOCAL=true ./icc.sh cf ic login
```

### Check you can access the service

```
 ./icc.sh cf ic images
```

```
 ./icc.sh docker images
```

# Development

## Building client container

```
./build.sh
```


## Troubleshoot data container that keep all state:

```
docker run -it --volumes-from icc_env_${ICC_ENV} ubuntu /bin/bash
cd /home/icsng
find .
```
