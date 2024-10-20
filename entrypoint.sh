#!/bin/bash

set -euo pipefail
FAILURE=1
SUCCESS=0

function print_slack_summary_build() {
  local slack_msg_header
  local slack_msg_body
  local slack_channel
  # Populate header and define slack channels
  slack_msg_header=":x: *Build to ${ENVIRONMENT} failed*"
  if [[ "${EXIT_STATUS}" == "${SUCCESS}" ]]; then
    slack_msg_header=":heavy_check_mark: *Build to ${ENVIRONMENT} succeeded*"
  fi
  cat <<-SLACK
            {
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "${slack_msg_header}"
                        }
                    },
                    {
                        "type": "divider"
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": "*Job:*\n${GITHUB_WORKFLOW}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Pushed By:*\n${GITHUB_ACTOR}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Branch:*\n${GITHUB_REF_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Message:*\n${GITHUB_COMMIT_MESSAGE}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Job URL:*\n${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit URL:*\n${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
                            },
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ]
}
SLACK
}

function share_slack_update_build() {
  curl -X POST \
    --data-urlencode "payload=$(print_slack_summary_build)" \
    "${SLACK_WEBHOOK_URL}"
}