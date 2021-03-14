#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
echo "Generating site and upload it to git"
env HUGO_ENV="production" hugo -t github-style

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

echo "Push forked themes repository"
# Go To theme folder
cd ../themes/github-style
# Add changes to git.
git add .

# Commit changes.
msg="commit all changes in theme folder `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

echo "Push custom hugo templates reposirtory"
# Come Back up to the Project Root
cd ../..

# blog 저장소 Commit & Push
git add .

msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git push origin master