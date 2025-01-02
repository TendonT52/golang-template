package migrate

import (
	"fmt"

	"github.com/spf13/cobra"

	"github.com/TendonT52/golang-template/app/repo"
)

var MigrateDownCmd = &cobra.Command{
	Use:   "down",
	Short: "run migrations down",
	Long:  `Revert the most recent migration.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		err := repo.GetMigrate().MigrateDown()
		if err != nil {
			return fmt.Errorf("migration failed: %w", err)
		}

		return nil
	},
}