-- Create the pgbench schema
CREATE SCHEMA pgbench;

-- Create the accounts table
CREATE TABLE pgbench.accounts (
    aid integer not null primary key,
    bid integer,
    abalance integer,
    filler char(84)
);

-- Create the branches table
CREATE TABLE pgbench.branches (
    bid integer not null primary key,
    bbalance integer,
    filler char(88)
);

-- Create the history table
CREATE TABLE pgbench.history (
    tid integer not null primary key,
    bid integer,
    aid integer,
    delta integer,
    mtime timestamp,
    filler char(22)
);

-- Create the tellers table
CREATE TABLE pgbench.tellers (
    tid integer not null primary key,
    bid integer,
    tbalance integer,
    filler char(84)
);

-- Create indexes on the accounts and branches tables
CREATE INDEX pgbench_accounts_bid ON pgbench.accounts (bid);
CREATE INDEX pgbench_branches_bid ON pgbench.branches (bid);