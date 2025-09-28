@rem ------------------- batch setting -------------------
@echo off

@rem ------------------- declare variable -------------------
if not defined PROJECT_ENV (set PROJECT_ENV=cli)

@rem ------------------- execute script -------------------
call :%*
goto end

@rem ------------------- declare function -------------------

:action-prepare
    echo ^> Startup and into container for develop algorithm
    @rem build image
    docker build -t %INFRA_DOCKER_IMAGE% ./conf/docker/%VAR_SRV_HOSTNAME%

    echo ^> Build virtual network
    set network_exist=1
    for /f "tokens=1" %%p in ('docker network ls --filter "name=%INFRA_DOCKER_NETWORK%" --format "{{.ID}}"') do (set network_exist=)
    if defined network_exist (docker network create %INFRA_DOCKER_NETWORK%)
    goto end

:action
    @rem declare variable
    set VAR_SRV_PORT=8080
    set VAR_SRV_HOSTNAME=%~n0
    set DOCKER_CONTAINER_NAME=%VAR_SRV_HOSTNAME%-%PROJECT_NAME%
    set INFRA_DOCKER_IMAGE=%VAR_SRV_HOSTNAME%:%PROJECT_NAME%
    set INFRA_DOCKER_NETWORK=benchmark-network
    set DC_ENV=%CLI_DIRECTORY%\cache\docker-compose-%VAR_SRV_HOSTNAME%.env
    set DC_CONF=%CLI_DIRECTORY%\conf\docker\docker-compose-%VAR_SRV_HOSTNAME%.yml

    @rem management container
    echo ^> Startup docker-compose environment file.
    @rem creaate cache folder
    IF not EXIST %CLI_DIRECTORY%\cache (mkdir %CLI_DIRECTORY%\cache)
    @rem create docker-compose env file
    IF EXIST !DC_ENV! (del !DC_ENV!)
    echo PROJECT_NAME=%PROJECT_NAME% > !DC_ENV!
    echo PROJECT_DIR=%CLI_DIRECTORY% >> !DC_ENV!
    echo SRV_HOSTNAME=%VAR_SRV_HOSTNAME% >> !DC_ENV!
    echo SRV_IMAGE_NAME=%INFRA_DOCKER_IMAGE%  >> !DC_ENV!
    echo SRV_CONTAINER_NAME=%DOCKER_CONTAINER_NAME% >> !DC_ENV!
    echo SRV_PORT=%VAR_SRV_PORT% >> !DC_ENV!
    echo INFRA_DOCKER_NETWORK=%INFRA_DOCKER_NETWORK% >> !DC_ENV!

    echo ^> Start project %PROJECT_NAME% develop server
    call :action-prepare

    if "%TARGET_PROJECT_COMMAND%"=="dev" (
        docker compose --file !DC_CONF! --env-file !DC_ENV! run server %TARGET_PROJECT_COMMAND%
    ) else (
        docker compose --file !DC_CONF! --env-file !DC_ENV! run server
    )
    goto end

:args
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="--into" (set TARGET_PROJECT_COMMAND=dev)
    goto end

:short
    echo Base docker container.
    goto end

:help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Use base docker container do FIO benchmark.
    echo.
    echo Options:
    echo      --help, -h        Show more information with '%~n0' command.
    echo      --into            Into container when it is at detach mode.
    echo      --stop            Stop container if dev-server was on work.
    call %CLI_SHELL_DIRECTORY%\utils\tools.bat command-description %~n0
    goto end

:end
