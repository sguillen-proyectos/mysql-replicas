package db

import (
	"database/sql"
	"fmt"

	"github.com/labstack/gommon/log"
)

type ConnectionSettings struct {
	Driver       string
	Hostname     string
	Port         int
	Username     string
	Password     string
	DatabaseName string
}

func makeConnectionString(settings ConnectionSettings) string {
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s",
		settings.Username,
		settings.Password,
		settings.Hostname,
		settings.Port,
		settings.DatabaseName,
	)
}

func NewConnection(settings ConnectionSettings) (*sql.DB, error) {
	connectionString := makeConnectionString(settings)
	log.Info(connectionString)
	db, err := sql.Open(settings.Driver, connectionString)
	return db, err
}
