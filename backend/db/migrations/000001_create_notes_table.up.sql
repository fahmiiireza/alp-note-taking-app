-- migrate -path db/migrations -database "postgresql://fahmifahreza@localhost:5432/notes?sslmode=disable" -verbose up 

-- postgresql://fahmifahreza@localhost:5432/notes
-- postgres://fahmifahreza@localhost:5432/notes
CREATE TABLE "notes" (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    body TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);
