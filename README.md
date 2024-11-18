# Resume TeX sources

## Release steps

* clone me:

  ```shell
  git clone --recursive \
  git@github.com:raven428/tex-resume.git \
  tex-resume
  ```

* commit and push changes
* make tag and send to release:

  ```shell
    export VER=v000 && git checkout master && git pull
    git tag -fm master ${VER} && git push --force origin ${VER}
  ```

* go to [releases](../../releases) and publish the recent draft after finish
