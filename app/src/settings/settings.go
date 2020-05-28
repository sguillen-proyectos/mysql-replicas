package settings

import "os"

type ApplicationSettings struct {
	MasterHostname string
	MasterPort     int
	MasterUsername string
	MasterPassword string
	SlaveHostname  string
	SlavePort      int
	SlaveUsername  string
	SlavePassword  string
	DatabaseName   string
}

func GetSettings() *ApplicationSettings {
	return &ApplicationSettings{
		MasterHostname: os.Getenv("DB_MASTER_HOSTNAME"),
		MasterPort:     3306,
		MasterUsername: os.Getenv("DB_MASTER_USERNAME"),
		MasterPassword: os.Getenv("DB_MASTER_PASSWORD"),
		SlaveHostname:  os.Getenv("DB_SLAVE_HOSTNAME"),
		SlavePort:      3306,
		SlaveUsername:  os.Getenv("DB_SLAVE_USERNAME"),
		SlavePassword:  os.Getenv("DB_SLAVE_PASSWORD"),
		DatabaseName:   os.Getenv("DB_NAME"),
	}
}
