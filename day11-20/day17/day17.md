1. Switch to the postgres system user

PostgreSQL usually runs under the postgres user. You need to log in as this user before running SQL commands:

`sudo -i -u postgres`

2. Log into PostgreSQL

Once inside the postgres user session:

`psql`
This drops you into the PostgreSQL shell.

3. Create the user with a password
Run:
`CREATE USER kodekloud_sam WITH PASSWORD 'YchZHRcLkL';`

4. Create the database

`CREATE DATABASE kodekloud_db4;`
5. Grant full privileges on the database to the user
`GRANT ALL PRIVILEGES ON DATABASE kodekloud_db4 TO kodekloud_sam;`

6. Verify
To confirm the user and database:

```
\du
\l
```

7. Exit PostgreSQL
`\q`

And exit back to your normal shell:

`exit`

