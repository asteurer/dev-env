#!/bin/zsh

work_dir=~/repos/dev-env/refresh_aws

set -a
source $work_dir/passwords.env
set +a

go run $work_dir/main.go