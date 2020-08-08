LDFLAGS := -ldflags '-s'

.PHONY: all
all: build lint test

.PHONY: test
test:
	go test -v ./...

.PHONY: fix
fix:
	golangci-lint run --fix

.PHONY: lint
lint:
	golangci-lint run

.PHONY: wait
wait:
	dist/dbmate-linux-amd64 -e MYSQL_URL wait
	dist/dbmate-linux-amd64 -e POSTGRESQL_URL wait
	dist/dbmate-linux-amd64 -e CLICKHOUSE_URL wait

.PHONY: clean
clean:
	rm -rf dist/*

.PHONY: build
build: clean build-linux-amd64
	ls -lh dist

.PHONY: build-linux-amd64
build-linux-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
	     go build $(LDFLAGS) -o dist/dbmate-linux-amd64 .

.PHONY: build-all
build-all: clean build-linux-amd64
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
	     go build $(LDFLAGS) -o dist/dbmate-linux-musl-amd64 .
	GOOS=linux GOARCH=arm64 CGO_ENABLED=1 CC=aarch64-linux-gnu-gcc-5 CXX=aarch64-linux-gnu-g++-5 \
	     go build $(LDFLAGS) -o dist/dbmate-linux-arm64 .
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 CC=o64-clang CXX=o64-clang++ \
	     go build $(LDFLAGS) -o dist/dbmate-macos-amd64 .
	GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix \
	     go build $(LDFLAGS) -o dist/dbmate-windows-amd64.exe .
	ls -lh dist

.PHONY: docker-make
docker-make:
	docker-compose build
	docker-compose run --rm dbmate make

.PHONY: docker-bash
docker-bash:
	-docker-compose run --rm dbmate bash
