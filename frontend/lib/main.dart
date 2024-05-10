import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<dynamic> notes = [];
  List<dynamic> selectedNotes = [];
  bool isSelectionMode = false;

  Future<void> fetchNotes() async {
    final response = await http.get(Uri.parse('http://localhost:8080/notes'));
    if (response.statusCode == 200) {
      setState(() {
        notes = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> deleteSelectedNotes() async {
    for (var note in selectedNotes) {
      final response = await http.delete(Uri.parse('http://localhost:8080/notes/${note['id']}'));
      if (response.statusCode == 204) {
        setState(() {
          notes.remove(note);
        });
      } else {
        throw Exception('Failed to delete note');
      }
    }
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List'),
        actions: [
          if (!isSelectionMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  isSelectionMode = true;
                  selectedNotes = List.from(notes);
                });
              },
            ),
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteSelectedNotes,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]['title']),
            subtitle: Text(notes[index]['body']),
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  if (selectedNotes.contains(notes[index])) {
                    selectedNotes.remove(notes[index]);
                  } else {
                    selectedNotes.add(notes[index]);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetail(
                      id: notes[index]['ID'],
                      note: notes[index],
                      refreshNotes: fetchNotes, // Pass the callback function
                    ),
                  ),
                );
              }
            },
            leading: isSelectionMode
                ? Checkbox(
                    value: selectedNotes.contains(notes[index]),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedNotes.add(notes[index]);
                        } else {
                          selectedNotes.remove(notes[index]);
                        }
                      });
                    },
                  )
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNote(
                refreshNotes: fetchNotes, // Pass the callback function
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteDetail extends StatelessWidget {
  final dynamic note;
  final int id;
  final Function refreshNotes;
  NoteDetail({required this.note, required this.id, required this.refreshNotes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateNoteScreen(
                    note: note,
                    id: note['ID'],
                    refreshNotes: refreshNotes, // Pass the callback function
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['title'],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(note['body']),
          ],
        ),
      ),
    );
  }
}

class UpdateNoteScreen extends StatefulWidget {
  final dynamic note;
  final int id;
  final Function refreshNotes;
  UpdateNoteScreen({required this.note, required this.id, required this.refreshNotes});

  @override
  _UpdateNoteScreenState createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['body']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final response = await http.patch(
                  Uri.parse('http://localhost:8080/notes/${widget.id}'),
                  body: jsonEncode({
                    'title': _titleController.text,
                    'body': _contentController.text,
                  }),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  widget.refreshNotes(); // Refresh notes after update
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to update note');
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNote extends StatefulWidget {
  final Function refreshNotes;
  AddNote({required this.refreshNotes});

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://localhost:8080/notes'),
                  body: jsonEncode({
                    'title': _titleController.text,
                    'body': _contentController.text,
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
                if (response.statusCode == 201) {
                  widget.refreshNotes(); // Refresh notes after adding
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to add note');
                }
              },
              child: Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
