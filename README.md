# Hasura, PostgreSQL, SQL Server, and Go API

## 1. Create docker network

First, create a custom Docker network to allow communication between containers:

`docker network create hasura-network`

## 2. Run PostgreSQL, SQL Server, and Hasura Containers

Run the PostgreSQL, SQL Server, and Hasura containers using the following commands:

`docker run -d --name postgres -e POSTGRES_USER=hasura -e POSTGRES_PASSWORD=hasura -e POSTGRES_DB=hasura -p 5432:5432 --network hasura-network postgres`

`docker run -d --name sql_server -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Admin_2024' -p 1433:1433 --network hasura-network mcr.microsoft.com/mssql/server`

`docker run -d --name hasura -p 8080:8080 -e HASURA_GRAPHQL_DATABASE_URL=postgres://hasura:hasura@host.docker.internal:5432/hasura -e HASURA_GRAPHQL_ENABLE_CONSOLE=true --network hasura-network hasura/graphql-engine`

## 3 Create the database

### 3.1 Log in

Using sqlcmd directly on your local machine:

`sqlcmd -S localhost,1433 -U sa -P Admin_2024 -C`

Or using Docker:
`docker exec -it sql_server /opt/mssql-tools18/bin/sqlcmd -S localhost,1433 -U sa -P Admin_2024 -C`

Also you can use a graphic envirioment such as Azure Data Studio or SQL Server Management Studio

### 3.1 Execute the query `DDL.sql`

You can verify the table status using:

```
USE abztract
GO
```
```
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO
```

## 4. Configure hasura

### Linking SQL Server Database

4.1 On your browser travel to http://localhost:8080/ or wherever Hasura is hosted, go to the **_Data_** page.

4.2 Click on **_Connect Database_**.

4.3 Select **_MS SQL Server_**(or a similar option) and click on **_Connect Existing Database_**.

4.4 Enter a **_Database name_** such as `"MSSQL_DB"`.

4.5 Select the **_Database URL_** option and type:

> DRIVER={ODBC Driver 17 for SQL Server};SERVER=host.docker.internal,1433;DATABASE=abztract;UID=sa;PWD=Admin_2024

4.6 Finally, click on **_Connect Database_** and it should connect.

## 5. Go API

The setup and configuration for the Go API is handled in a separate repository. Please follow the instructions in that repository to set up the Go API and link it to Hasura.

### [Go API Repository](https://github.com/Abztract-inventory/graphql-api)

This repository includes:

- Instructions to build and run the Go API Docker container.
- Steps to link the Go API as a Remote Schema in Hasura.

# Troubleshooting

## Manually Connect a Container to the Network

If any container is not connected to the `hasura-network`, you can manually connect it with:

`docker network connect hasura-network <container_name>`

## Issues with Container Communication

If a container cannot communicate with another container, ensure that all containers are connected to the same network (`hasura-network`). You can check available networks with:

`docker network ls`

To inspect a network and verify the container connections, use:

`docker network inspect hasura-network`
