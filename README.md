# Timing boot time of VM vs container

## Usage

To time the start time of the container:
In one shell run

```bash
./wait-for-http-8081.sh
```

In another shell run

```bash
vagrant ssh
podman run --rm --name nginx-container -p 8080:80 nginx:latest
```

The wait script will display 'Nginx up and running!' when the container has fully started.

## Results

On my Framework 16:

- VM: 10.4 s
- container: 0.2 s
