package db

import (
	"fmt"
	"net/url"
	"time"
)

type Config struct {
	// Connection
	Host     string `mapstructure:"host"`
	Port     string `mapstructure:"port"`
	DbName   string `mapstructure:"database_name"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	SSLMode  string `mapstructure:"sslmode"`

	// Connection Pool
	MaxOpenConns    int           `mapstructure:"max_open_conns"`
	MaxIdleConns    int           `mapstructure:"max_idle_conns"`
	ConnMaxLifetime time.Duration `mapstructure:"conn_max_lifetime"`
	ConnMaxIdleTime time.Duration `mapstructure:"conn_max_idle_time"`


	Timeout time.Duration `mapstructure:"timeout"`
}

func (c Config) connStr() (string, error) {
	if c.User == "" {
		return "", fmt.Errorf("cannot create connection string: user is empty")
	}
	if c.Password == "" {
		return "", fmt.Errorf("cannot create connection string: password is empty")
	}
	if c.Host == "" {
		return "", fmt.Errorf("cannot create connection string: host is empty")
	}
	if c.Port == "" {
		return "", fmt.Errorf("cannot create connection string: port is empty")
	}
	if c.DbName == "" {
		return "", fmt.Errorf("cannot create connection string: database name is empty")
	}
	u := &url.URL{
		Scheme: "postgres",
		User:   url.UserPassword(c.User, c.Password),
		Host:   fmt.Sprintf("%s:%s", c.Host, c.Port),
		Path:   c.DbName,
	}

	q := u.Query()
	if c.SSLMode != "" {
		q.Set("sslmode", c.SSLMode)
	}
	u.RawQuery = q.Encode()

	return u.String(), nil
}
