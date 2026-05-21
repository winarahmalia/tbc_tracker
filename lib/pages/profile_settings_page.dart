import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String userId;

  const ProfileSettingsPage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.userId,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late String _name;
  late String _email;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _email = widget.initialEmail;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      if (mounted && profile != null) {
        setState(() {
          _name = profile.name;
          _email = profile.email;
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (_) {}
  }

  // ─── Dialog: Ubah Nama ──────────────────────────────────────────────────
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _name);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Nama Profil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 16),
          ),
          content: _buildCompactTextField(
            controller: controller,
            hint: 'Masukkan nama baru',
            icon: Icons.person_outline,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newName = controller.text.trim();
                          if (newName.isEmpty) {
                            _showErrorSnackBar('Nama tidak boleh kosong.');
                            return;
                          }
                          setDialogState(() => isLoading = true);
                          try {
                            await ProfileService.updateName(newName);
                            if (mounted) {
                              setState(() => _name = newName);
                              Navigator.pop(ctx);
                              _showSuccessSnackBar('Nama profil berhasil diperbarui!');
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ─── Dialog: Ubah Email ─────────────────────────────────────────────────
  void _showEditEmailDialog() {
    final emailController = TextEditingController(text: _email);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Email',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 16),
          ),
          content: _buildCompactTextField(
            controller: emailController,
            hint: 'Masukkan email baru',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newEmail = emailController.text.trim();

                          if (newEmail.isEmpty) {
                            _showErrorSnackBar('Email tidak boleh kosong.');
                            return;
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(newEmail)) {
                            _showErrorSnackBar('Format email tidak valid.');
                            return;
                          }

                          setDialogState(() => isLoading = true);
                          try {
                            await ProfileService.updateEmail(newEmail: newEmail);
                            if (mounted) {
                              setState(() => _email = newEmail);
                              Navigator.pop(ctx);
                              _showSuccessSnackBar('Email berhasil diperbarui!');
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ─── Dialog: Ubah Kata Sandi (langsung input password baru) ──────────────
  void _showEditPasswordDialog() {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Kata Sandi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332), fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompactTextField(
                  controller: newPassController,
                  hint: 'Kata sandi baru (min. 6 karakter)',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isNewPasswordVisible,
                  onToggle: () => setDialogState(
                      () => _isNewPasswordVisible = !_isNewPasswordVisible),
                ),
                const SizedBox(height: 10),
                _buildCompactTextField(
                  controller: confirmPassController,
                  hint: 'Konfirmasi kata sandi baru',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggle: () => setDialogState(
                      () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newPassword = newPassController.text;
                          final confirmPassword = confirmPassController.text;

                          if (newPassword.length < 6) {
                            _showErrorSnackBar('Password minimal 6 karakter!');
                            return;
                          }
                          if (newPassword != confirmPassword) {
                            _showErrorSnackBar('Konfirmasi kata sandi tidak cocok!');
                            return;
                          }

                          setDialogState(() => isLoading = true);
                          try {
                            await ProfileService.resetPasswordDirectly(newPassword);
                            if (mounted) {
                              Navigator.pop(ctx);
                              _showSuccessSnackBar('Kata sandi berhasil diubah!');
                            }
                          } catch (e) {
                            setDialogState(() => isLoading = false);
                            _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D37),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }



  // ─── Dialog: Ganti Foto ──────────────────────────────────────────────────
  void _showEditPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          const Text(
            "Ubah Foto Profil",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B4332)),
          ),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF006D37)),
            title: const Text("Ambil Foto"),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUploadImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: Color(0xFF006D37)),
            title: const Text("Pilih dari Galeri"),
            onTap: () {
              Navigator.pop(ctx);
              _pickAndUploadImage(ImageSource.gallery);
            },
          ),
          if (_avatarUrl != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Hapus Foto",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _removeAvatar();
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 512,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';

      final url = await ProfileService.uploadAvatarBytes(
        bytes: bytes,
        mimeType: mimeType,
      );
      if (mounted) {
        setState(() => _avatarUrl = url);
        _showSuccessSnackBar('Foto profil berhasil diperbarui!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal mengunggah foto: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUploadingAvatar = true);
    try {
      await ProfileService.removeAvatar();
      if (mounted) {
        setState(() => _avatarUrl = null);
        _showSuccessSnackBar("Foto profil dihapus.");
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar("Gagal menghapus foto.");
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        content: const Text(
          "Apakah kamu yakin ingin keluar dari akun ini?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Ya, Keluar",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF40916C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile Settings",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSectionLabel('AKUN'),
            const SizedBox(height: 8),
            _buildMenuGroup([
              _buildMenuTile(Icons.person_outline, 'Ubah Nama Profil',
                  onTap: _showEditNameDialog),
              _buildMenuTile(Icons.email_outlined, 'Ubah Email',
                  onTap: _showEditEmailDialog),
              _buildMenuTile(Icons.lock_outline, 'Ubah Kata Sandi',
                  onTap: _showEditPasswordDialog),
            ]),

            const SizedBox(height: 20),
            _buildCommunityCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFD1F2E1),
              backgroundImage:
                  _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _isUploadingAvatar
                  ? const CircularProgressIndicator(
                      color: Color(0xFF40916C), strokeWidth: 2)
                  : (_avatarUrl == null
                      ? const Icon(Icons.person,
                          size: 80, color: Color(0xFF1B4332))
                      : null),
            ),
            GestureDetector(
              onTap: _isUploadingAvatar ? null : _showEditPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFF40916C), shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _name,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332)),
        ),
        Text(
          _email,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        isDense: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(icon, color: const Color(0xFF006D37), size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
        suffixIcon: isPassword
            ? Padding(
                padding: EdgeInsets.zero,
                child: IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF0FFF6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF40916C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: Color(0xFFDDEEE6),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF006D37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF006D37), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF064E3B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "KOMUNITAS",
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Color(0xFFD1F2E1), shape: BoxShape.circle),
                    child: const Icon(Icons.group_outlined,
                        color: Color(0xFF40916C)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gabung Komunitas",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4332)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Terhubung dengan pejuang TBC lainnya untuk saling mendukung dalam perjalanan kesembuhan Anda.",
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _showSuccessSnackBar(
                      "Berhasil bergabung dengan komunitas!"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Gabung",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showLogoutDialog(context),
      icon: const Icon(Icons.logout, color: Colors.red, size: 18),
      label: const Text(
        "Keluar Akun",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}
