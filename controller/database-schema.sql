use foobar_db;

create table foo (
    id int not null auto_increment,
    name varchar(255) not null,
    address varchar(255) not null,
    primary key(id)
);
