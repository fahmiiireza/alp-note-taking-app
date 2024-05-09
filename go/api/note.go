package api

import (
	"net/http"

	"github.com/Man4ct/alp-note-taking-app/db"
	"github.com/gin-gonic/gin"
)

func getAllNote(c *gin.Context) {
	// Get all notes
	var notes []db.Note

	result := db.GetDB().Find(&notes)
	if result.Error != nil {

		c.JSON(http.StatusBadRequest, gin.H{"error": result.Error.Error()})
		return

	}
	c.JSON(http.StatusOK, gin.H{
		"notes": notes,
	})
}

func getNote(c *gin.Context) {
	// Get a note
	var note db.Note
	id := c.Param("id")
	result := db.GetDB().First(&note, id)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"note": note,
	})
}
func createNote(c *gin.Context) {
	// Create a note
}

func updateNote(c *gin.Context) {
	// Update a note
}

func deleteNote(c *gin.Context) {
	// Delete a note
}
