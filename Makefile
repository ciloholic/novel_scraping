SHELL := /bin/bash
.DEFAULT_GOAL := all

# ===============================================
# https://gist.github.com/tadashi-aikawa/da73d277a3c1ec6767ed48d1335900f3
# ===============================================
help: ## ヘルプ
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9][a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: $(shell egrep -oh ^[a-zA-Z0-9][a-zA-Z0-9_-]+: $(MAKEFILE_LIST) | sed 's/://')
# ===============================================

all:      ## ビルドから起動まで
	make build up ps
reset:    ## リセットからビルド、起動まで
	make down prune build up ps

prune:    ## 不要なDockerイメージを破棄
	docker system prune -f
ps:       ## 起動中のコンテナを表示
	docker compose ps
up:       ## コンテナを起動
	docker compose up -d
stop:     ## コンテナを停止
	docker compose stop
build:    ## コンテナをビルド
	docker compose build
down:     ## コンテナを破棄
	docker compose down --remove-orphans
downv:    ## コンテナとボリューム、ネットワークを破棄
	docker compose down -v --remove-orphans
restart:  ## コンテナを再起動
	docker compose restart
rubocop:  ## Rubocopを実行
	docker compose exec ruby bundle exec rubocop -A
rspec:  ## Rspecを実行
	docker compose exec ruby bundle exec rspec
login:    ## Railsコンテナへログイン
	docker compose exec ruby bash