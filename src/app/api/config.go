package api

import (
	"time"
)

type Config struct {
	Port     string `mapstructure:"port"`
	Host     string `mapstructure:"host"`
	LogLevel string `mapstructure:"log_level"`

	Cors struct {
		Enabled          bool          `mapstructure:"enabled"`
		AllowedOrigins   []string      `mapstructure:"allowed_origins"`
		AllowedMethods   []string      `mapstructure:"allowed_methods"`
		AllowedHeaders   []string      `mapstructure:"allowed_headers"`
		ExposedHeaders   []string      `mapstructure:"exposed_headers"`
		AllowCredentials bool          `mapstructure:"allow_credentials"`
		MaxAge           time.Duration `mapstructure:"max_age"`
	} `mapstructure:"cors"`

	Timeout struct {
		Read  time.Duration `mapstructure:"read"`
		Write time.Duration `mapstructure:"write"`
		Idle  time.Duration `mapstructure:"idle"`
	} `mapstructure:"timeout"`
}
