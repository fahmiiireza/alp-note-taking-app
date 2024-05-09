package api

import (
	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	r.GET("/notes", getAllNote)
	r.GET("/notes/:id", getNote)
	r.POST("/notes", createNote)
	r.PATCH("/notes/:id", updateNote)
	r.DELETE("/notes/:id", deleteNote)

	return r
}
