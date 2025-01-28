#!/bin/bash

set -e

COMMITS_TO_EDIT=10

echo ">>> Starting backdating of last $COMMITS_TO_EDIT commits by 2 years"
echo ">>> When the editor opens, change all 'pick' to 'edit', then save and exit."
git rebase -i HEAD~$COMMITS_TO_EDIT

echo ">>> Press ENTER when ready to continue."
read

for i in $(seq 1 $COMMITS_TO_EDIT); do
    RAW_DATE=$(git log -1 --format=%aI)

    # Backdate by 2 years using Python
    BACKDATED=$(python3 -c "from datetime import datetime; from dateutil.relativedelta import relativedelta; print((datetime.strptime('$RAW_DATE', '%Y-%m-%dT%H:%M:%S%z') - relativedelta(years=2)).strftime('%Y-%m-%dT%H:%M:%S %z'))")

    echo ">>> Rewriting commit date: $RAW_DATE --> $BACKDATED"

    export GIT_AUTHOR_DATE="$BACKDATED"
    export GIT_COMMITTER_DATE="$BACKDATED"

    git commit --amend --no-edit
    git rebase --continue
done

echo ">>> Successfully rebased all commits."
echo ">>> Push your branch with: git push --force"
