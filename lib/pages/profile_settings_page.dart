import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import 'login_page.dart';
import 'schedule_setup_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  const ProfileSettingsPage({super.key, required this.initialName, required this.initialEmail});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late String _name;
  late String _email;
  
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _email = widget.initialEmail;
  }

  void _showEditNameDialog() {
    final TextEditingController controller = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Ubah Nama Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              label: "Nama Baru",
              hintText: "Masukkan nama baru",
              prefixIcon: Icons.person_outline,
              controller: controller,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _name = controller.text;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama profil berhasil diperbarui!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final TextEditingController controller = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Ubah Email",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              label: "Email Baru",
              hintText: "Masukkan email baru",
              prefixIcon: Icons.email_outlined,
              controller: controller,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _email = controller.text;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email berhasil diperbarui!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPasswordDialog() {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Ubah Kata Sandi",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: "Kata Sandi Lama",
                  hintText: "••••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: oldPassController,
                  isPassword: true,
                  isVisible: _isOldPasswordVisible,
                  onToggleVisibility: () => setStateDialog(() => _isOldPasswordVisible = !_isOldPasswordVisible),
                ),
                const SizedBox(height: 15),
                CustomInput(
                  label: "Kata Sandi Baru",
                  hintText: "••••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: newPassController,
                  isPassword: true,
                  isVisible: _isNewPasswordVisible,
                  onToggleVisibility: () => setStateDialog(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                ),
                const SizedBox(height: 15),
                CustomInput(
                  label: "Konfirmasi Kata Sandi Baru",
                  hintText: "••••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: confirmPassController,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () => setStateDialog(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassController.text.isNotEmpty && 
                    newPassController.text == confirmPassController.text) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Kata sandi berhasil diubah!")),
                  );
                } else if (newPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildMenuItem(Icons.person_outline, "Ubah Nama Profil", onTap: _showEditNameDialog),
            _buildMenuItem(Icons.email_outlined, "Ubah Email", onTap: _showEditEmailDialog),
            _buildMenuItem(Icons.lock_outline, "Ubah Kata Sandi", onTap: _showEditPasswordDialog),
            _buildMenuItem(Icons.edit_calendar_outlined, "Atur Ulang Jadwal / Ganti Obat", onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text(
                    "Edit Jadwal?",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                  ),
                  content: const Text(
                    "Apakah kamu yakin ingin mengubah jadwal minum obat?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Ya, Edit", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleSetupPage()),
              );
              if (result != null) {
                Navigator.pop(context, result);
              }
            }),
            const SizedBox(height: 40),
            _buildCommunityCard(),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4332)),
          ),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF006D37)),
            title: const Text("Ambil Foto"),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur kamera akan segera hadir!")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF006D37)),
            title: const Text("Pilih dari Galeri"),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur galeri akan segera hadir!")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Hapus Foto", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Foto profil dihapus!")),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFD1F2E1),
              child: Icon(Icons.person, size: 80, color: Color(0xFF1B4332)),
            ),
            GestureDetector(
              onTap: _showEditPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF40916C), shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        Text(
          _email,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71).withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF006D37), size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFD1F2E1), shape: BoxShape.circle),
                    child: const Icon(Icons.group_outlined, color: Color(0xFF40916C)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gabung Komunitas",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Terhubung dengan pejuang TBC lainnya untuk saling mendukung dalam perjalanan kesembuhan Anda.",
                          style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil bergabung dengan komunitas!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Gabung",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
