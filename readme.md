# Evaluation

Your project will be evaluated in two phases described below, the third one will be applied only for those who had
implemented the optional operations.

## First execution

This first execution is to ensure the project works exactly how was described in the exercise description.

The command to run it will be:

`mvn clean verify -Dkarate.auth.user=<your-user> -Dkarate.auth.pass=<your-password>`

## Second execution

There are some projects that have included all the endpoints in the basic security configuration so this second run it to
pass the basic auth for all the calls except the swagger-related ones

The command to run it will be:

`mvn clean verify -Dkarate.auth.user=<your-user> -Dkarate.auth.pass=<your-password> -Dkarate.auth.crud=true`

## Third execution

This run will be applied only for those who had implemented the optional stock operation

The command to run it will be:

`mvn clean verify -Dkarate.auth.user=<your-user> -Dkarate.auth.pass=<your-password> -Dkarate.auth.crud=true -Dkarate.stock=true`

# Parameter configuration

- In all cases `<your-user>` is the value of your basic auth username and `<your-password>` its password
- In case of your project is not running on localhost, you can change the host by adding the parameter
  `-Dkarate.host=<your-host>`. For example: `-Dkarate.host=https://your-other-host/route/etc`
- In case your project is running in a different port than the default `8080`, you can pass it as
  parameter with `-Dkarate.port=<your-port>`. For example: `-Dkarate.port=9999`
