#!/bin/bash

set -euo pipefail
FAILURE="failure"
SUCCESS="success"

function print_slack_summary_build() {
  local slack_msg_header
  local environment="${1}"
  local job_status="${2}"
  local commit_message="${3}"
  local slack_webhook_url="${4}"

  slack_msg_header=":x: *Build to ${environment} failed*"
  if [[ "${job_status}" == "${SUCCESS}" ]]; then
    slack_msg_header=":heavy_check_mark: *Build to ${environment} succeeded*"
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
                                "text": "*Workflow:*\n${GITHUB_WORKFLOW}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Author:*\n${GITHUB_ACTOR}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Branch/Tag:*\n${GITHUB_REF_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Message:*\n${commit_message}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Run URL:*\n${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
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
  local environment="${1}"
  local job_status="${2}"
  local commit_message="${3}"
  local slack_webhook_url="${4}"

  curl -X POST \
    --data-urlencode "payload=$(print_slack_summary_build "$environment" "$job_status" "$commit_message" "$slack_webhook_url")" \
    "${slack_webhook_url}"
}

# Call the function with inputs
share_slack_update_build "$INPUT_ENVIRONMENT" "$INPUT_JOB_STATUS" "$INPUT_COMMIT_MESSAGE" "$INPUT_SLACK_WEBHOOK_URL"
