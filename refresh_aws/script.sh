#!/bin/zsh

export OP_VAULT_ID=yc3elswjhkyfuqjdkvssqvmula
export OP_TOKEN=$(op item get 1password_dev:read:write --vault $OP_VAULT_ID --fields label=credential --reveal)
export OP_ADMIN_ITEM_ID=jiupyjamrb3z7iaakv64k2xbeq
export OP_TEMP_ITEM_ID=3zv65ffdqw4sg2bkvadmsd4y7q
export AWS_REGION=us-west-2

/home/asteurer/Repositories/System/refresh_aws/main