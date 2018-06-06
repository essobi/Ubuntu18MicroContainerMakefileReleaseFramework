###MarkdownHeader~~Words Under section go HEREERE!  I think some embedded Markdown too as long as it doesn't collide with the header.
###Owner~~You@You.com
###Synopis~~TLDR
###Operations~~How to Ops
###Description~~Desc goes here.
###Initial Deployment Pattern~~1st thing
###Sustained Operations~~Checkout, update, make all, make test, make run, checkin, submit PR, merge, push, publish
##AssetTag~~account@github.com username@heroku.com 0.0.1 AppNameOrSomeThing
##Comment~~Currently aimed at Heroku as a container provider but could be easily adapted to wherever you docker runs.

ENVDIR="./envs/"
LOGDIR="./logs/"
FNAME	 = NAME
FTAG 	 = TAG
FAPP 	 = APP
FTYPE 	 = TYPE
FRHOST 	 = RHOST
NAME 	:= $(shell cat ${ENVDIR}${FNAME})
CNAME 	:= $(shell cat ${ENVDIR}${FNAME} | tr '/' '_')
TAG 	:= $(shell cat ${ENVDIR}${FTAG})
APP 	:= $(shell cat ${ENVDIR}${FAPP})
TYPE 	:= $(shell cat ${ENVDIR}${FTYPE})
RHOST 	:= $(shell cat ${ENVDIR}${FRHOST})
IMG     := ${NAME}:${TAG}
LATEST  := ${NAME}:latest
DATE 	:= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
REG	:= $(RHOST)"/"${APP}"/"${TYPE}
TOKEN	:= $(shell heroku auth:token 2> /dev/null)

help: ## Displays help.
	@echo '------------------------------------------------- Help -------------------------------------------------'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'	

env: ## Display the current environment layout and map it to other formats.
	@echo "Name:\t\t"	$(NAME)
	@echo "Tag:\t\t"	$(TAG) 
	@echo "App:\t\t"	$(APP) 
	@echo "Type:\t\t"	$(TYPE)
	@echo "Reg Host:\t"	$(RHOST)
	@echo "Image:\t\t"	$(IMG) 
	@echo "Date:\t\t"	$(DATE)
	@echo "Reg Path:\t"	$(REG)

build: ## Build and tag while logging to ./logs/ the image NAME:latest and NAME:TAG on the default docker env.
	docker build  --build-arg VERSION="$(TAG)" --build-arg DATE="$(DATE)" -t "$(IMG)" -t "$(LATEST)" . | tee  $(LOGDIR)$(DATE)-$(CNAME)-$(APP)-docker-build.log

size: ## Check size of default env built images.
	docker image ls "$(IMG)"
	docker image ls "$(LATEST)"

test: ## Execute the container on the default docker env and test something.
	docker run --rm -it "$(IMG)"  md5sum /usr/bin/autossh | tee  $(LOGDIR)$(DATE)-$(CNAME)-$(APP)-docker-test.log

run: ## Connect bash to a throw away container on default env for $(IMG)
	docker run --rm -it "$(IMG)"

connect: ## Connect to the running remote docker instance on heroku with ps:exec
	heroku ps:exec -a $(APP)

publish: ## Publish $(IMG) to $(REG) at $(HOST)
	docker login --username=_ --password="$(TOKEN)" $(RHOST)
	docker tag  $(IMG) $(REG)
	docker push $(REG)

push: ## Heroku container:push $(TYPE)
	heroku container:push $(TYPE) -a $(APP)

release: ## Heroku container:release $(TYPE)
	heroku container:release $(TYPE)

open: ## Open the associated heroku app in a browser
	heroku open $(APP)

all : Dockerfile ## Build Dockerfile, test, Followup: Confirm tests, submit PR w/logs, merge, publish, push, release
	build test readme
	.PHONY : all

init: ## New Application init.  Only run after checkout and configuration, once.
	heroku create $(APP)

clean: ## Clean up local directory for strays.
	@rm *~ ##*


readme: Makefile ## Generates the readme.
	@echo "# Application Description" > README.md
	@echo '---' >> README.md
	@echo "## " $(NAME)-$(APP) >> README.md
	@echo '---' >> README.md
	@grep -E '^###.*' Makefile | awk 'BEGIN {FS = "~~"}; {printf "%s \n%s\n\n", $$1, $$2}' >> README.md
	@echo '---' >> README.md
	@echo '### Makefile functions.' >> README.md
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%s - Example: ```make %s```\n%s\n\n\n---\n", $$1, $$1, $$2}' >> README.md


