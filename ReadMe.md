# uxktn/t3-pipelines

To make this clear: I have no clue about docker.

But: I was stressed out from waiting for my pipelines to finish, running apt-get commands in the pipeline was costing too much time. So, I googled it.

This docker image fulfils my personal needs for deployment of TYPO3 via gitlab-ci & bitbucket pipelines.
Works for me, may work for you.

## Features

PHP 7.3.17 (See other branches/docker tags for e.g. 7.2)  
Composer 1.10.6  
Surf 2.0.2  
Deployer  
node 10.20.1  
npm 6.14.4  
yarn 1.22.4  
grunt-cli 1.3.2  
bower 1.8.8  
(Ruby) Sass 3.7.4 (Bleeding Edge)  

### PHP versions

`uxktn/t3-pipelines` or `uxktn/t3-pipelines:latest` (currently php 7.3)  
`uxktn/t3-pipelines:php73`  
`uxktn/t3-pipelines:php72`  
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

