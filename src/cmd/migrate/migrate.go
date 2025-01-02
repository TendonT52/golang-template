package migrate

import (
	"github.com/spf13/cobra"

	"github.com/TendonT52/golang-template/app/db"
	"github.com/TendonT52/golang-template/config"
)

var MigrationCmd = &cobra.Command{
	Use:   "migrate",
	Short: "Use for database migrations",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		cfg := config.GetConfig()
		err := db.LoadMigrate(cfg.Database)
		if err != nil {
			return err
		}
		return nil
	},
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}

func init() {
	MigrationCmd.AddCommand(NewMigrationCmd)
	MigrationCmd.AddCommand(MigrateUpCmd)
	MigrationCmd.AddCommand(MigrateDownCmd)
}
