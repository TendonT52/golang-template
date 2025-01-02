package repo

import (
	"embed"
	"fmt"
	"net/url"

	"github.com/amacneil/dbmate/v2/pkg/dbmate"
	_ "github.com/amacneil/dbmate/v2/pkg/driver/postgres"
)

type Migrate struct {
	*dbmate.DB
}

//go:embed migrations/*.sql
var fs embed.FS

var migrate *Migrate

func LoadMigrate(conn Config) error {
	connStr, err := conn.connStr()
	if err != nil {
		return fmt.Errorf("cannot create new migrations: %w", err)
	}
	u, err := url.Parse(connStr)
	if err != nil {
		return fmt.Errorf("cannot parse connection string: %w", err)
	}
	db := dbmate.New(u)
	db.MigrationsDir = []string{"./app/repo/migrations"}
	db.FS = fs
	migrate = &Migrate{db}
	return nil
}

func GetMigrate() Migrate {
	return *migrate
}

func (m Migrate) MigrateUp() error {
	m.MigrationsDir = []string{"./migrations"}
	m.SchemaFile = "./app/repo/schema.sql"
	return migrate.CreateAndMigrate()
}

func (m Migrate) MigrateDown() error {
	m.MigrationsDir = []string{"./migrations"}
	m.SchemaFile = "./app/repo/schema.sql"
	return migrate.Rollback()
}
