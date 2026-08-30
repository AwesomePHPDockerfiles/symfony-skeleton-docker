# symfony-skeleton-docker

```bash
# run this if you are building a traditional web application
composer create-project symfony/skeleton:"8.1.*" my_project_directory
cd my_project_directory
composer require webapp
```

```bash
# run this if you are building a microservice, console application or API
composer create-project symfony/skeleton:"8.1.*" my_project_directory
```

```bash
docker run --rm -v $(pwd):/app -w /app --user "$(id -u):$(id -g)" composer create-project laravel/laravel
```

```bash
docker run -it --rm -v .:/app -w /app --user "$(id -u):$(id -g)" testphp85 composer create-project symfony/skeleton:"8.1.*" ???<value>???
```
