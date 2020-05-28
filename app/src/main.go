package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"donkeysharp.xyz/app-db-lb/dataaccess"
	"donkeysharp.xyz/app-db-lb/db"
	"donkeysharp.xyz/app-db-lb/settings"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"

	_ "github.com/go-sql-driver/mysql"
)

type FooRecord struct {
	Id      int
	Name    string
	Address string
}

var readDb, writeDb *sql.DB

func startDatabaseConnections() error {
	var err error
	log.Info("Gettting settings")
	appConfig := settings.GetSettings()

	writeDb, err = db.NewConnection(db.ConnectionSettings{
		Driver:       "mysql",
		Hostname:     appConfig.MasterHostname,
		Port:         appConfig.MasterPort,
		Username:     appConfig.MasterUsername,
		Password:     appConfig.MasterPassword,
		DatabaseName: appConfig.DatabaseName,
	})
	if err != nil {
		return err
	}

	readDb, err = db.NewConnection(db.ConnectionSettings{
		Driver:       "mysql",
		Hostname:     appConfig.SlaveHostname,
		Port:         appConfig.SlavePort,
		Username:     appConfig.SlaveUsername,
		Password:     appConfig.SlavePassword,
		DatabaseName: appConfig.DatabaseName,
	})
	if err != nil {
		return err
	}
	return nil
}

func main() {
	err := startDatabaseConnections()
	if err != nil {
		fmt.Printf("Error during Database connection\n")
		os.Exit(1)
	}

	e := echo.New()
	e.GET("/information", func(c echo.Context) error {
		ctx := c.Request().Context()
		fooDa := dataaccess.NewFooDataAccess(readDb)
		records, err := fooDa.GetRecords(ctx)
		if err != nil {
			log.Error(err)
			return c.JSON(http.StatusInternalServerError, err)
		}

		jsonBytes, err := json.Marshal(records)
		if err != nil {
			log.Error(err)
			return c.JSON(http.StatusInternalServerError, err)
		}

		return c.String(http.StatusOK, string(jsonBytes))
	})

	e.POST("/add-information", func(c echo.Context) error {
		ctx := c.Request().Context()
		fooDa := dataaccess.NewFooDataAccess(writeDb)
		fooRecord := &dataaccess.FooRecord{}
		result, err := fooDa.AddRecord(fooRecord, ctx)
		if err != nil {
			log.Error(err)
			return err
		}
		lastInsertedId, err := result.LastInsertId()
		if err != nil {
			log.Error(err)
			c.JSON(http.StatusInternalServerError, err)
		}

		return c.JSON(http.StatusOK, fmt.Sprintf("%d", lastInsertedId))
	})
	e.Logger.Fatal(e.Start(":8000"))
}
