# uxktn/t3-pipelines

To make this clear: I have no clue about docker. 

But: I was stressed out from waiting for my pipelines to finish, running apt-get commands in the pipeline was costing too much time. So, I googled it.

This docker image fulfils my personal needs for deployment of TYPO3 via gitlab-ci & bitbucket pipelines.  
Works for me, may work for you.

## Features

PHP 7.1 (See other branches/docker tags for 7.0 and 5.6)  
Composer 1.5.2  
TYPO3 Surf (dev-master) 
Deployer 
node 8.9.4  
npm 5.6.0
yarn 1.3.2  
grunt-cli 1.2.0  
bower 1.8.2  
Sass 3.5.3 (Bleeding Edge)

### PHP versions

`uxktn/t3-pipelines` or `uxktn/t3-pipelines:latest` (currently php 7.1)  
`uxktn/t3-pipelines:php71`  
`uxktn/t3-pipelines:php70`  
`uxktn/t3-pipelines:php56`  

### Example for bitbucket pipelines
```
image: uxktn/t3-pipelines

pipelines:
  branches:
    develop:
      - step:
          name: build frontend assets
          caches:
            - node
          script:
            - yarn --allow-root
            - grunt
          artifacts:
            - styleguide/**
            - packages/some_sitepackage/Resources/Public/**
      - step:
          name: build typo3 & deploy
          caches:
            - composer
          script:
            - ~/.composer/vendor/typo3/surf/surf deploy develop
```

### Example for gitlab-ci
```
image: uxktn/t3-pipelines

cache:
  untracked: true
  paths:
    - build/.sass-cache
    - build/node_modules
    - build/bower_components
    - vendor

stages:
  - build
  - deploy

build:
  stage: build
  script:
    - npm install
    - bower install --allow-root
    - grunt
  artifacts:
    expire_in: 60 minutes
    paths:
      - packages/some_sitepackage/Resources/Public
  only:
  - develop

deploy:
  stage: deploy
  dependencies:
    - build
  before_script:
    - eval $(ssh-agent -s)
    - ssh-add <(echo "$SSH_PRIVATE_KEY")
    - mkdir -p ~/.ssh
    - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
  script:
    - ~/.composer/vendor/typo3/surf/surf deploy develop
  only:
  - develop
```

### Docker hub
https://hub.docker.com/r/uxktn/t3-pipelines/

### Inspiration, blueprints, information while poking around in the dark
https://github.com/edbizarro/bitbucket-pipelines-php7  
https://confluence.atlassian.com/bitbucket/debug-your-pipelines-locally-with-docker-838273569.html  
https://unix.stackexchange.com/a/359801  
https://stackoverflow.com/a/38553499  

