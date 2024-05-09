package main

import (
	"fmt"

	"github.com/Man4ct/alp-note-taking-app/api"
	"github.com/Man4ct/alp-note-taking-app/db"
	"gorm.io/gorm"
)

type Repository struct {
	*gorm.DB
}

func main() {
	// Call the function
	// sayHello()

	db.ConnectDB()

	// Start the server
	r := api.SetupRouter()

	if err := r.Run(); err != nil {
		fmt.Println("Error starting server:", err)
	}
}
