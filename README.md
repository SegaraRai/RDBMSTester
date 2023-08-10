# How to start

```bash
$ pnpm i
$ docker build -t rdbms_test docker
$ docker run --rm -it --name rdbms_test -p 43306:3306 -p 45432:5432 rdbms_test
$ pnpm start
```
