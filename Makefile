host := 192.168.5.155
user := asteurer

setup_fedora_server:
	@ssh $(user)@$(host) \
		"OP_SERVICE_ACCOUNT_TOKEN='$$(op item get dev_env_op_service_account_token --vault DEV)' bash -s" < setup_fedora_server.sh

setup_ubuntu_desktop:
	@./setup_ubuntu_desktop.sh

ssh:
	@ssh $(user)@$(host)