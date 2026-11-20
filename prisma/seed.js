import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Pre-computed Bcrypt hashes for demo accounts (rounds = 12)
const HASHED_PASSWORDS = {
  admin123: '$2b$12$WXb5/UGH3527bTTvE.WHAesGpiqYw4kvtHgtquFm041YVMPUHxo.K',
  staff123: '$2b$12$dw.gsAIPkKJVkXp2jbA/OOpLV9O2yB7EVtRaQWKJ4IcRVi6N3pS3q',
  teacher123: '$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK',
  student123: '$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6',
  parent123: '$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6',
};

// Realistic Vietnamese name generation dictionaries
const FAMILY_NAMES = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý'];
const MID_MALE = ['Văn', 'Hữu', 'Đức', 'Minh', 'Hoàng', 'Quốc', 'Thanh', 'Đình', 'Xuân', 'Hải', 'Tuấn', 'Tiến', 'Bảo', 'Gia'];
const MID_FEMALE = ['Thị', 'Ngọc', 'Thu', 'Phương', 'Thanh', 'Bích', 'Hải', 'Mai', 'Khánh', 'Diễm', 'Quỳnh', 'Mỹ', 'Thùy'];
const FIRST_MALE = ['An', 'Bình', 'Cường', 'Dũng', 'Đạt', 'Hải', 'Hiếu', 'Hùng', 'Huy', 'Khoa', 'Long', 'Minh', 'Nam', 'Nghĩa', 'Phúc', 'Quân', 'Sơn', 'Thắng', 'Thịnh', 'Trung', 'Tuấn', 'Việt'];
const FIRST_FEMALE = ['Anh', 'Chi', 'Dung', 'Hà', 'Hân', 'Hằng', 'Hoa', 'Hương', 'Lan', 'Linh', 'Mai', 'My', 'Ngân', 'Ngọc', 'Nhi', 'Phương', 'Quyên', 'Quỳnh', 'Thảo', 'Trang', 'Trâm', 'Vy', 'Yến'];

const DISTRICTS = [
  'Quận 1, TP. Hồ Chí Minh',
  'Quận 3, TP. Hồ Chí Minh',
  'Quận 5, TP. Hồ Chí Minh',
  'Quận 7, TP. Hồ Chí Minh',
  'Quận 10, TP. Hồ Chí Minh',
  'Quận Bình Thạnh, TP. Hồ Chí Minh',
  'Quận Phú Nhuận, TP. Hồ Chí Minh',
  'Quận Tân Bình, TP. Hồ Chí Minh',
  'Quận Gò Vấp, TP. Hồ Chí Minh',
  'TP. Thủ Đức, TP. Hồ Chí Minh',
];

const TEACHER_SPECS = [
  { spec: 'IELTS 8.0 & Academic Writing', degree: 'Master of Applied Linguistics' },
  { spec: 'TOEIC & Business English', degree: 'BA English Language Teaching' },
  { spec: 'IELTS Speaking & Native Intonation', degree: 'M.Ed TESOL (Australia)' },
  { spec: 'Phonics & Basic Communication', degree: 'Cambridge CELTA' },
  { spec: 'TOEIC Listening & Test Strategies', degree: 'IELTS 8.5, TOEIC 990' },
  { spec: 'Junior English & SAT Foundation', degree: 'MA in Linguistics' },
  { spec: 'Debate & Advanced Communication', degree: 'TESOL Certificate' },
  { spec: 'Academic English & Research Skills', degree: 'PhD in Education' },
  { spec: 'Grammar in Use & Pronunciation', degree: 'BA in Linguistics' },
  { spec: 'Corporate Communication & Negotiations', degree: 'MBA & TESOL' },
];

function generateVietnameseName(index, isFemale = false) {
  const fam = FAMILY_NAMES[index % FAMILY_NAMES.length];
  if (isFemale) {
    const mid = MID_FEMALE[Math.floor(index / 2) % MID_FEMALE.length];
    const first = FIRST_FEMALE[index % FIRST_FEMALE.length];
    return `${fam} ${mid} ${first}`;
  } else {
    const mid = MID_MALE[Math.floor(index / 2) % MID_MALE.length];
    const first = FIRST_MALE[index % FIRST_MALE.length];
    return `${fam} ${mid} ${first}`;
  }
}

// Helper to batch run promises to avoid overloading connection pool
async function batchProcess(items, batchSize, fn) {
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    await Promise.all(batch.map(fn));
  }
}

async function seedUsersAndProfiles() {
  console.log('🌱 [1/9] Seeding Users (NGUOI_DUNG)...');
  console.log('   -> ADMIN: Exactly 1 account');
  console.log('   -> ACADEMIC_STAFF: Exactly 1 account');
  console.log('   -> TEACHER: Exactly 40 accounts (Range: 30–50)');
  console.log('   -> STUDENT: Exactly 350 accounts (Range: 300–500)');
  console.log('   -> PARENT: Exactly 180 accounts (Range: 150–250)');

  // 1. Core Users (Admin, Staff, Teachers, Students, Parents)
  const userDataList = [
    // --- EXACTLY 1 ADMIN ---
    {
      TenDangNhap: 'admin',
      Email: 'admin@center.edu.vn',
      HoTen: 'Nguyễn Văn Quản Trị (Admin)',
      MatKhau: HASHED_PASSWORDS.admin123,
      VaiTro: 'ADMIN',
      SoDienThoai: '0901234567',
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    },
    // --- EXACTLY 1 ACADEMIC_STAFF ---
    {
      TenDangNhap: 'staff',
      Email: 'staff@center.edu.vn',
      HoTen: 'Trần Thị Học Vụ (Staff)',
      MatKhau: HASHED_PASSWORDS.staff123,
      VaiTro: 'ACADEMIC_STAFF',
      SoDienThoai: '0912345678',
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    },
  ];

  // --- 40 TEACHERS (7 existing + 33 generated) ---
  const existingTeachers = [
    { username: 'teacher', email: 'teacher@center.edu.vn', name: 'ThS. Lê Hoàng Nam (Teacher)', phone: '0923456789' },
    { username: 'teacher2', email: 'teacher2@center.edu.vn', name: 'ThS. Nguyễn Thị Mai', phone: '0923456790' },
    { username: 'teacher_david', email: 'david.wilson@center.edu.vn', name: 'David Wilson, M.Ed', phone: '0923456791' },
    { username: 'teacher_my', email: 'nguyen.thaomy@center.edu.vn', name: 'Trần Diễm My, CELTA', phone: '0923456792' },
    { username: 'teacher_bao', email: 'hoang.quocbao@center.edu.vn', name: 'Đỗ Gia Bảo, IELTS 8.5', phone: '0923456795' },
    { username: 'teacher_phuong', email: 'vu.bichphuong@center.edu.vn', name: 'Hoàng Minh Phương, MA', phone: '0923456794' },
    { username: 'teacher_an', email: 'dang.hoaian@center.edu.vn', name: 'Vũ Quốc An, TESOL', phone: '0923456793' },
  ];

  for (const t of existingTeachers) {
    userDataList.push({
      TenDangNhap: t.username,
      Email: t.email,
      HoTen: t.name,
      MatKhau: HASHED_PASSWORDS.teacher123,
      VaiTro: 'TEACHER',
      SoDienThoai: t.phone,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  for (let i = 8; i <= 40; i++) {
    const pad = String(i).padStart(2, '0');
    const isFemale = i % 2 === 0;
    const name = generateVietnameseName(i, isFemale);
    userDataList.push({
      TenDangNhap: `teacher_${pad}`,
      Email: `teacher_${pad}@center.edu.vn`,
      HoTen: `ThS. ${name}`,
      MatKhau: HASHED_PASSWORDS.teacher123,
      VaiTro: 'TEACHER',
      SoDienThoai: `09230000${pad}`,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  // --- 350 STUDENTS (10 existing + 340 generated) ---
  const existingStudents = [
    { username: 'student', email: 'student@center.edu.vn', name: 'Phạm Minh Khang (Student)', phone: '0934567890' },
    { username: 'student_tuan', email: 'student_tuan@center.edu.vn', name: 'Hoàng Anh Tuấn', phone: '0934567891' },
    { username: 'student_chau', email: 'student_chau@center.edu.vn', name: 'Nguyễn Bảo Châu', phone: '0934567892' },
    { username: 'student_phuc', email: 'student_phuc@center.edu.vn', name: 'Võ Minh Phúc', phone: '0934567893' },
    { username: 'student_linh', email: 'student_linh@center.edu.vn', name: 'Lê Thùy Linh', phone: '0934567894' },
    { username: 'student_dung', email: 'student_dung@center.edu.vn', name: 'Đặng Tiến Dũng', phone: '0934567895' },
    { username: 'student_anh', email: 'student_anh@center.edu.vn', name: 'Trần Tuấn Anh', phone: '0934567896' },
    { username: 'student_huy', email: 'student_huy@center.edu.vn', name: 'Nguyễn Đức Huy', phone: '0934567897' },
    { username: 'student_ngoc', email: 'student_ngoc@center.edu.vn', name: 'Trần Bích Ngọc', phone: '0934567898' },
    { username: 'student_nam', email: 'student_nam@center.edu.vn', name: 'Lê Hoàng Nam', phone: '0934567899' },
  ];

  for (const s of existingStudents) {
    userDataList.push({
      TenDangNhap: s.username,
      Email: s.email,
      HoTen: s.name,
      MatKhau: HASHED_PASSWORDS.student123,
      VaiTro: 'STUDENT',
      SoDienThoai: s.phone,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  for (let i = 11; i <= 350; i++) {
    const pad = String(i).padStart(4, '0');
    const isFemale = i % 2 === 1;
    const name = generateVietnameseName(i + 50, isFemale);
    userDataList.push({
      TenDangNhap: `student_${pad}`,
      Email: `student_${pad}@center.edu.vn`,
      HoTen: name,
      MatKhau: HASHED_PASSWORDS.student123,
      VaiTro: 'STUDENT',
      SoDienThoai: `0934${String(i).padStart(6, '0')}`,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  // --- 180 PARENTS (6 existing + 174 generated) ---
  const existingParents = [
    { username: 'parent', email: 'parent@center.edu.vn', name: 'Phạm Quốc Hùng (Parent)', phone: '0945678901' },
    { username: 'parent_huong', email: 'parent_huong@center.edu.vn', name: 'Nguyễn Thu Hương', phone: '0945678902' },
    { username: 'parent_trong', email: 'parent_trong@center.edu.vn', name: 'Trần Đức Trọng', phone: '0945678903' },
    { username: 'parent_nam', email: 'parent_nam@center.edu.vn', name: 'Võ Văn Nam', phone: '0945678904' },
    { username: 'parent_ha', email: 'parent_ha@center.edu.vn', name: 'Lê Thanh Hà', phone: '0945678905' },
    { username: 'parent_lien', email: 'parent_lien@center.edu.vn', name: 'Trần Thị Kim Liên', phone: '0945678906' },
  ];

  for (const p of existingParents) {
    userDataList.push({
      TenDangNhap: p.username,
      Email: p.email,
      HoTen: p.name,
      MatKhau: HASHED_PASSWORDS.parent123,
      VaiTro: 'PARENT',
      SoDienThoai: p.phone,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  for (let i = 7; i <= 180; i++) {
    const pad = String(i).padStart(3, '0');
    const isFemale = i % 2 === 0;
    const name = generateVietnameseName(i + 500, isFemale);
    userDataList.push({
      TenDangNhap: `parent_${pad}`,
      Email: `parent_${pad}@center.edu.vn`,
      HoTen: `${name} (PH)`,
      MatKhau: HASHED_PASSWORDS.parent123,
      VaiTro: 'PARENT',
      SoDienThoai: `0945${String(i).padStart(6, '0')}`,
      TrangThai: true,
      SoLanDangNhapSai: 0,
      DaXoa: false,
    });
  }

  // Upsert all users in batches
  const userMap = {};
  await batchProcess(userDataList, 50, async (u) => {
    const user = await prisma.nGUOI_DUNG.upsert({
      where: { TenDangNhap: u.TenDangNhap },
      update: {
        Email: u.Email,
        HoTen: u.HoTen,
        MatKhau: u.MatKhau,
        VaiTro: u.VaiTro,
        SoDienThoai: u.SoDienThoai,
        TrangThai: u.TrangThai,
        DaXoa: false,
      },
      create: u,
    });
    userMap[u.TenDangNhap] = user;
  });

  console.log('🌱 [2/9] Seeding Profiles (GIANG_VIEN, HOC_VIEN, PHU_HUYNH)...');

  // --- TEACHER PROFILES (40) ---
  const teacherProfiles = [
    { username: 'teacher', code: 'GV2026-001', spec: 'IELTS 8.0 & Academic Writing', degree: 'Master of Applied Linguistics' },
    { username: 'teacher2', code: 'GV2026-002', spec: 'TOEIC & Business English', degree: 'BA English Language Teaching' },
    { username: 'teacher_david', code: 'GV2026-003', spec: 'IELTS Speaking & Native Intonation', degree: 'M.Ed TESOL (Australia)' },
    { username: 'teacher_my', code: 'GV2026-004', spec: 'Phonics & Basic Communication', degree: 'Cambridge CELTA' },
    { username: 'teacher_bao', code: 'GV2026-005', spec: 'TOEIC Listening & Test Strategies', degree: 'IELTS 8.5, TOEIC 990' },
    { username: 'teacher_phuong', code: 'GV2026-006', spec: 'Junior English & SAT Foundation', degree: 'MA in Linguistics' },
    { username: 'teacher_an', code: 'GV2026-007', spec: 'Debate & Advanced Communication', degree: 'TESOL Certificate' },
  ];

  for (let i = 8; i <= 40; i++) {
    const pad = String(i).padStart(2, '0');
    const specInfo = TEACHER_SPECS[i % TEACHER_SPECS.length];
    teacherProfiles.push({
      username: `teacher_${pad}`,
      code: `GV2026-${String(i).padStart(3, '0')}`,
      spec: specInfo.spec,
      degree: specInfo.degree,
    });
  }

  const teacherMap = {};
  await batchProcess(teacherProfiles, 30, async (tp) => {
    const u = userMap[tp.username];
    const teacher = await prisma.gIANG_VIEN.upsert({
      where: { MaSoGiangVien: tp.code },
      update: {
        ChuyenMon: tp.spec,
        HocVi: tp.degree,
        TrangThai: 'ACTIVE',
        DaXoa: false,
      },
      create: {
        MaNguoiDung: u.MaNguoiDung,
        MaSoGiangVien: tp.code,
        ChuyenMon: tp.spec,
        HocVi: tp.degree,
        TrangThai: 'ACTIVE',
        DaXoa: false,
      },
    });
    teacherMap[tp.username] = teacher;
  });

  // --- STUDENT PROFILES (350) ---
  const studentProfiles = [
    { username: 'student', code: '26-04001', dob: new Date('2004-05-15'), address: 'Quận 1, TP. Hồ Chí Minh' },
    { username: 'student_tuan', code: '26-04002', dob: new Date('2002-09-05'), address: 'Quận Phú Nhuận, TP. Hồ Chí Minh' },
    { username: 'student_chau', code: '26-04003', dob: new Date('2005-08-20'), address: 'Quận 3, TP. Hồ Chí Minh' },
    { username: 'student_phuc', code: '26-04004', dob: new Date('2005-01-12'), address: 'TP. Thủ Đức, TP. Hồ Chí Minh' },
    { username: 'student_linh', code: '26-04005', dob: new Date('2004-02-28'), address: 'Quận 7, TP. Hồ Chí Minh' },
    { username: 'student_dung', code: '26-04006', dob: new Date('2003-07-22'), address: 'Quận 10, TP. Hồ Chí Minh' },
    { username: 'student_anh', code: '26-04007', dob: new Date('2003-11-10'), address: 'Quận Bình Thạnh, TP. Hồ Chí Minh' },
    { username: 'student_huy', code: '26-04008', dob: new Date('2004-04-18'), address: 'Quận Tân Bình, TP. Hồ Chí Minh' },
    { username: 'student_ngoc', code: '26-04009', dob: new Date('2005-12-03'), address: 'Quận 5, TP. Hồ Chí Minh' },
    { username: 'student_nam', code: '26-04010', dob: new Date('2003-03-25'), address: 'Quận Gò Vấp, TP. Hồ Chí Minh' },
  ];

  for (let i = 11; i <= 350; i++) {
    const pad = String(i).padStart(4, '0');
    const birthYear = 2000 + (i % 10);
    const birthMonth = (i % 12) + 1;
    const birthDay = (i % 28) + 1;
    studentProfiles.push({
      username: `student_${pad}`,
      code: `26-${String(4000 + i)}`,
      dob: new Date(`${birthYear}-${String(birthMonth).padStart(2, '0')}-${String(birthDay).padStart(2, '0')}`),
      address: DISTRICTS[i % DISTRICTS.length],
    });
  }

  const studentMap = {};
  await batchProcess(studentProfiles, 50, async (sp) => {
    const u = userMap[sp.username];
    const student = await prisma.hOC_VIEN.upsert({
      where: { MaSoHocVien: sp.code },
      update: {
        NgaySinh: sp.dob,
        DiaChi: sp.address,
        TrangThai: 'ACTIVE',
        DaXoa: false,
      },
      create: {
        MaNguoiDung: u.MaNguoiDung,
        MaSoHocVien: sp.code,
        NgaySinh: sp.dob,
        DiaChi: sp.address,
        TrangThai: 'ACTIVE',
        DaXoa: false,
      },
    });
    studentMap[sp.username] = student;
  });

  // --- PARENT-STUDENT LINKS (180) ---
  const parentLinks = [
    { parentUsername: 'parent', studentUsername: 'student', relation: 'Phụ huynh' },
    { parentUsername: 'parent_huong', studentUsername: 'student_tuan', relation: 'Mẹ' },
    { parentUsername: 'parent_trong', studentUsername: 'student_chau', relation: 'Bố' },
    { parentUsername: 'parent_nam', studentUsername: 'student_phuc', relation: 'Bố' },
    { parentUsername: 'parent_ha', studentUsername: 'student_linh', relation: 'Mẹ' },
    { parentUsername: 'parent_lien', studentUsername: 'student_anh', relation: 'Mẹ' },
  ];

  // Map parent_007..parent_180 to students
  for (let i = 7; i <= 180; i++) {
    const parentPad = String(i).padStart(3, '0');
    const parentUsername = `parent_${parentPad}`;
    let studentUsername;
    if (i === 7) studentUsername = 'student_huy';
    else if (i === 8) studentUsername = 'student_ngoc';
    else if (i === 9) studentUsername = 'student_nam';
    else {
      const studentIndex = i + 1; // e.g. i=10 -> student_0011
      studentUsername = `student_${String(studentIndex).padStart(4, '0')}`;
    }
    const relation = i % 2 === 0 ? 'Mẹ' : 'Bố';
    parentLinks.push({ parentUsername, studentUsername, relation });
  }

  await batchProcess(parentLinks, 40, async (pl) => {
    const parentUser = userMap[pl.parentUsername];
    const student = studentMap[pl.studentUsername];
    if (parentUser && student) {
      const existing = await prisma.pHU_HUYNH_HOC_VIEN.findFirst({
        where: {
          MaNguoiDung_PH: parentUser.MaNguoiDung,
          MaHocVien: student.MaHocVien,
          DaXoa: false,
        },
      });
      if (!existing) {
        await prisma.pHU_HUYNH_HOC_VIEN.create({
          data: {
            MaNguoiDung_PH: parentUser.MaNguoiDung,
            MaHocVien: student.MaHocVien,
            QuanHe: pl.relation,
            DaXoa: false,
          },
        });
      }
    }
  });

  return { userMap, teacherMap, studentMap, studentProfiles, teacherProfiles };
}

async function seedCoursesAndClassrooms() {
  console.log('🌱 [3/9] Seeding Courses (KHOA_HOC)...');
  const courseList = [
    { code: 'IELTS-50', title: 'IELTS Foundation 5.0+', desc: 'Xây dựng nền tảng từ vựng và ngữ pháp học thuật', target: 'IELTS 5.0', weeks: 10, fee: 6800000.0 },
    { code: 'IELTS-65', title: 'IELTS Intensive 6.5+', desc: 'Luyện thi cấp tốc 4 kỹ năng chuẩn đầu ra 6.5+', target: 'IELTS 6.5', weeks: 12, fee: 8500000.0 },
    { code: 'IELTS-75', title: 'IELTS Master 7.5+', desc: 'Chinh phục band điểm cao phục vụ du học và định cư', target: 'IELTS 7.5', weeks: 12, fee: 10500000.0 },
    { code: 'TOEIC-550', title: 'TOEIC Căn Bản 550+', desc: 'Khóa học củng cố ngữ pháp và chiến lược giải đề', target: 'TOEIC 550', weeks: 8, fee: 4200000.0 },
    { code: 'TOEIC-750', title: 'TOEIC Đột Phá 750+', desc: 'Bứt phá kỹ năng Nghe & Đọc chuẩn quốc tế', target: 'TOEIC 750', weeks: 8, fee: 5200000.0 },
    { code: 'COMM-A2', title: 'Tiếng Anh Giao Tiếp Cơ Bản A2', desc: 'Xây dựng phản xạ đàm thoại hàng ngày và chuẩn ngữ âm', target: 'CEFR A2', weeks: 8, fee: 4500000.0 },
    { code: 'COMM-B1', title: 'Tiếng Anh Giao Tiếp Phản Xạ B1', desc: 'Thuyết trình, phỏng vấn và thảo luận công việc', target: 'CEFR B1', weeks: 10, fee: 5800000.0 },
    { code: 'TEENS-B2', title: 'Tiếng Anh Thiếu Niên Học Thuật B2', desc: 'Phát triển tư duy phản biện cho học sinh THCS/THPT', target: 'CEFR B2', weeks: 12, fee: 7200000.0 },
    { code: 'BUS-ENG', title: 'Tiếng Anh Thương Mại & Đàm Phán', desc: 'Giao tiếp chuyên nghiệp trong môi trường doanh nghiệp quốc tế', target: 'Business Pro', weeks: 8, fee: 6000000.0 },
    { code: 'KIDS-STARTERS', title: 'Tiếng Anh Trẻ Em Starters', desc: 'Khơi dậy niềm vui học tiếng Anh qua bài hát và trò chơi', target: 'Cambridge Starters', weeks: 10, fee: 4800000.0 },
  ];

  const courseMap = {};
  for (const c of courseList) {
    const course = await prisma.kHOA_HOC.upsert({
      where: { MaSoKhoaHoc: c.code },
      update: {
        TenKhoaHoc: c.title,
        MoTa: c.desc,
        TrinhDoMucTieu: c.target,
        ThoiLuongTuan: c.weeks,
        HocPhi: c.fee,
        TrangThai: true,
        DaXoa: false,
      },
      create: {
        MaSoKhoaHoc: c.code,
        TenKhoaHoc: c.title,
        MoTa: c.desc,
        TrinhDoMucTieu: c.target,
        ThoiLuongTuan: c.weeks,
        HocPhi: c.fee,
        TrangThai: true,
        DaXoa: false,
      },
    });
    courseMap[c.code] = course;
  }

  console.log('🌱 [4/9] Seeding Classrooms (PHONG_HOC)...');
  const roomList = [
    { code: 'P.101', building: 'Tòa nhà A', cap: 30 },
    { code: 'P.102', building: 'Tòa nhà A', cap: 25 },
    { code: 'P.103', building: 'Tòa nhà A', cap: 25 },
    { code: 'P.201', building: 'Tòa nhà B', cap: 35 },
    { code: 'P.202', building: 'Tòa nhà B', cap: 30 },
    { code: 'P.203', building: 'Tòa nhà B', cap: 20 },
    { code: 'P.301', building: 'Tòa nhà C', cap: 40 },
    { code: 'P.302', building: 'Tòa nhà C', cap: 25 },
    { code: 'P.303', building: 'Tòa nhà C', cap: 20 },
    { code: 'LAB-01', building: 'Tòa nhà D', cap: 30 },
  ];

  const roomMap = {};
  for (const r of roomList) {
    const room = await prisma.pHONG_HOC.upsert({
      where: { MaSoPhong: r.code },
      update: {
        ToaNha: r.building,
        SucChua: r.cap,
        TrangThai: 'AVAILABLE',
        DaXoa: false,
      },
      create: {
        MaSoPhong: r.code,
        ToaNha: r.building,
        SucChua: r.cap,
        TrangThai: 'AVAILABLE',
        DaXoa: false,
      },
    });
    roomMap[r.code] = room;
  }

  return { courseMap, roomMap };
}

async function seedClassesAndRosters(maps) {
  const { teacherMap, studentMap, courseMap, userMap, studentProfiles } = maps;

  console.log('🌱 [5/9] Seeding Classes (LOP_HOC) with Lifecycle Normalization...');
  // Normalized 24 Classes:
  // - 4 PLANNING: opening in future, 0 students
  // - 6 OPEN_FOR_ENROLLMENT: open for registration, 0 or newly registered students, NO grades
  // - 10 IN_PROGRESS: active classes, 15-20 students, sessions scheduled, ongoing grades
  // - 4 COMPLETED: past classes, locked grades
  const classList = [
    // --- PLANNING (4 classes) ---
    { code: 'IELTS-75-K26B', courseCode: 'IELTS-75', teacherUser: 'teacher_david', maxCap: 20, currentEnrolled: 0, startDate: new Date('2026-12-15'), endDate: new Date('2027-03-15'), status: 'PLANNING' },
    { code: 'TOEIC-750-K14', courseCode: 'TOEIC-750', teacherUser: 'teacher_08', maxCap: 25, currentEnrolled: 0, startDate: new Date('2026-12-20'), endDate: new Date('2027-02-20'), status: 'PLANNING' },
    { code: 'BUS-ENG-K02', courseCode: 'BUS-ENG', teacherUser: 'teacher_09', maxCap: 20, currentEnrolled: 0, startDate: new Date('2027-01-05'), endDate: new Date('2027-03-05'), status: 'PLANNING' },
    { code: 'COMM-B1-K11', courseCode: 'COMM-B1', teacherUser: 'teacher_10', maxCap: 20, currentEnrolled: 0, startDate: new Date('2027-01-10'), endDate: new Date('2027-03-20'), status: 'PLANNING' },

    // --- OPEN_FOR_ENROLLMENT (6 classes) ---
    { code: 'IELTS-75-K26A', courseCode: 'IELTS-75', teacherUser: 'teacher', maxCap: 20, currentEnrolled: 0, startDate: new Date('2026-11-25'), endDate: new Date('2027-02-20'), status: 'OPEN_FOR_ENROLLMENT' },
    { code: 'IELTS-50-K16', courseCode: 'IELTS-50', teacherUser: 'teacher_phuong', maxCap: 25, currentEnrolled: 0, startDate: new Date('2026-11-28'), endDate: new Date('2027-02-10'), status: 'OPEN_FOR_ENROLLMENT' },
    { code: 'TOEIC-550-K31', courseCode: 'TOEIC-550', teacherUser: 'teacher_bao', maxCap: 25, currentEnrolled: 0, startDate: new Date('2026-12-01'), endDate: new Date('2027-02-01'), status: 'OPEN_FOR_ENROLLMENT' },
    { code: 'COMM-A2-K09', courseCode: 'COMM-A2', teacherUser: 'teacher_my', maxCap: 20, currentEnrolled: 0, startDate: new Date('2026-12-05'), endDate: new Date('2027-02-05'), status: 'OPEN_FOR_ENROLLMENT' },
    { code: 'KIDS-ST-K01', courseCode: 'KIDS-STARTERS', teacherUser: 'teacher_11', maxCap: 15, currentEnrolled: 0, startDate: new Date('2026-12-01'), endDate: new Date('2027-02-15'), status: 'OPEN_FOR_ENROLLMENT' },
    { code: 'TEENS-B2-K05', courseCode: 'TEENS-B2', teacherUser: 'teacher_12', maxCap: 20, currentEnrolled: 0, startDate: new Date('2026-12-10'), endDate: new Date('2027-03-10'), status: 'OPEN_FOR_ENROLLMENT' },

    // --- IN_PROGRESS (10 classes) ---
    { code: 'IELTS-65-K26A', courseCode: 'IELTS-65', teacherUser: 'teacher', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-11-01'), endDate: new Date('2027-01-24'), status: 'IN_PROGRESS' },
    { code: 'TOEIC-750-K12', courseCode: 'TOEIC-750', teacherUser: 'teacher2', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-11-05'), endDate: new Date('2027-01-15'), status: 'IN_PROGRESS' },
    { code: 'IELTS-65-K26B', courseCode: 'IELTS-65', teacherUser: 'teacher_david', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-11-10'), endDate: new Date('2027-02-10'), status: 'IN_PROGRESS' },
    { code: 'COMM-A2-K08', courseCode: 'COMM-A2', teacherUser: 'teacher_my', maxCap: 20, currentEnrolled: 16, startDate: new Date('2026-11-05'), endDate: new Date('2027-01-05'), status: 'IN_PROGRESS' },
    { code: 'COMM-B1-K09', courseCode: 'COMM-B1', teacherUser: 'teacher_an', maxCap: 20, currentEnrolled: 16, startDate: new Date('2026-11-12'), endDate: new Date('2027-01-22'), status: 'IN_PROGRESS' },
    { code: 'IELTS-50-K15', courseCode: 'IELTS-50', teacherUser: 'teacher_phuong', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-11-08'), endDate: new Date('2027-01-18'), status: 'IN_PROGRESS' },
    { code: 'TOEIC-550-K30', courseCode: 'TOEIC-550', teacherUser: 'teacher_bao', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-11-15'), endDate: new Date('2027-01-15'), status: 'IN_PROGRESS' },
    { code: 'TEENS-B2-K04', courseCode: 'TEENS-B2', teacherUser: 'teacher_phuong', maxCap: 20, currentEnrolled: 16, startDate: new Date('2026-11-18'), endDate: new Date('2027-02-18'), status: 'IN_PROGRESS' },
    { code: 'BUS-ENG-K01', courseCode: 'BUS-ENG', teacherUser: 'teacher_13', maxCap: 20, currentEnrolled: 15, startDate: new Date('2026-11-02'), endDate: new Date('2027-01-02'), status: 'IN_PROGRESS' },
    { code: 'COMM-B1-K10', courseCode: 'COMM-B1', teacherUser: 'teacher_14', maxCap: 20, currentEnrolled: 15, startDate: new Date('2026-11-08'), endDate: new Date('2027-01-18'), status: 'IN_PROGRESS' },

    // --- COMPLETED (4 classes) ---
    { code: 'IELTS-65-PAST', courseCode: 'IELTS-65', teacherUser: 'teacher', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-08-15'), endDate: new Date('2026-10-15'), status: 'COMPLETED' },
    { code: 'TOEIC-550-PAST', courseCode: 'TOEIC-550', teacherUser: 'teacher_bao', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-08-01'), endDate: new Date('2026-10-01'), status: 'COMPLETED' },
    { code: 'COMM-A2-PAST', courseCode: 'COMM-A2', teacherUser: 'teacher_my', maxCap: 20, currentEnrolled: 16, startDate: new Date('2026-08-10'), endDate: new Date('2026-10-10'), status: 'COMPLETED' },
    { code: 'IELTS-50-PAST', courseCode: 'IELTS-50', teacherUser: 'teacher_phuong', maxCap: 25, currentEnrolled: 18, startDate: new Date('2026-07-20'), endDate: new Date('2026-09-30'), status: 'COMPLETED' },
  ];

  const classMap = {};
  for (const c of classList) {
    const course = courseMap[c.courseCode];
    const teacher = teacherMap[c.teacherUser];
    const cls = await prisma.lOP_HOC.upsert({
      where: { MaSoLop: c.code },
      update: {
        MaKhoaHoc: course.MaKhoaHoc,
        MaGiangVien: teacher?.MaGiangVien,
        SiSoToiDa: c.maxCap,
        SiSoHienTai: c.currentEnrolled,
        NgayBatDau: c.startDate,
        NgayKetThuc: c.endDate,
        TrangThai: c.status,
        DaXoa: false,
      },
      create: {
        MaSoLop: c.code,
        MaKhoaHoc: course.MaKhoaHoc,
        MaGiangVien: teacher?.MaGiangVien,
        SiSoToiDa: c.maxCap,
        SiSoHienTai: c.currentEnrolled,
        NgayBatDau: c.startDate,
        NgayKetThuc: c.endDate,
        TrangThai: c.status,
        DaXoa: false,
      },
    });
    classMap[c.code] = { ...cls, ...c };
  }

  console.log('🌱 [6/9] Seeding Rosters & Enrollments (HOC_VIEN_LOP_HOC & YEU_CAU_DANG_KY)...');
  // Distribute students cleanly into classes
  // Total active & completed classes = 14
  const activeAndCompletedClasses = Object.values(classMap).filter(c => c.status === 'IN_PROGRESS' || c.status === 'COMPLETED');
  const enrollmentPairs = [];

  let studentIdx = 0;
  for (const c of activeAndCompletedClasses) {
    const countToEnroll = c.currentEnrolled;
    for (let k = 0; k < countToEnroll; k++) {
      const studentProfile = studentProfiles[studentIdx % studentProfiles.length];
      enrollmentPairs.push({
        classCode: c.code,
        studentUser: studentProfile.username,
        isCompleted: c.status === 'COMPLETED',
      });
      studentIdx++;
    }
  }

  // Ensure key demo students are in classes
  if (!enrollmentPairs.some(e => e.classCode === 'IELTS-65-K26A' && e.studentUser === 'student')) {
    enrollmentPairs.unshift({ classCode: 'IELTS-65-K26A', studentUser: 'student', isCompleted: false });
  }
  if (!enrollmentPairs.some(e => e.classCode === 'IELTS-65-PAST' && e.studentUser === 'student_tuan')) {
    enrollmentPairs.unshift({ classCode: 'IELTS-65-PAST', studentUser: 'student_tuan', isCompleted: true });
  }

  await batchProcess(enrollmentPairs, 50, async (enr) => {
    const cls = classMap[enr.classCode];
    const stu = studentMap[enr.studentUser];
    if (cls && stu) {
      const existingRoster = await prisma.hOC_VIEN_LOP_HOC.findFirst({
        where: {
          MaLopHoc: cls.MaLopHoc,
          MaHocVien: stu.MaHocVien,
          DaXoa: false,
        },
      });
      if (!existingRoster) {
        await prisma.hOC_VIEN_LOP_HOC.create({
          data: {
            MaLopHoc: cls.MaLopHoc,
            MaHocVien: stu.MaHocVien,
            TrangThaiHoc: enr.isCompleted ? 'COMPLETED' : 'ENROLLED',
            DaXoa: false,
          },
        });
      }

      const existingReq = await prisma.yEU_CAU_DANG_KY.findFirst({
        where: {
          MaLopHoc: cls.MaLopHoc,
          MaHocVien: stu.MaHocVien,
          DaXoa: false,
        },
      });
      if (!existingReq) {
        await prisma.yEU_CAU_DANG_KY.create({
          data: {
            MaLopHoc: cls.MaLopHoc,
            MaHocVien: stu.MaHocVien,
            TrangThai: 'APPROVED',
            GhiChu: 'Ghi danh theo học phần',
            MaNguoiDuyet: userMap.staff.MaNguoiDung,
            NgayDuyet: new Date(),
            DaXoa: false,
          },
        });
      }
    }
  });

  return { classMap, enrollmentPairs, activeAndCompletedClasses };
}

async function seedSchedulesAndGrades(maps) {
  const { teacherMap, studentMap, roomMap, classMap, userMap, courseMap, enrollmentPairs } = maps;

  console.log('🌱 [7/9] Seeding Schedule Sessions (BUOI_HOC)...');
  const today = new Date();
  const baseDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());

  const scheduleConfigs = [
    // cls: IELTS-65-K26A (Thứ 2, 4, 6 - Ca 18:00 - 20:00 tại P.101)
    { classCode: 'IELTS-65-K26A', roomCode: 'P.101', teacherUser: 'teacher', dayOffset: 1, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    { classCode: 'IELTS-65-K26A', roomCode: 'P.101', teacherUser: 'teacher', dayOffset: 3, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    { classCode: 'IELTS-65-K26A', roomCode: 'P.101', teacherUser: 'teacher', dayOffset: 5, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    // cls: TOEIC-750-K12 (Thứ 3, 5 - Ca 18:00 - 20:00 tại P.102)
    { classCode: 'TOEIC-750-K12', roomCode: 'P.102', teacherUser: 'teacher2', dayOffset: 2, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    { classCode: 'TOEIC-750-K12', roomCode: 'P.102', teacherUser: 'teacher2', dayOffset: 4, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    // cls: IELTS-65-K26B (Thứ 3, 5 - Ca 18:00 - 20:00 tại P.201)
    { classCode: 'IELTS-65-K26B', roomCode: 'P.201', teacherUser: 'teacher_david', dayOffset: 2, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    { classCode: 'IELTS-65-K26B', roomCode: 'P.201', teacherUser: 'teacher_david', dayOffset: 4, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    // cls: COMM-A2-K08 (Thứ 2, 4 - Ca 08:00 - 10:00 tại P.103)
    { classCode: 'COMM-A2-K08', roomCode: 'P.103', teacherUser: 'teacher_my', dayOffset: 1, start: '08:00', end: '10:00', shift: 'Ca sáng (08:00 - 10:00)' },
    { classCode: 'COMM-A2-K08', roomCode: 'P.103', teacherUser: 'teacher_my', dayOffset: 3, start: '08:00', end: '10:00', shift: 'Ca sáng (08:00 - 10:00)' },
    // cls: COMM-B1-K09 (Thứ 3, 5 - Ca 14:00 - 16:00 tại P.202)
    { classCode: 'COMM-B1-K09', roomCode: 'P.202', teacherUser: 'teacher_an', dayOffset: 2, start: '14:00', end: '16:00', shift: 'Ca chiều (14:00 - 16:00)' },
    { classCode: 'COMM-B1-K09', roomCode: 'P.202', teacherUser: 'teacher_an', dayOffset: 4, start: '14:00', end: '16:00', shift: 'Ca chiều (14:00 - 16:00)' },
    // cls: IELTS-50-K15 (Thứ 2, 6 - Ca 14:00 - 16:00 tại P.203)
    { classCode: 'IELTS-50-K15', roomCode: 'P.203', teacherUser: 'teacher_phuong', dayOffset: 1, start: '14:00', end: '16:00', shift: 'Ca chiều (14:00 - 16:00)' },
    { classCode: 'IELTS-50-K15', roomCode: 'P.203', teacherUser: 'teacher_phuong', dayOffset: 5, start: '14:00', end: '16:00', shift: 'Ca chiều (14:00 - 16:00)' },
    // cls: TOEIC-550-K30 (Thứ 7, CN - Ca 08:00 - 10:00 tại P.301)
    { classCode: 'TOEIC-550-K30', roomCode: 'P.301', teacherUser: 'teacher_bao', dayOffset: 6, start: '08:00', end: '10:00', shift: 'Cuối tuần sáng (08:00 - 10:00)' },
    { classCode: 'TOEIC-550-K30', roomCode: 'P.301', teacherUser: 'teacher_bao', dayOffset: 7, start: '08:00', end: '10:00', shift: 'Cuối tuần sáng (08:00 - 10:00)' },
    // cls: TEENS-B2-K04 (Thứ 7, CN - Ca 14:00 - 16:00 tại P.303)
    { classCode: 'TEENS-B2-K04', roomCode: 'P.303', teacherUser: 'teacher_phuong', dayOffset: 6, start: '14:00', end: '16:00', shift: 'Cuối tuần chiều (14:00 - 16:00)' },
    { classCode: 'TEENS-B2-K04', roomCode: 'P.303', teacherUser: 'teacher_phuong', dayOffset: 7, start: '14:00', end: '16:00', shift: 'Cuối tuần chiều (14:00 - 16:00)' },
    // cls: BUS-ENG-K01 (Thứ 2, 4 - Ca 18:00 - 20:00 tại P.302)
    { classCode: 'BUS-ENG-K01', roomCode: 'P.302', teacherUser: 'teacher_13', dayOffset: 1, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    { classCode: 'BUS-ENG-K01', roomCode: 'P.302', teacherUser: 'teacher_13', dayOffset: 3, start: '18:00', end: '20:00', shift: 'Ca tối (18:00 - 20:00)' },
    // cls: COMM-B1-K10 (Thứ 3, 5 - Ca 08:00 - 10:00 tại LAB-01)
    { classCode: 'COMM-B1-K10', roomCode: 'LAB-01', teacherUser: 'teacher_14', dayOffset: 2, start: '08:00', end: '10:00', shift: 'Ca sáng (08:00 - 10:00)' },
    { classCode: 'COMM-B1-K10', roomCode: 'LAB-01', teacherUser: 'teacher_14', dayOffset: 4, start: '08:00', end: '10:00', shift: 'Ca sáng (08:00 - 10:00)' },
  ];

  await batchProcess(scheduleConfigs, 20, async (sc) => {
    const cls = classMap[sc.classCode];
    const room = roomMap[sc.roomCode];
    const teacher = teacherMap[sc.teacherUser];
    const sessDate = new Date(baseDate.getTime() + sc.dayOffset * 86400000);

    const existingSess = await prisma.bUOI_HOC.findFirst({
      where: {
        MaLopHoc: cls.MaLopHoc,
        NgayHoc: sessDate,
        GioBatDau: sc.start,
        GioKetThuc: sc.end,
        DaXoa: false,
      },
    });

    if (!existingSess) {
      await prisma.bUOI_HOC.create({
        data: {
          MaLopHoc: cls.MaLopHoc,
          MaPhongHoc: room.MaPhongHoc,
          MaGiangVien: teacher.MaGiangVien,
          NgayHoc: sessDate,
          GioBatDau: sc.start,
          GioKetThuc: sc.end,
          CaHoc: sc.shift,
          DaXacNhan: true,
          TrangThai: 'SCHEDULED',
          DaXoa: false,
        },
      });
    }
  });

  console.log('🌱 [8/9] Seeding Grades (BANG_DIEM) & Progression (TIEN_TRINH_KHOA_HOC)...');
  // Grades: STRICTLY only for IN_PROGRESS or COMPLETED classes!
  // OPEN_FOR_ENROLLMENT and PLANNING classes have 0 grades.
  const gradesToSeed = [];
  for (const enr of enrollmentPairs) {
    const isCompleted = enr.isCompleted;
    const seedNum = (enr.studentUser.length * 7 + enr.classCode.length * 13) % 20;
    const cc = 8.0 + (seedNum % 5) * 0.5;
    const gk = 6.5 + ((seedNum + 2) % 6) * 0.5;
    const ck = 7.0 + ((seedNum + 4) % 6) * 0.5;
    const total = parseFloat(((cc * 0.1 + gk * 0.3 + ck * 0.6)).toFixed(1));
    const result = total >= 5.0 ? 'PASSED' : 'FAILED';

    gradesToSeed.push({
      classCode: enr.classCode,
      studentUser: enr.studentUser,
      cc,
      gk,
      ck: isCompleted ? ck : null,
      total: isCompleted ? total : null,
      result: isCompleted ? result : 'STUDYING',
      locked: isCompleted,
      note: isCompleted ? 'Đã hoàn thành khóa học và cấp chứng chỉ' : 'Đang học - Đánh giá quá trình',
    });
  }

  await batchProcess(gradesToSeed, 50, async (gc) => {
    const cls = classMap[gc.classCode];
    const stu = studentMap[gc.studentUser];
    if (cls && stu) {
      const existingGrade = await prisma.bANG_DIEM.findFirst({
        where: {
          MaLopHoc: cls.MaLopHoc,
          MaHocVien: stu.MaHocVien,
          DaXoa: false,
        },
      });

      if (existingGrade) {
        await prisma.bANG_DIEM.update({
          where: { MaBangDiem: existingGrade.MaBangDiem },
          data: {
            DiemChuyenCan: gc.cc,
            DiemGiuaKy: gc.gk,
            DiemCuoiKy: gc.ck,
            DiemTongKet: gc.total,
            KetQua: gc.result,
            DaKhoaSo: gc.locked,
            GhiChu: gc.note,
          },
        });
      } else {
        await prisma.bANG_DIEM.create({
          data: {
            MaLopHoc: cls.MaLopHoc,
            MaHocVien: stu.MaHocVien,
            DiemChuyenCan: gc.cc,
            DiemGiuaKy: gc.gk,
            DiemCuoiKy: gc.ck,
            DiemTongKet: gc.total,
            KetQua: gc.result,
            DaKhoaSo: gc.locked,
            GhiChu: gc.note,
            DaXoa: false,
          },
        });
      }
    }
  });

  // Course progression: student c1 (IELTS-65) -> c2 (IELTS-75)
  const c1 = courseMap['IELTS-65'];
  const c2 = courseMap['IELTS-75'];
  const stu = studentMap.student;

  const existingProg = await prisma.tIEN_TRINH_KHOA_HOC.findFirst({
    where: {
      MaHocVien: stu.MaHocVien,
      MaKhoaHocHienTai: c1.MaKhoaHoc,
      MaKhoaHocTiepTheo: c2.MaKhoaHoc,
      DaXoa: false,
    },
  });

  if (!existingProg) {
    await prisma.tIEN_TRINH_KHOA_HOC.create({
      data: {
        MaHocVien: stu.MaHocVien,
        MaKhoaHocHienTai: c1.MaKhoaHoc,
        MaKhoaHocTiepTheo: c2.MaKhoaHoc,
        DuDieuKien: true,
        DaXacNhan: true,
        MaNguoiXacNhan: userMap.staff.MaNguoiDung,
        NgayXacNhan: new Date(),
        GhiChu: 'Đủ điều kiện chuyển tiếp từ IELTS 6.5 lên 7.5',
        DaXoa: false,
      },
    });
  }
}

async function seedTicketsAndHistory(maps) {
  const { userMap, classMap, enrollmentPairs, activeAndCompletedClasses } = maps;
  console.log('🌱 [9/9] Seeding Module Yêu cầu & Khiếu nại (DON_THU, PHAN_HOI, LICHSU_KHOA_DIEM)...');
  console.log('   -> STUDENT COMPLAINTS: 120 records (Range: 100–150)');
  console.log('   -> TEACHER GRADE UNLOCK REQUESTS: 90 records (Range: 80–120)');

  const staffUser = userMap.staff;

  // ---------------------------------------------------------
  // 1. KHIẾU NẠI CỦA HỌC VIÊN (COMPLAINTS: 120 đơn)
  // Quy trình: STUDENT -> TEACHER -> Xử lý khiếu nại
  // 6 tình huống: Chuyên cần, Giữa kỳ, Cuối kỳ, Tổng kết, Hiển thị sai, Chưa cập nhật
  // Phân bố: 30 PENDING, 30 PROCESSING, 45 RESOLVED, 15 CLOSED
  // ---------------------------------------------------------
  const COMPLAINT_TEMPLATES = [
    {
      title: (c, s) => `Khiếu nại điểm chuyên cần buổi học thứ ${s} - Lớp ${c.code}`,
      content: (c, s) => `Kính chào thầy/cô phụ trách lớp ${c.code}, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số ${s}, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.`,
    },
    {
      title: (c) => `Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp ${c.code}`,
      content: (c) => `Kính gửi thầy/cô lớp ${c.code}, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.`,
    },
    {
      title: (c) => `Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp ${c.code}`,
      content: (c) => `Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp ${c.code}. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.`,
    },
    {
      title: (c) => `Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp ${c.code}`,
      content: (c) => `Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.`,
    },
    {
      title: (c) => `Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp ${c.code}`,
      content: (c) => `Trong buổi sửa bài cuối khóa trên lớp ${c.code}, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.`,
    },
    {
      title: (c) => `Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp ${c.code}`,
      content: (c) => `Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.`,
    },
  ];

  const complaintsList = [];
  for (let i = 1; i <= 120; i++) {
    const code = `KN-202611-${String(i).padStart(4, '0')}`;
    const enr = enrollmentPairs[i % enrollmentPairs.length];
    const studentUser = userMap[enr.studentUser];
    const cls = classMap[enr.classCode];
    const teacherUser = userMap[cls.teacherUser];

    const template = COMPLAINT_TEMPLATES[i % COMPLAINT_TEMPLATES.length];
    const title = template.title(cls, (i % 8) + 1);
    const content = template.content(cls, (i % 8) + 1);

    // Status distribution
    let status;
    let messages = [];
    if (i <= 30) {
      status = 'PENDING';
      // 0 messages: New ticket in queue
    } else if (i <= 60) {
      status = 'PROCESSING';
      messages = [
        {
          sender: teacherUser,
          content: 'Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.',
        },
        {
          sender: studentUser,
          content: 'Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.',
        },
      ];
    } else if (i <= 105) {
      status = 'RESOLVED';
      const isAccepted = i % 2 === 0;
      messages = [
        {
          sender: teacherUser,
          content: 'Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.',
        },
        {
          sender: teacherUser,
          content: isAccepted
            ? '[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!'
            : '[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.',
        },
      ];
    } else {
      status = 'CLOSED';
      messages = [
        {
          sender: teacherUser,
          content: '[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.',
        },
        {
          sender: studentUser,
          content: 'Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.',
        },
      ];
    }

    const deadline = new Date(cls.endDate.getTime() + 7 * 86400000);

    complaintsList.push({
      ticketCode: code,
      ticketType: 'COMPLAINT',
      senderId: studentUser.MaNguoiDung,
      receiverId: teacherUser.MaNguoiDung,
      receiverRole: 'TEACHER',
      category: 'GRADE',
      classId: cls.MaLopHoc,
      title,
      content,
      status,
      deadlineAt: deadline,
      messages,
    });
  }

  // ---------------------------------------------------------
  // 2. YÊU CẦU MỞ SỔ ĐIỂM CỦA GIẢNG VIÊN (REQUESTS: 90 đơn)
  // Quy trình: TEACHER -> ACADEMIC_STAFF / ADMIN -> Xử lý
  // 5 trường hợp: Mở lần đầu, Mở lại, Điều chỉnh điểm, Nhập bổ sung, Xử lý sai sót
  // Phân bố: 20 PENDING, 15 PROCESSING, 40 APPROVED, 15 REJECTED
  // ---------------------------------------------------------
  const REQUEST_TEMPLATES = [
    {
      title: (c) => `Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp ${c.code}`,
      content: (c) => `Kính gửi Phòng Đào tạo & Học vụ, lớp ${c.code} đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.`,
    },
    {
      title: (c) => `Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp ${c.code}`,
      content: (c) => `Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp ${c.code}, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.`,
    },
    {
      title: (c) => `Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp ${c.code}`,
      content: (c) => `Kính gửi Ban Học vụ, giảng viên phụ trách lớp ${c.code} phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.`,
    },
    {
      title: (c) => `Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp ${c.code}`,
      content: (c) => `Kính gửi Phòng Học vụ, lớp ${c.code} có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.`,
    },
    {
      title: (c) => `Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp ${c.code}`,
      content: (c) => `Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp ${c.code}, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.`,
    },
  ];

  const requestsList = [];
  for (let j = 1; j <= 90; j++) {
    const code = `YC-202611-${String(j).padStart(4, '0')}`;
    const cls = activeAndCompletedClasses[j % activeAndCompletedClasses.length];
    const teacherUser = userMap[cls.teacherUser];

    const template = REQUEST_TEMPLATES[j % REQUEST_TEMPLATES.length];
    const title = template.title(cls);
    const content = template.content(cls);

    let status;
    let messages = [];
    let needAuditUnlock = false;

    if (j <= 20) {
      status = 'PENDING';
      // 0 messages: waiting for review
    } else if (j <= 35) {
      status = 'PROCESSING';
      messages = [
        {
          sender: staffUser,
          content: 'Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.',
        },
      ];
    } else if (j <= 75) {
      status = 'APPROVED';
      needAuditUnlock = true;
      messages = [
        {
          sender: staffUser,
          content: `[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ${teacherUser.HoTen} theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.`,
        },
      ];
    } else {
      status = 'REJECTED';
      messages = [
        {
          sender: staffUser,
          content: '[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.',
        },
      ];
    }

    requestsList.push({
      ticketCode: code,
      ticketType: 'REQUEST',
      senderId: teacherUser.MaNguoiDung,
      receiverId: staffUser.MaNguoiDung,
      receiverRole: 'ACADEMIC_STAFF',
      category: 'GRADE_UNLOCK',
      classId: cls.MaLopHoc,
      title,
      content,
      status,
      deadlineAt: null,
      messages,
      needAuditUnlock,
    });
  }

  // Combine and write all tickets to PostgreSQL via raw query
  const allTickets = [...complaintsList, ...requestsList];
  console.log(`   -> Inserting/Upserting ${allTickets.length} Tickets...`);

  await batchProcess(allTickets, 30, async (t) => {
    // 1. Insert/Upsert Ticket
    const rows = await prisma.$queryRawUnsafe(`
      INSERT INTO "DON_THU" (
        "MaSoDon", "LoaiDon", "MaNguoiGui", "MaNguoiNhan", "VaiTroNguoiNhan",
        "LinhVuc", "MaLopHoc", "TieuDe", "NoiDung", "TrangThai",
        "HanChotKhieuNai", "NgayTao", "NgayCapNhat", "DaXoa"
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, false
      ) ON CONFLICT ("MaSoDon") DO UPDATE SET
        "LoaiDon" = EXCLUDED."LoaiDon",
        "MaNguoiGui" = EXCLUDED."MaNguoiGui",
        "MaNguoiNhan" = EXCLUDED."MaNguoiNhan",
        "VaiTroNguoiNhan" = EXCLUDED."VaiTroNguoiNhan",
        "LinhVuc" = EXCLUDED."LinhVuc",
        "MaLopHoc" = EXCLUDED."MaLopHoc",
        "TieuDe" = EXCLUDED."TieuDe",
        "NoiDung" = EXCLUDED."NoiDung",
        "TrangThai" = EXCLUDED."TrangThai",
        "HanChotKhieuNai" = EXCLUDED."HanChotKhieuNai",
        "NgayCapNhat" = EXCLUDED."NgayCapNhat",
        "DaXoa" = false
      RETURNING "MaDon"
    `,
      t.ticketCode, t.ticketType, t.senderId, t.receiverId, t.receiverRole,
      t.category, t.classId, t.title, t.content, t.status,
      t.deadlineAt, new Date(), new Date()
    );

    const ticketId = rows[0]?.MaDon;
    if (!ticketId) return;

    // 2. Insert messages if not already present
    if (t.messages && t.messages.length > 0) {
      const existingMsgs = await prisma.$queryRawUnsafe(
        'SELECT count(*) as count FROM "DON_THU_PHAN_HOI" WHERE "MaDon" = $1 AND "DaXoa" = false',
        ticketId
      );
      const msgCount = Number(existingMsgs[0]?.count || 0);

      if (msgCount === 0) {
        for (const m of t.messages) {
          await prisma.$executeRawUnsafe(`
            INSERT INTO "DON_THU_PHAN_HOI" (
              "MaDon", "MaNguoiGui", "NoiDung", "NgayTao", "NgayCapNhat", "DaXoa"
            ) VALUES (
              $1, $2, $3, $4, $5, false
            )
          `,
            ticketId, m.sender.MaNguoiDung, m.content, new Date(), new Date()
          );
        }
      }
    }

    // 3. Insert Audit Log into LICHSU_KHOA_DIEM for APPROVED unlock requests
    if (t.needAuditUnlock) {
      const reasonText = `Phê duyệt yêu cầu mở sổ điểm #${t.ticketCode}`;
      const existingLogs = await prisma.$queryRawUnsafe(
        'SELECT count(*) as count FROM "LICHSU_KHOA_DIEM" WHERE "MaLopHoc" = $1 AND "LyDo" LIKE $2 AND "DaXoa" = false',
        t.classId, `%${t.ticketCode}%`
      );
      const logCount = Number(existingLogs[0]?.count || 0);

      if (logCount === 0) {
        await prisma.$executeRawUnsafe(`
          INSERT INTO "LICHSU_KHOA_DIEM" (
            "MaLopHoc", "HanhDong", "MaNguoiThucHien", "ThoiGian", "LyDo", "NgayTao", "NgayCapNhat", "DaXoa"
          ) VALUES (
            $1, 'UNLOCK', $2, $3, $4, $5, $6, false
          )
        `,
          t.classId, staffUser.MaNguoiDung, new Date(), reasonText, new Date(), new Date()
        );
      }
    }
  });

  console.log('✅ Tickets, Messages & Audit History successfully seeded!');
}

async function verifySeededData() {
  console.log('\n======================================================');
  console.log('🔍 VERIFYING SEEDED DATA VIA PRISMA CLIENT');
  console.log('======================================================');

  const countUsers = await prisma.nGUOI_DUNG.count({ where: { DaXoa: false } });
  const countTeachers = await prisma.gIANG_VIEN.count({ where: { DaXoa: false } });
  const countStudents = await prisma.hOC_VIEN.count({ where: { DaXoa: false } });
  const countParents = await prisma.pHU_HUYNH_HOC_VIEN.count({ where: { DaXoa: false } });
  const countCourses = await prisma.kHOA_HOC.count({ where: { DaXoa: false } });
  const countClassrooms = await prisma.pHONG_HOC.count({ where: { DaXoa: false } });
  const countClasses = await prisma.lOP_HOC.count({ where: { DaXoa: false } });
  const countRosters = await prisma.hOC_VIEN_LOP_HOC.count({ where: { DaXoa: false } });
  const countEnrollments = await prisma.yEU_CAU_DANG_KY.count({ where: { DaXoa: false } });
  const countSessions = await prisma.bUOI_HOC.count({ where: { DaXoa: false } });
  const countGrades = await prisma.bANG_DIEM.count({ where: { DaXoa: false } });
  const countProgressions = await prisma.tIEN_TRINH_KHOA_HOC.count({ where: { DaXoa: false } });

  // Count by role
  const roleCounts = await prisma.nGUOI_DUNG.groupBy({
    by: ['VaiTro'],
    where: { DaXoa: false },
    _count: { MaNguoiDung: true },
  });

  const roleMap = {};
  for (const r of roleCounts) {
    roleMap[r.VaiTro] = r._count.MaNguoiDung;
  }

  console.log(`📊 Total Users (NGUOI_DUNG):            ${countUsers}`);
  console.log(`   - ADMIN (Chính xác 1):               ${roleMap.ADMIN || 0}`);
  console.log(`   - ACADEMIC_STAFF (Chính xác 1):      ${roleMap.ACADEMIC_STAFF || 0}`);
  console.log(`   - TEACHER (Quy chuẩn 30–50):         ${roleMap.TEACHER || 0}`);
  console.log(`   - STUDENT (Quy chuẩn 300–500):       ${roleMap.STUDENT || 0}`);
  console.log(`   - PARENT (Quy chuẩn 150–250):        ${roleMap.PARENT || 0}`);
  console.log(`📊 Total Teachers (GIANG_VIEN):        ${countTeachers}`);
  console.log(`📊 Total Students (HOC_VIEN):          ${countStudents}`);
  console.log(`📊 Total Parent Links (PHU_HUYNH):     ${countParents}`);
  console.log(`📊 Total Courses (KHOA_HOC):           ${countCourses}`);
  console.log(`📊 Total Classrooms (PHONG_HOC):       ${countClassrooms}`);
  console.log(`📊 Total Classes (LOP_HOC):            ${countClasses}`);
  console.log(`📊 Total Rosters (HOC_VIEN_LOP_HOC):   ${countRosters}`);
  console.log(`📊 Total Requests (YEU_CAU_DANG_KY):   ${countEnrollments}`);
  console.log(`📊 Total Sessions (BUOI_HOC):          ${countSessions}`);
  console.log(`📊 Total Grade Records (BANG_DIEM):    ${countGrades}`);
  console.log(`📊 Total Progressions:                 ${countProgressions}`);

  // Strict role assertions
  if (roleMap.ADMIN !== 1) throw new Error(`Expected exactly 1 ADMIN, found ${roleMap.ADMIN}`);
  if (roleMap.ACADEMIC_STAFF !== 1) throw new Error(`Expected exactly 1 ACADEMIC_STAFF, found ${roleMap.ACADEMIC_STAFF}`);
  if (roleMap.TEACHER < 30 || roleMap.TEACHER > 50) throw new Error(`TEACHER count ${roleMap.TEACHER} out of range [30, 50]`);
  if (roleMap.STUDENT < 300 || roleMap.STUDENT > 500) throw new Error(`STUDENT count ${roleMap.STUDENT} out of range [300, 500]`);
  if (roleMap.PARENT < 150 || roleMap.PARENT > 250) throw new Error(`PARENT count ${roleMap.PARENT} out of range [150, 250]`);

  // Lifecycle check:
  // Classes in OPEN_FOR_ENROLLMENT must have 0 grade records
  const openClasses = await prisma.lOP_HOC.findMany({ where: { TrangThai: 'OPEN_FOR_ENROLLMENT', DaXoa: false } });
  for (const oc of openClasses) {
    const gCount = await prisma.bANG_DIEM.count({ where: { MaLopHoc: oc.MaLopHoc, DaXoa: false } });
    if (gCount !== 0) throw new Error(`OPEN_FOR_ENROLLMENT class ${oc.MaSoLop} has ${gCount} grades, expected 0!`);
  }
  console.log(`✓ All ${openClasses.length} OPEN_FOR_ENROLLMENT Classes have 0 Grade Records`);

  // Classes in PLANNING must have 0 grade records
  const planClasses = await prisma.lOP_HOC.findMany({ where: { TrangThai: 'PLANNING', DaXoa: false } });
  for (const pc of planClasses) {
    const gCount = await prisma.bANG_DIEM.count({ where: { MaLopHoc: pc.MaLopHoc, DaXoa: false } });
    if (gCount !== 0) throw new Error(`PLANNING class ${pc.MaSoLop} has ${gCount} grades, expected 0!`);
  }
  console.log(`✓ All ${planClasses.length} PLANNING Classes have 0 Grade Records`);

  // Classes in COMPLETED must have locked grades
  const completedClasses = await prisma.lOP_HOC.findMany({ where: { TrangThai: 'COMPLETED', DaXoa: false } });
  for (const cc of completedClasses) {
    const unlockedGrades = await prisma.bANG_DIEM.count({ where: { MaLopHoc: cc.MaLopHoc, DaKhoaSo: false, DaXoa: false } });
    if (unlockedGrades !== 0) throw new Error(`COMPLETED class ${cc.MaSoLop} has unlocked grades!`);
  }
  console.log(`✓ All ${completedClasses.length} COMPLETED Classes have locked grades (DaKhoaSo = true)`);

  // ---------------------------------------------------------
  // Verify Module Yêu cầu và Khiếu nại (DON_THU, PHAN_HOI, LICHSU_KHOA_DIEM)
  // ---------------------------------------------------------
  console.log('\n--- 📋 VERIFYING MODULE YÊU CẦU & KHIẾU NẠI ---');
  const countComplaintsRaw = await prisma.$queryRawUnsafe(`SELECT count(*) as count FROM "DON_THU" WHERE "LoaiDon" = 'COMPLAINT' AND "DaXoa" = false`);
  const countComplaints = Number(countComplaintsRaw[0]?.count || 0);

  const countRequestsRaw = await prisma.$queryRawUnsafe(`SELECT count(*) as count FROM "DON_THU" WHERE "LoaiDon" = 'REQUEST' AND "DaXoa" = false`);
  const countRequests = Number(countRequestsRaw[0]?.count || 0);

  const countMessagesRaw = await prisma.$queryRawUnsafe(`SELECT count(*) as count FROM "DON_THU_PHAN_HOI" WHERE "DaXoa" = false`);
  const countMessages = Number(countMessagesRaw[0]?.count || 0);

  const countAuditLogsRaw = await prisma.$queryRawUnsafe(`SELECT count(*) as count FROM "LICHSU_KHOA_DIEM" WHERE "DaXoa" = false`);
  const countAuditLogs = Number(countAuditLogsRaw[0]?.count || 0);

  console.log(`📊 Khiếu nại học viên (COMPLAINT):       ${countComplaints} (Quy chuẩn: 100–150)`);
  console.log(`📊 Yêu cầu mở sổ giảng viên (REQUEST):    ${countRequests} (Quy chuẩn: 80–120)`);
  console.log(`📊 Phản hồi & trao đổi (DON_THU_PHAN_HOI): ${countMessages}`);
  console.log(`📊 Lịch sử mở sổ (LICHSU_KHOA_DIEM):      ${countAuditLogs}`);

  // Assertions for quantities
  if (countComplaints < 100 || countComplaints > 150) {
    throw new Error(`COMPLAINT count ${countComplaints} out of range [100, 150]`);
  }
  if (countRequests < 80 || countRequests > 120) {
    throw new Error(`REQUEST count ${countRequests} out of range [80, 120]`);
  }

  // Status breakdown
  const complaintStatuses = await prisma.$queryRawUnsafe(`
    SELECT "TrangThai", count(*) as cnt 
    FROM "DON_THU" 
    WHERE "LoaiDon" = 'COMPLAINT' AND "DaXoa" = false 
    GROUP BY "TrangThai"
    ORDER BY "TrangThai"
  `);
  console.log('📊 Trạng thái khiếu nại (COMPLAINT):');
  for (const s of complaintStatuses) {
    console.log(`   - ${s.TrangThai}: ${s.cnt}`);
  }

  const requestStatuses = await prisma.$queryRawUnsafe(`
    SELECT "TrangThai", count(*) as cnt 
    FROM "DON_THU" 
    WHERE "LoaiDon" = 'REQUEST' AND "DaXoa" = false 
    GROUP BY "TrangThai"
    ORDER BY "TrangThai"
  `);
  console.log('📊 Trạng thái yêu cầu mở sổ (REQUEST):');
  for (const s of requestStatuses) {
    console.log(`   - ${s.TrangThai}: ${s.cnt}`);
  }

  // Verify that PENDING tickets do NOT have fake completion messages
  const pendingWithMsg = await prisma.$queryRawUnsafe(`
    SELECT count(*) as count
    FROM "DON_THU" d
    JOIN "DON_THU_PHAN_HOI" p ON d."MaDon" = p."MaDon"
    WHERE d."TrangThai" = 'PENDING' AND (p."NoiDung" LIKE '%[HỆ THỐNG]%' OR p."NoiDung" LIKE '%[KẾT QUẢ XỬ LÝ]%')
  `);
  const fakePendingCount = Number(pendingWithMsg[0]?.count || 0);
  console.log(`✓ Đơn PENDING có lịch sử hoàn tất giả: ${fakePendingCount} (Kỳ vọng: 0)`);
  if (fakePendingCount !== 0) throw new Error('PENDING tickets must not have completion history!');

  // Verify that all APPROVED unlock requests have history in LICHSU_KHOA_DIEM
  const approvedUnlockWithoutLog = await prisma.$queryRawUnsafe(`
    SELECT count(*) as count
    FROM "DON_THU" d
    WHERE d."LoaiDon" = 'REQUEST' AND d."LinhVuc" = 'GRADE_UNLOCK' AND d."TrangThai" = 'APPROVED'
      AND NOT EXISTS (
        SELECT 1 FROM "LICHSU_KHOA_DIEM" l WHERE l."MaLopHoc" = d."MaLopHoc" AND l."LyDo" LIKE '%' || d."MaSoDon" || '%'
      )
  `);
  const missingLogCount = Number(approvedUnlockWithoutLog[0]?.count || 0);
  console.log(`✓ Đơn APPROVED thiếu bản ghi LICHSU_KHOA_DIEM: ${missingLogCount} (Kỳ vọng: 0)`);
  if (missingLogCount !== 0) throw new Error('APPROVED unlock requests must have audit logs in LICHSU_KHOA_DIEM!');

  console.log('✅ ALL PRISMA & TICKET VERIFICATION CHECKS PASSED!\n');
}

async function main() {
  console.log('======================================================');
  console.log('🚀 PRISMA SEED STARTING (IDEMPOTENT & NON-DESTRUCTIVE)');
  console.log('======================================================\n');

  try {
    const userMaps = await seedUsersAndProfiles();
    const courseRoomMaps = await seedCoursesAndClassrooms();
    const classMaps = await seedClassesAndRosters({ ...userMaps, ...courseRoomMaps });
    await seedSchedulesAndGrades({ ...userMaps, ...courseRoomMaps, ...classMaps });
    await seedTicketsAndHistory({ ...userMaps, ...courseRoomMaps, ...classMaps });

    await verifySeededData();
    console.log('🎉 PRISMA SEED COMPLETED SUCCESSFULLY!');
  } catch (error) {
    console.error('❌ Error during Prisma seeding:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main();
