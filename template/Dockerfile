# syntax=docker/dockerfile:1
#
# Example template: Claude Code on top of the "shell" template.
#
# We start from the official shell template (bash, git, gh, docker CLI,
# ripgrep, … already present, plus all of sbx's credential-proxy tooling) and
# install the Claude CLI on top. The neighbouring kit (../kit/spec.yaml)
# references the image built here and injects the Anthropic credentials at
# startup.
#
# Build:
#   docker build -t sbx-examples/claude-on-shell:latest template/
#
# Need Docker-in-Docker inside the sandbox? Start from
# `docker/sandbox-templates:shell-docker` instead and add, at the end of the
# file:
#   LABEL com.docker.sandboxes.start-docker="true"
FROM docker/sandbox-templates:shell

##########################################################################
# Install the Claude CLI                                                  #
# The official installer drops the binary in ~/.local/bin, which is       #
# already on the base template's PATH. We run it as the `agent` user (the  #
# shell template's current user) so the files are owned by the right uid.  #
##########################################################################
RUN set -ex; \
    curl -fsSL https://claude.ai/install.sh | bash

# Claude Code sources this file before every Bash command: that is how the
# agent's `export`s persist from one tool call to the next. The base template
# already created /etc/sandbox-persistent.sh.
ENV CLAUDE_ENV_FILE=/etc/sandbox-persistent.sh

# Pre-create the session-state directories the kit mounts as persistent
# volumes. Creating them here (owned by `agent`) prevents the OCI runtime from
# creating them as root at mount time. The kit re-owns them at startup anyway
# (block-volume mkfs trap), but this lays down a sane baseline in the image.
RUN set -ex; \
    mkdir -p \
      /home/agent/.claude/projects \
      /home/agent/.claude/sessions \
      /home/agent/.claude/todos \
      /home/agent/.claude/shell-snapshots \
      /home/agent/.claude/statsig
