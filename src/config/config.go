package config

import (
	"fmt"

	"github.com/spf13/viper"

	"github.com/TendonT52/golang-template/app/api"
	"github.com/TendonT52/golang-template/app/repo"
)

type Config struct {
	Server   api.Config  `mapstructure:"server"`
	Database repo.Config `mapstructure:"database"`
}

var cfg *Config

func LoadConfig(path string) error {
	if path == "" {
		return fmt.Errorf("config file path is empty")
	}

	viper.SetConfigFile(path)
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return fmt.Errorf("failed to read config file: %w", err)
	}

	cfg = &Config{}
	if err := viper.Unmarshal(cfg); err != nil {
		return fmt.Errorf("failed to unmarshal config: %w", err)
	}

	return nil
}

func GetConfig() Config {
	return *cfg
}
