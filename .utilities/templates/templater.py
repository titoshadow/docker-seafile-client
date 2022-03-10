#!/usr/bin/env python3

# Docker Seafile client, help you mount a Seafile library as a volume.
# Copyright (C) 2019-2020, flow.gunso@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import re

from jinja2 import Template
import click

README_FILENAME = "README.md"
CHANGELOG_FILENAME = "CHANGELOG.md"
SEAFILE_TOPIC_POST_TEMPLATE_FILENAME = ".utilities/templates/seafile_topic_post.template"
DOCKER_HUB_DESCRIPTION_FILENAME = "docker_hub.description"
SEAFILE_FORUM_TOPIC_POST_DESCRIPTION_FILENAME = "seafile_forum_topic_post.description"


def translate_issues_references_into_urls(string):
    return re.sub(
        r' #([0-9]+)',
        r' [issue#\1](https://gitlab.com/flwgns-docker/seafile-client/-/issues/\1)',
        string)


def translate_markdown_links_of_repository_files_into_urls(string, ref):
    return re.sub(
        r'(\[.+\])\((?!.+:\/\/)(?!mailto:.+)(.+)\)',
        r'\1(https://gitlab.com/flwgns-docker/seafile-client/-/blob/{}/\2)'
            .format(ref),
        string)


@click.command()
@click.argument('ref', type=click.STRING)
def templater(ref):
    """CLI entrypoint the templater."""

    if len(ref) != 40:
        raise Exception("Commit reference must be 40 characters long (i.e. not the short ref)")

    # Extract text from the README.md, CHANGELOG.md and the Seafile forum topic post template files.
    with open(README_FILENAME, mode="rt") as fo:
        readme_text = fo.read()
    with open(CHANGELOG_FILENAME, mode="rt") as fo:
        changelog_text = fo.read()
    with open(SEAFILE_TOPIC_POST_TEMPLATE_FILENAME, mode="rt") as fo:
        seafile_topic_post_template_text = fo.read()

    # Generate the Docker Hub description by:
    # - translating Markdown links of repository files to reachable URLs
    docker_hub_description = translate_markdown_links_of_repository_files_into_urls(readme_text, ref)
    with open(DOCKER_HUB_DESCRIPTION_FILENAME, mode="wt") as fo:
        fo.write(docker_hub_description)

    # Generate the Seafile forum topic post description by:
    # - translating issues reference into reachable URLs
    # - templating the previous into the existing post
    seafile_topic_post_template = Template(seafile_topic_post_template_text)
    changlog_reachable_issue_urls = translate_issues_references_into_urls(changelog_text)
    seafile_topic_post_description = seafile_topic_post_template.render(changelog=changlog_reachable_issue_urls)
    with open(SEAFILE_FORUM_TOPIC_POST_DESCRIPTION_FILENAME, mode="wt") as fo:
        fo.write(seafile_topic_post_description)


if __name__ == "__main__":
    templater()
