---
title: "How a Docker container can exit successfully with OutOfMemory error"
date: 2024-11-28T23:25:17+03:00
draft: false
github_link: "https://github.com/chriswachira"
author: "Chris Wachira"
tags:
  - Docker
  - Linux
  - Containers
image: /images/docker.jpg
description: ""
toc: 
---

Have you ever run a container and it exits successfully (code 0) but with an OutOfMemory error at the same time, leaving you confused and questioning your life decisions?

<img 
    style="display: block; 
           margin-left: auto;
           margin-right: auto;
           width: 30%;"
    src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExMTY5c2xhNDZ0cXczdXl2NTVrNDd0NzJhcmVoNjQ2bWE4eG1sMGl1dyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l3q2K5jinAlChoCLS/200w.webp">
</img>

Let me explain the how and why by firstly talking about the OutOfMemory Killer.

&nbsp;

### OutOfMemory Killer :skull_and_crossbones:

Also known as the OOM Killer, this is a mechanism built into the Linux kernel whose main purpose is to handle situations when the system is critically low on memory (physical or swap).

It verifies that the system is truly out of memory and will select a process to kill it to free up memory. The selection is based on a process’s OOM Score.

&nbsp;

### What is OOM Score?

Every running process in Linux has an oom_score. The operating system calculates it based on several criteria, which are mainly influenced by the amount of memory the process is using. Typically, the oom_score varies between -1000 and 1000. The process with the highest oom_score gets killed first by OOM Killer when the system starts running critically low on memory.

You can check the oom_score of a running process using its process ID:

```
cat /proc/process_ID/oom_score
```

<img 
    style="display: block; 
           margin-left: auto;
           margin-right: auto;
           width: 60%;"
    src="https://turnoff.us/image/en/bad-malloc.png"
    alt="Bad malloc by Daniel Stori (turnoff.us)">
</img>

&nbsp;

### Okay then, why did I get exit code 0 and OutOfMemory at the same time?

This happens when a “leaf” process that’s not the main process defined in your Docker image’s ENTRYPOINT or CMD, attempts to use more memory than is available. Depending on your application, another process can be spawned to perform a certain action, and if that process attempts to use more memory than what’s available, the OOM Killer will spring into action and kill that process.

Since the leaf process was not the main process for your container, the main process can continue running until it completes its main job or it can run forever. In this situation, the Docker runtime takes note of the OOM event, even though it wasn’t for the main process. Let’s see this whole thing in action.

&nbsp;

### Locally replicate the exit code 0 and OOM combo...

To replicate this combination locally, you’ll need to have Docker running (obviously) and the `jq` tool installed.

1. Run a simple NGINX container with a hard memory limit of 1GB.

```
docker run -d -p 8000:80 --memory 1G nginx:latest
```


2. Exec into the running container:

```
docker exec -it CONTAINER_ID /bin/bash
```

3. Install the stress package:

```
root@:/# apt update && apt install -y stress
```

4. Run stress with the following arguments:

```
stress -c 2 -m 4 —vm-bytes 512M
```

* The above command will try to use more memory than is available. You should see the output below. Notice the second line: worker ID got signal 9.

```
stress: info: [168] dispatching hogs: 2 cpu, 0 io, 4 vm, 0 hdd
stress: FAIL: [168] (425) <-- worker 172 got signal 9
stress: WARN: [168] (427) now reaping child worker processes
stress: FAIL: [168] (461) failed run completed in 1s 
```

5. From another terminal shell, stop the container with `docker stop` which will gracefully terminate the main process in the container:

```
docker stop CONTAINER_ID
```

6. Check the container details using docker inspect:

```
docker inspect CONTAINER_ID | jq ".[0].State"
```

* You should see a similar output as below:

```
{
  "Status": "exited",
  "Running": false,
  "Paused": false,
  "Restarting": false,
  "OOMKilled": true,
  "Dead": false,
  "Pid": 0,
  "ExitCode": 0,
  "Error": "",
  "StartedAt": "2024-09-27T08:18:42.210404427Z",
  "FinishedAt": "2024-09-27T08:27:21.077232458Z"
}
```

Note that `OOMKilled` is `true` and `ExitCode` is 0. Since `stress` was not the main process in the container, the main process can continue forever and exit successfully.

&nbsp;


References:

1. https://linuxhandbook.com/oom-killer/
2. https://github.com/aws/amazon-ecs-agent/issues/2467#issuecomment-2378848424
