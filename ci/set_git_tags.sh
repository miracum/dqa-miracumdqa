#!/bin/bash

# The syntax to get the newest tag from all branches is from https://gist.github.com/rponte/fdc0724dd984088606b0

CI_DEPLOYMENT_GIT_MAIL="forename.surname@hospital.org"
CI_DEPLOYMENT_GIT_NAME="Forename Surname"
CI_DEPLOYMENT_GIT_USR="username"
CI_DEPLOYMENT_GIT_PWD="ChangeMe"

# Remove old repos:
rm -rf dqatool_deployment
rm -rf DQAstats
rm -rf DQAgui
rm -rf miRacumDQA

# Pull copy of DQAstats:
git clone https://${CI_DEPLOYMENT_GIT_USR}:${CI_DEPLOYMENT_GIT_PWD}@gitlab.miracum.org/miracum/dqa/DQAstats.git
cd DQAstats
git describe --tags `git rev-list --tags --max-count=1`
DQAstats_tag=$(git describe --tags `git rev-list --tags --max-count=1`) # gets tags across all branches, not just the current branch
cd ..

# Pull copy of DQAgui:
git clone https://${CI_DEPLOYMENT_GIT_USR}:${CI_DEPLOYMENT_GIT_PWD}@gitlab.miracum.org/miracum/dqa/DQAgui.git
cd DQAgui
git describe --tags `git rev-list --tags --max-count=1`
DQAgui_tag=$(git describe --tags `git rev-list --tags --max-count=1`) # gets tags across all branches, not just the current branch
cd ..

# Pull copy of miRacumDQA:
git clone https://${CI_DEPLOYMENT_GIT_USR}:${CI_DEPLOYMENT_GIT_PWD}@gitlab.miracum.org/miracum/dqa/miRacumDQA.git
cd miRacumDQA
miRacumDQA_tag=$(git describe --tags `git rev-list --tags --max-count=1`) # gets tags across all branches, not just the current branch
miRacumDQA_tag_no_prefix=$(echo ${miRacumDQA_tag} | sed "s/v//") # Replaces every 'v' in the tag with a blank ''.
cd ..


echo DQAstats:
echo ${DQAstats_tag}
echo DQAgui:
echo ${DQAgui_tag}
echo miRacumDQA:
echo ${miRacumDQA_tag}
echo miRacumDQA_tag_no_prefix:
echo ${miRacumDQA_tag_no_prefix}



# Clone the dqatool_deployment repo here to update the version tags in it:
git clone https://${GITHUB_USER}:${K8S_SECRET_GITHUB_ACCESS_TOKEN}@gitlab.miracum.org/miracum/dqa/dqatool_deployment.git
cd dqatool_deployment

# Write the tags to the repo:
echo "#!/bin/bash

export DQASTATS_TAG=${DQAstats_tag}
export DQAGUI_TAG=${DQAgui_tag}
export MIRACUMDQA_TAG=${miRacumDQA_tag}
export DEPLOY_TAG=${miRacumDQA_tag_no_prefix}" > deployvars.sh

# TODO: Push changes to repo and trigger the build process:
git push

# Cleanup / Remove repos:
rm -rf dqatool_deployment
rm -rf DQAstats
rm -rf DQAgui
rm -rf miRacumDQA
rm -rf deployvars.sh