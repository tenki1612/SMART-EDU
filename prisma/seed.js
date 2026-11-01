import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Pre-computed Bcrypt hashes for demo accounts
const HASHED_PASSWORDS = {
  admin123: '$2b$12$WXb5/UGH3527bTTvE.WHAesGpiqYw4kvtHgtquFm041YVMPUHxo.K',
  staff123: '$2b$12$dw.gsAIPkKJVkXp2jbA/OOpLV9O2yB7EVtRaQWKJ4IcRVi6N3pS3q',
  teacher123: '$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK',
  student123: '$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6',
  parent123: '$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6',
};

async function main() {
  console.log('⏳ Cleaning existing records...');
  // Delete in reverse dependency order
  await prisma.parentStudent.deleteMany().catch(() => {});
  await prisma.courseProgression.deleteMany().catch(() => {});
  await prisma.gradeRecord.deleteMany().catch(() => {});
  await prisma.scheduleSession.deleteMany().catch(() => {});
  await prisma.enrollmentRequest.deleteMany().catch(() => {});
  await prisma.classStudent.deleteMany().catch(() => {});
  await prisma.class.deleteMany().catch(() => {});
  await prisma.classroom.deleteMany().catch(() => {});
  await prisma.course.deleteMany().catch(() => {});
  await prisma.student.deleteMany().catch(() => {});
  await prisma.teacher.deleteMany().catch(() => {});
  await prisma.user.deleteMany().catch(() => {});

  console.log('🌱 1. Seeding Users (5 System Roles)...');
  const admin = await prisma.user.create({
    data: {
      username: 'admin',
      email: 'admin@center.edu.vn',
      fullName: 'Nguyễn Văn Quản Trị (Admin)',
      hashedPassword: HASHED_PASSWORDS.admin123,
      role: 'ADMIN',
      phone: '0901234567',
      isActive: true,
    },
  });

  const staff = await prisma.user.create({
    data: {
      username: 'staff',
      email: 'staff@center.edu.vn',
      fullName: 'Trần Thị Học Vụ (Staff)',
      hashedPassword: HASHED_PASSWORDS.staff123,
      role: 'ACADEMIC_STAFF',
      phone: '0912345678',
      isActive: true,
    },
  });

  const userTeacher = await prisma.user.create({
    data: {
      username: 'teacher',
      email: 'teacher@center.edu.vn',
      fullName: 'ThS. Lê Hoàng Nam (Teacher)',
      hashedPassword: HASHED_PASSWORDS.teacher123,
      role: 'TEACHER',
      phone: '0923456789',
      isActive: true,
    },
  });

  const userStudent = await prisma.user.create({
    data: {
      username: 'student',
      email: 'student@center.edu.vn',
      fullName: 'Phạm Minh Khang (Student)',
      hashedPassword: HASHED_PASSWORDS.student123,
      role: 'STUDENT',
      phone: '0934567890',
      isActive: true,
    },
  });

  const userParent = await prisma.user.create({
    data: {
      username: 'parent',
      email: 'parent@center.edu.vn',
      fullName: 'Phạm Quốc Hùng (Parent)',
      hashedPassword: HASHED_PASSWORDS.parent123,
      role: 'PARENT',
      phone: '0945678901',
      isActive: true,
    },
  });

  console.log('🌱 2. Seeding Profiles & Parent Link...');
  const teacher = await prisma.teacher.create({
    data: {
      userId: userTeacher.id,
      teacherCode: 'GV2026-001',
      specialty: 'IELTS 8.0 & Academic Writing',
      degree: 'Master of Applied Linguistics',
      status: 'ACTIVE',
    },
  });

  const student = await prisma.student.create({
    data: {
      userId: userStudent.id,
      studentCode: '26-04001',
      dateOfBirth: new Date('2005-05-15'),
      address: '123 Nguyễn Văn Cừ, Quận 5, TP.HCM',
      status: 'ACTIVE',
    },
  });

  await prisma.parentStudent.create({
    data: {
      parentUserId: userParent.id,
      studentId: student.id,
      relationshipType: 'Bố ruột',
    },
  });

  console.log('🌱 3. Seeding Courses (FR-11 -> FR-17)...');
  const course1 = await prisma.course.create({
    data: {
      code: 'IELTS-PREP-65',
      title: 'Luyện thi IELTS Chuyên Sâu 6.5+',
      description: 'Khóa học tập trung rèn luyện 4 kỹ năng chuẩn học thuật với mục tiêu đầu ra IELTS 6.5.',
      targetLevel: 'IELTS 6.5',
      durationWeeks: 12,
      fee: 8500000.0,
      isActive: true,
    },
  });

  const course2 = await prisma.course.create({
    data: {
      code: 'IELTS-MASTER-75',
      title: 'Luyện thi IELTS Master 7.5+',
      description: 'Khóa học nâng cao dành cho học viên đã đạt IELTS 6.5 muốn bứt phá lên 7.5+.',
      targetLevel: 'IELTS 7.5',
      durationWeeks: 12,
      fee: 10500000.0,
      isActive: true,
    },
  });

  const course3 = await prisma.course.create({
    data: {
      code: 'TOEIC-INTENSIVE-750',
      title: 'TOEIC Cấp Tốc 750+',
      description: 'Chinh phục kỳ thi TOEIC 2 kỹ năng Nghe - Đọc đạt chuẩn đầu ra đại học và đi làm.',
      targetLevel: 'TOEIC 750',
      durationWeeks: 8,
      fee: 5200000.0,
      isActive: true,
    },
  });

  console.log('🌱 4. Seeding Classrooms (FR-42 -> FR-49)...');
  const room1 = await prisma.classroom.create({
    data: { roomCode: 'P.101', building: 'Tòa nhà A', capacity: 30, status: 'AVAILABLE' },
  });
  const room2 = await prisma.classroom.create({
    data: { roomCode: 'P.102', building: 'Tòa nhà A', capacity: 25, status: 'AVAILABLE' },
  });
  await prisma.classroom.createMany({
    data: [
      { roomCode: 'LAB.201', building: 'Tòa nhà B (Phòng máy)', capacity: 35, status: 'AVAILABLE' },
      { roomCode: 'P.301', building: 'Tòa nhà C', capacity: 20, status: 'MAINTENANCE' },
    ],
  });

  console.log('🌱 5. Seeding Classes (FR-32 -> FR-41)...');
  const class1 = await prisma.class.create({
    data: {
      classCode: 'IELTS-65-K26A',
      courseId: course1.id,
      teacherId: teacher.id,
      maxCapacity: 20,
      currentEnrolled: 1,
      startDate: new Date('2026-11-01'),
      endDate: new Date('2027-01-24'),
      status: 'OPEN_FOR_ENROLLMENT',
    },
  });

  const class2 = await prisma.class.create({
    data: {
      classCode: 'IELTS-75-K26A',
      courseId: course2.id,
      teacherId: teacher.id,
      maxCapacity: 20,
      currentEnrolled: 0,
      startDate: new Date('2026-11-20'),
      endDate: new Date('2027-02-20'),
      status: 'OPEN_FOR_ENROLLMENT',
    },
  });

  const class3 = await prisma.class.create({
    data: {
      classCode: 'TOEIC-750-K12',
      courseId: course3.id,
      teacherId: teacher.id,
      maxCapacity: 25,
      currentEnrolled: 0,
      startDate: new Date('2026-11-15'),
      endDate: new Date('2027-01-15'),
      status: 'OPEN_FOR_ENROLLMENT',
    },
  });

  console.log('🌱 6. Seeding Class Membership & Enrollment Requests...');
  await prisma.classStudent.create({
    data: {
      classId: class1.id,
      studentId: student.id,
      status: 'ENROLLED',
    },
  });

  await prisma.enrollmentRequest.create({
    data: {
      studentId: student.id,
      classId: class1.id,
      status: 'APPROVED',
      note: 'Học viên đã nộp học phí qua chuyển khoản',
      reviewedBy: staff.id,
      reviewedAt: new Date(),
    },
  });

  console.log('🌱 7. Seeding Schedules, Grades & Course Progressions...');
  const now = new Date();
  const scheduleDate1 = new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000);
  const scheduleDate2 = new Date(now.getTime() + 4 * 24 * 60 * 60 * 1000);

  await prisma.scheduleSession.createMany({
    data: [
      {
        classId: class1.id,
        classroomId: room1.id,
        teacherId: teacher.id,
        sessionDate: scheduleDate1,
        startTime: '18:00',
        endTime: '20:00',
        slotName: 'Ca 3 (18:00 - 20:00)',
        isConfirmed: true,
        status: 'SCHEDULED',
      },
      {
        classId: class1.id,
        classroomId: room1.id,
        teacherId: teacher.id,
        sessionDate: scheduleDate2,
        startTime: '18:00',
        endTime: '20:00',
        slotName: 'Ca 3 (18:00 - 20:00)',
        isConfirmed: true,
        status: 'SCHEDULED',
      },
    ],
  });

  await prisma.gradeRecord.create({
    data: {
      classId: class1.id,
      studentId: student.id,
      attendanceScore: 9.5,
      midtermScore: 7.5,
      finalScore: 8.0,
      totalScore: 8.1,
      resultStatus: 'PASSED',
      isConfirmed: false,
      note: 'Học viên tiếp thu tốt, phát âm chuẩn, hoàn thành xuất sắc mục tiêu đầu ra 6.5.',
    },
  });

  await prisma.courseProgression.create({
    data: {
      studentId: student.id,
      currentCourseId: course1.id,
      nextCourseId: course2.id,
      isEligible: true,
      isConfirmed: true,
      confirmedBy: staff.id,
      confirmedAt: new Date(),
      note: 'Học viên đã đạt 8.1 ở khóa IELTS 6.5, đủ điều kiện học lên lớp IELTS Master 7.5+.',
    },
  });

  console.log('✅ Prisma Database Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during Prisma seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

