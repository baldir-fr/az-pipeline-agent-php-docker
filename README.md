# Docker Self-hosted Azure Pipeline Agents

This is a starter for a docker based Self-hosted Azure Pipeline Agents.

This is an alternative to [Microsoft Hosted Agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml).

Based on [Run a self-hosted agent in Docker](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops).

Be aware of [Common Pitfalls of using Self-Hosted Build Agents](https://devblogs.microsoft.com/cse/2023/02/22/common-pitfalls-of-using-self-hosted-agents/).

## Capabilities

| Name    | description        |
|---------|--------------------|
| php 8.1 | install-php-8.1.sh | 
| npm     | npm 8              |
| curl    |                    |
| node.js | node 16            |
| git     |                    |

## Setup .env

In the examples below, replace `{your-organisation-name}` with your actual Azure DevOps organization name.

Copy `.env.sample` to `.env` file

Change the value for `AZP_URL`:

```dotenv
AZP_URL=https://dev.azure.com/{your-organisation-name}
```

### Generate a Personal Access Token

Go to th Personal Access Tokens page in your Azure DevOps Organization.

Ex. `https://dev.azure.com/{your-organisation-name}/_usersSettings/tokens`

Create a new Personal access token with following permissions:

- Build (Read & execute)
- Code (Full)
- Code (Status)
- Environment (Read & manage)
- Packaging (Read, write, & manage)
- Pipeline Resources (Use and manage)
- Release (Read, write, execute, & manage)
- Secure Files (Read, create, & manage)
- Service Connections (Read & query)
- Test Management (Read & write)
- Pull Request Threads (Read & write)

Paste the token in your `.env` file:

```dotenv
AZP_TOKEN={replace-with-your-personal-access-token}
```

## Choose your target architecture

By default, this Dockerfile targets arm64 since I tested it on a MacOS machine with M1 architecture. You may need to change architecture depending on the machine you want to run the runners from.

In `Dockerfile`, you may want to change the `TARGETARCH` value.

Ex.

```dockerfile
# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
```

## Cleanup and start all

This command will :

- cleanup existing agents images and their volumes
- build the runner docker image
- start the agents defined in `docker-compose.yml`

```shell
./fresh-start.sh
```

Check your agents in `https://dev.azure.com/{your-organisation-name}_settings/agentpools?poolId=1&view=agents`


The individuals steps are found below.

### Build the image

```shell
./build-image.sh
```

### (Optional) change the agent pool name

By default, the agents are created for the `Default` agent pool.

You can change it with the `AZP_POOL` in the `.env` file

```dotenv
AZP_POOL=Default
```

### (Optional) add of remove agents instances in docker-compose.yml

By default, 3 agents are defined in the `docker-compose.yml` file

Each of them has a volume mounted in an `agent*` directory.

If you want to add more agents, don't forget to change the volume for `/azp` mount point and the agent name in environment variable `AZP_AGENT_NAME`

```yml
services:
  agent1:
    image: dockeragent:latest
    volumes:
      - ./start.sh:/azp/start.sh
      # Change the directory for this agent
      - ./agent1/:/azp
    env_file:
      - .env
    environment:
      # Change the name of this agent
      - AZP_AGENT_NAME=agent1-docker
```

### Start the agents

```shell
./start-agents.sh
```

### Stop the agents

```shell
./stop-agents.sh
```

### Cleanup agents

Stops agents and removes volumes and data.

```shell
./cleanup-agents.sh
```

## Extend your runner image with new capabilities

You may need to run other tools than the already available ones.

To do so, add installation scripts into the `Dockerfile`.

You can take inspiration in the [official Microsoft hosted runners](https://github.com/actions/runner-images/tree/main).

For example in our case, we adapted the [php installer script](https://github.com/actions/runner-images/blob/main/images/linux/scripts/installers/php.sh) to make our own [install-php-8.1.sh](install-php-8.1.sh) 