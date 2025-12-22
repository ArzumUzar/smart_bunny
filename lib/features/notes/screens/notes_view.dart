import 'package:flutter/material.dart';
import '../../../models/note.dart';
import '../../../core/utils/colors.dart';

class NotesView extends StatefulWidget {
  final List<Note> notes;
  final Function(String) onDeleteNote;
  final Function(String, String) onUpdateNote;

  const NotesView({Key? key, required this.notes, required this.onDeleteNote, required this.onUpdateNote}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String? editingId;
  final TextEditingController _noteController = TextEditingController();

  void _startEdit(Note note) {
    setState(() {
      editingId = note.id;
      _noteController.text = note.note;
    });
  }

  void _saveEdit(String id) {
    widget.onUpdateNote(id, _noteController.text);
    setState(() {
      editingId = null;
      _noteController.clear();
    });
  }

  void _cancelEdit() {
    setState(() {
      editingId = null;
      _noteController.clear();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📝', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text('Henüz Not Yok', style: TextStyle(color: AppColors.purple700, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Quiz\'deki yanlış cevaplarını buraya ekleyerek çalışabilirsin', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
            SizedBox(height: 40),
            Text('🐰🥕', style: TextStyle(fontSize: 40)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notlarım', style: TextStyle(color: AppColors.purple700, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${widget.notes.length} kayıtlı soru', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
              const Spacer(),
              const Text('📚', style: TextStyle(fontSize: 30)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.notes.length,
            itemBuilder: (context, index) {
              final note = widget.notes[index];
              final isEditing = editingId == note.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(4)),
                                    child: Text(note.language.name, style: const TextStyle(color: AppColors.purple700, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.blue100, borderRadius: BorderRadius.circular(4)),
                                    child: Text(note.level.code, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(note.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            ],
                          ),
                        ),
                        if (!isEditing) ...[
                          IconButton(onPressed: () => _startEdit(note), icon: const Icon(Icons.edit, size: 18), color: AppColors.purple600, padding: const EdgeInsets.all(8), constraints: const BoxConstraints()),
                          IconButton(onPressed: () => widget.onDeleteNote(note.id), icon: const Icon(Icons.delete, size: 18), color: Colors.red, padding: const EdgeInsets.all(8), constraints: const BoxConstraints()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Senin Cevabın', style: TextStyle(fontSize: 10, color: Colors.black45)),
                                const SizedBox(height: 2),
                                Text('❌ ${note.userAnswer}', style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Doğru Cevap', style: TextStyle(fontSize: 10, color: Colors.black45)),
                                const SizedBox(height: 2),
                                Text('✓ ${note.correctAnswer}', style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('🥕 Kişisel Notun', style: TextStyle(fontSize: 10, color: Colors.black45)),
                    const SizedBox(height: 8),
                    if (isEditing)
                      Column(
                        children: [
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Buraya not ekle...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.purple100)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _saveEdit(note.id),
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(8)),
                                    child: const Center(child: Text('Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(onPressed: _cancelEdit, child: const Text('İptal')),
                            ],
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: () => _startEdit(note),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.purple50, borderRadius: BorderRadius.circular(8)),
                          child: Text(note.note.isEmpty ? 'Not eklemek için tıkla...' : note.note, style: TextStyle(fontSize: 14, color: note.note.isEmpty ? Colors.black38 : Colors.black87, fontStyle: note.note.isEmpty ? FontStyle.italic : FontStyle.normal)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🐰', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Her gün biraz daha öğren!', style: TextStyle(fontSize: 14, color: Colors.black54)),
              SizedBox(width: 8),
              Text('🥕', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}