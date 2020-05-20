build:: build-controller build-loadbalancer
	@echo "Building Docker image"
	docker build -t donkeysharp/mysql:latest .

build-loadbalancer:
	@echo "Building MySQL load balancer"
	$(MAKE) -C ./loadbalancer build

build-controller:
	@echo "Building Controller image"
	$(MAKE) -C ./controller build

start-tests:: build
	$(MAKE) -C ./tests start

stop-tests:
	$(MAKE) -C ./tests stop
