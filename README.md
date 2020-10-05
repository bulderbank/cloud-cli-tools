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

##### Functions
Use the container as part of `bash` / `zsh` functions, see `./examples` folder.
To add a script from examples to your local environment, you'll need to edit your `.bashrc`/`.zshrc` file:

```
# ~/.zshrc

...

fpath=(~/.config/zsh/functions $fpath)  # Move functions from ./examples to this folder
autoload -Uz \
  func1 func2 func3  # Replace with actual function names

```

##### Versioning
Functions should be written so its possible to select which version of the container to run.
Set the `CLI_TOOLS_VERSION` environment variable in your shell to select a container version other than `latest`.
If `CLI_TOOLS_VERSION` is unset, the example functions will default to the `latest` tag.
Images build via GitHub Actions will receive this tag by default.
In other words, if you don't specify `CLI_TOOLS_VERSION`, you'll run the latest container image available in our GitHub packages container repository.

