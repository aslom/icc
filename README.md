
!!! IBM Container Client as self-contained container for client side usage

Contains in one docker image all required software described in
https://www.ng.bluemix.net/docs/containers/container_cli_ov.html#container_cli_ov

!! Using client container

! Create wrapper script

```
docker run icsng/client cat /icc.sh > icc.sh
```

! Setup your environment variables

```
docker run icsng/client cat /env-skel.sh > default_env.sh
```

Edit default_env.sh

! Create data container

```
./icc.sh create-data-env
```

! Login into IBM Bluemix Cloud FOundry

```
./icc.sh cf login
```

! Login into IBM Bluemix Container service

```
./icc.sh cf ic login
```

! Check you can access the service

```
 ./icc.sh cf ic images
```

```
 ./icc.sh docker images
```


!! Building client container

```
./build.sh
```


!! Troubleshoot data container that keep all state:

```
docker run -it --volumes-from icsng_env_default ubuntu /bin/bash
cd /home/icsng
find .
```
