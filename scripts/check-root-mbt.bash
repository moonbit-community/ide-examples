# logging commands before executing them
set -o xtrace
# exit on error exclude `if` and `while` control flow
set -o errexit
# unbound variable checking
set -o nounset
# when any command in a pipeline fails, exit immediately
set -o pipefail

for file in *.mbt; do
    moon check "$file"
done