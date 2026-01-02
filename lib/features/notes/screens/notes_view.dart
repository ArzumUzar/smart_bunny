import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/note.dart';
import '../../../core/utils/colors.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  List<Note> notes = [];
  bool isLoading = true;
  String? editingId;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotes(); // Sayfa açılınca notları çek
  }

  // NOTLARI SUPABASE'DEN ÇEK
  Future<void> _fetchNotes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // En yeni en üstte

      final List<dynamic> data = response;
      if (mounted) {
        setState(() {
          notes = data.map((json) => Note.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // NOT SİLME
  Future<void> _deleteNote(String id) async {
    // Önce listeyi güncelle (Hızlı tepki)
    setState(() {
      notes.removeWhere((n) => n.id == id);
    });

    // Sonra veritabanından sil
    try {
      await Supabase.instance.client.from('notes').delete().eq('id', id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silinemedi!")));
    }
  }

  // NOT GÜNCELLEME (Kişisel not ekleme)
  Future<void> _saveEdit(String id) async {
    // 1. Veritabanını güncelle
    try {
      await Supabase.instance.client.from('notes').update({
        'user_note': _noteController.text
      }).eq('id', id);
      
      // 2. Ekranı güncelle
      setState(() {
        final index = notes.indexWhere((n) => n.id == id);
        if (index != -1) notes[index].note = _noteController.text;
        editingId = null;
        _noteController.clear();
      });
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kaydedilemedi!")));
    }
  }

  void _startEdit(Note note) {
    setState(() {
      editingId = note.id;
      _noteController.text = note.note;
    });
  }

  void _cancelEdit() {
    setState(() {
      editingId = null;
      _noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
    }

    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📝', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text('Henüz Not Yok', style: TextStyle(color: AppColors.purple700, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Quiz\'deki yanlış cevaplarını\nburaya ekleyerek çalışabilirsin', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
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
                  Text('${notes.length} kayıtlı soru', style: const TextStyle(fontSize: 14, color: Colors.black54)),
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
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
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
                                    child: Text(note.language, style: const TextStyle(color: AppColors.purple700, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.blue100, borderRadius: BorderRadius.circular(4)),
                                    child: Text(note.level, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
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
                          IconButton(onPressed: () => _deleteNote(note.id), icon: const Icon(Icons.delete, size: 18), color: Colors.red, padding: const EdgeInsets.all(8), constraints: const BoxConstraints()),
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
      ],
    );
  }
}