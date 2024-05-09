package api

type NoteRequest struct {
	Title string `json:"title" binding:"required"`
	Body  string `json:"body" binding:"required"`
}

type NoteUpdateRequest struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}
