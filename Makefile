host := 192.168.5.172
user := asteurer

setup:
	@ssh $(user)@$(host) 'bash -s' < setup.sh

ssh:
	@ssh $(user)@$(host)