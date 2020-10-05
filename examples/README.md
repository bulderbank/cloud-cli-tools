# Functions
Use `cloud-cli-tools` containers as part of `bash` / `zsh` functions.
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

