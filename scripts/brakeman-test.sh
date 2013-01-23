# The only parameter entered by user is a directory containing
# the actual Rails application - probably doesn't work if
# it contains whitespaces or other special characters
TEST_DIR=$1

if [ "$TEST_DIR" == "" ]; then
  echo "Usage: $0 path-to-directory-with-the-rails-app project-id-or-name"
  exit 1
fi

# Project ID or name - has to be unique within projects tested
# on this node otherwise the HTML and JSON output would be mixed
PROJECT_ID=$2

if [ "$PROJECT_ID" == "" ]; then
  echo "Usage: $0 path-to-directory-with-the-rails-app project-id-or-name"
  exit 1
fi


# All file paths are relative to workspace (working directory)
PERSISTENT_DIR="__JENKINS_TEST__"
THIS_BUILD_DIR="${PERSISTENT_DIR}/${PROJECT_ID}/builds/${BUILD_NUMBER}"

LAST_REPORT_JSON="${PERSISTENT_DIR}/${PROJECT_ID}/last-brakeman-report.json"
LAST_REPORT_HTML="${PERSISTENT_DIR}/${PROJECT_ID}/last-brakeman-report.html"
LAST_CHANGES_JSON="${PERSISTENT_DIR}/${PROJECT_ID}/last-changes.json"

CURRENT_REPORT_HTML="${THIS_BUILD_DIR}/${PROJECT_ID}/brakeman-report.html"
CURRENT_REPORT_JSON="${THIS_BUILD_DIR}/${PROJECT_ID}/brakeman-report.json"
CURRENT_CHANGES_JSON="${THIS_BUILD_DIR}/${PROJECT_ID}/changes.json"

# Creates brakeman summary visible in build log
brakeman $TEST_DIR

# Creates output directory for the current build output
mkdir -p ${THIS_BUILD_DIR}

# Not a first run, there is a report already
if [ -e "${LAST_REPORT_JSON}" ]; then
  brakeman -q --compare ${LAST_REPORT_JSON} ${TEST_DIR} >${CURRENT_CHANGES_JSON}
fi

# Creates full list of issues both in HTML and JSON
brakeman \
  -o ${CURRENT_REPORT_HTML} \
  -o ${CURRENT_REPORT_JSON} \
  ${TEST_DIR}

# First run, full report are also the changes
if [ ! -e "${LAST_REPORT_JSON}" ]; then
  cp ${CURRENT_REPORT_JSON} ${CURRENT_CHANGES_JSON}
fi

# changes are copied to last-changes in the workspace root
cp ${CURRENT_CHANGES_JSON} ${LAST_CHANGES_JSON}

# report* files are copied to last-* in the workspace root
cp ${CURRENT_REPORT_HTML} ${LAST_REPORT_HTML}
# last-brakeman-report.json is used while comparing builds at the beginning of a next build
cp ${CURRENT_REPORT_JSON} ${LAST_REPORT_JSON}

