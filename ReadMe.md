# uxktn/t3-pipelines

To make this clear: I have no clue about docker.

But: I was stressed out from waiting for my pipelines to finish, running apt-get commands in the pipeline was costing too much time. So, I googled it.

This docker image fulfils my personal needs for deployment of TYPO3 via gitlab-ci & bitbucket pipelines.
Works for me, may work for you.

## Features

PHP 8.2.13 (cli)
Composer 2.6.5
Surf 3.4.6
Deployer 7.3.3
node 18.13.0
sass 1.69.5 compiled with dart2js 3.1.5
npm 9.2.0
yarn 1.22.21

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
