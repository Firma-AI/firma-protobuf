import "./just/build.just"
import "./just/code_check.just"
import "./just/install.just"
import "./just/test.just"

# Pin dev-tool versions from a single source of truth (see tool-versions.env).
set dotenv-filename := "tool-versions.env"
set dotenv-load := true

# Lists all the available commands
default:
    @just --list
