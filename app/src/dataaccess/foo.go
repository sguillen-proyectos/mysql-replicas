package dataaccess

import (
	"context"
	"database/sql"
)

type FooDataAccess struct {
	db *sql.DB
}

type FooRecord struct {
	Id              int
	Name            string `json:"name"`
	Address         string `json:"address"`
	ReplicaHostname string `json:"replicaHostname"`
}

func NewFooDataAccess(db *sql.DB) *FooDataAccess {
	return &FooDataAccess{
		db: db,
	}
}

func (self *FooDataAccess) GetRecords(ctx context.Context) ([]FooRecord, error) {
	var records []FooRecord
	db := self.db

	query := "select id, name, address, @@hostname hostname from foo;"

	stmt, err := db.PrepareContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer stmt.Close()

	rows, err := stmt.QueryContext(ctx)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		record := FooRecord{}
		err := rows.Scan(&record.Id, &record.Name, &record.Address, &record.ReplicaHostname)
		if err != nil {
			return nil, err
		}
		records = append(records, record)

	}
	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return records, nil
}

func (self *FooDataAccess) AddRecord(record *FooRecord, ctx context.Context) (sql.Result, error) {
	db := self.db
	stmt, err := db.PrepareContext(ctx, "INSERT INTO foo(name, address) VALUES(?, ?)")
	if err != nil {
		return nil, err
	}
	defer stmt.Close()

	result, err := stmt.ExecContext(ctx, record.Name, record.Name)
	if err != nil {
		return nil, err
	}
	return result, err
}
