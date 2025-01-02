package migrate

import (
	"fmt"

	"github.com/spf13/cobra"

	"github.com/TendonT52/golang-template/app/repo"
)

var MigrateUpCmd = &cobra.Command{
	Use:   "up",
	Short: "run migrations up",
	Long:  `All pending migrations will be applied.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		err := repo.GetMigrate().MigrateUp()
		if err != nil {
			return fmt.Errorf("migration failed: %w", err)
		}

		return nil
	},
}
