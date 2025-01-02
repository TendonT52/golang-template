package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/TendonT52/golang-template/cmd/migrate"
	"github.com/TendonT52/golang-template/config"
)

var cfgFile string

var rootCmd = &cobra.Command{
	Use:   "lms",
	Short: "Loan Management System is all in one system for managing loans",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		if err := config.LoadConfig(cfgFile); err != nil {
			return fmt.Errorf("failed to load config: %w\n", err)
		}
		return nil
	},
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}

func init() {
	cobra.EnableTraverseRunHooks = true

	rootCmd.AddCommand(serveCmd)
	rootCmd.AddCommand(migrate.MigrationCmd)

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file path")
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
