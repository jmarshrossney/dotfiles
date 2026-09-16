# ~/.config/direnv/lib/uv.sh
#
# NOTE: I took heavy inspiration from this blog post:
# https://offby1.website/posts/uv-direnv-and-simple-envrc-files.html

use_uv() {
  # Re-evaluate if these files change
  watch_file .env
  watch_file .envrc.local
  watch_file pyproject.toml
  watch_file uv.lock

  source_up_if_exists
  dotenv_if_exists
  source_env_if_exists .envrc.local

  if [ ! -d .venv ]; then uv venv; fi
  export VIRTUAL_ENV="$PWD/.venv"
  PATH_add "$VIRTUAL_ENV/bin"

  log_status "uv sync"
  uv sync
}
