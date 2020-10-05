# cloud-cli-tools

Docker image containing command-line tools that our cloud engineers use daily.

## Building

To build the image locally on your machine, use the following command:
```bash
./build.sh
```
Images built locally will only receive the `local` tag, you'll need to set `CLI_TOOLS_VERSION` to run this container with the included example functions.

## Usage
##### Downloading pre-built images
1. Create a [GitHub Personal Access Token (PAT)](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) with `read::packages` permission.
2. Run `./login.sh`, and provide your GitHub username and PAT when prompted.
3. Run `docker pull docker.pkg.github.com/bulderbank/cloud-cli-tools/cli-tools:latest`

