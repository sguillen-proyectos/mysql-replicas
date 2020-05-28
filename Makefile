build:: build-controller build-loadbalancer build-app
	@echo "Building Docker image"
	docker build -t donkeysharp/mysql:latest .

build-loadbalancer:
	@echo "Building MySQL load balancer"
	$(MAKE) -C ./loadbalancer build

build-controller:
	@echo "Building Controller image"
	$(MAKE) -C ./controller build

build-app:
	@echo "Building test application image"
	$(MAKE) -C ./app build

start-tests:: build
	$(MAKE) -C ./tests start

stop-tests:
	$(MAKE) -C ./tests stop
