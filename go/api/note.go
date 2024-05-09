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
	var noteRequest NoteRequest
	var note db.Note

	if err := c.BindJSON(&noteRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return

	}
	note = db.Note{
		Title: noteRequest.Title,
		Body:  noteRequest.Body,
	}

	if err := db.GetDB().Create(&note).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{
		"note": note,
	})
}

func updateNote(c *gin.Context) {
	// Update a note
	var noteRequest NoteUpdateRequest
	var note db.Note
	id := c.Param("id")

	if err := c.BindJSON(&noteRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return

	}
	result := db.GetDB().First(&note, id)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": result.Error.Error()})
		return
	}
	if err := db.GetDB().Model(&note).Updates(noteRequest).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

}

func deleteNote(c *gin.Context) {
	// Delete a note
	var note db.Note
	id := c.Param("id")
	result := db.GetDB().Delete(&note, id)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": result.Error.Error()})
		return
	}
	c.JSON(http.StatusNoContent, nil)
}
