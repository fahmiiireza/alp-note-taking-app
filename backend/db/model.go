package db

import "gorm.io/gorm"

type Note struct {
	gorm.Model

	Title string `json:"title"`
	Body  string `json:"body"`
}
