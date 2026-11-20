import requests

BASE_URL = "http://127.0.0.1:8000/api/v1"

print("==================================================================")
print("🌐 COMPREHENSIVE LIVE API VERIFICATION ON PORT 8000 (POSTGRESQL)")
print("==================================================================")

# 1. Login
tokens = {}
users = [
    ("admin", "admin123", "ADMIN"),
    ("staff", "staff123", "ACADEMIC_STAFF"),
    ("teacher", "teacher123", "TEACHER"),
    ("student", "student123", "STUDENT")
]

for u, p, role in users:
    r = requests.post(f"{BASE_URL}/auth/login", json={"username": u, "password": p})
    assert r.status_code == 200, f"Login failed for {u}: {r.text}"
    tokens[role] = r.json().get("data", {}).get("access_token")
    print(f"  ✅ [200 OK] Auth Login: {u} ({role})")

admin_hdr = {"Authorization": f"Bearer {tokens['ADMIN']}"}
staff_hdr = {"Authorization": f"Bearer {tokens['ACADEMIC_STAFF']}"}
teacher_hdr = {"Authorization": f"Bearer {tokens['TEACHER']}"}
student_hdr = {"Authorization": f"Bearer {tokens['STUDENT']}"}

# 2. Courses
r = requests.get(f"{BASE_URL}/courses/")
assert r.status_code == 200
courses = r.json().get("data", [])
print(f"  ✅ [200 OK] GET /courses/: {len(courses)} courses active (Expected: 34)")
assert len(courses) == 34, f"Expected 34 courses, got {len(courses)}"

# 3. Classes
r = requests.get(f"{BASE_URL}/classes/", headers=staff_hdr)
assert r.status_code == 200
classes = r.json().get("data", [])
print(f"  ✅ [200 OK] GET /classes/: {len(classes)} classes active (Expected: 108)")
assert len(classes) == 108, f"Expected 108 classes, got {len(classes)}"

# 4. Classrooms
r = requests.get(f"{BASE_URL}/classrooms/", headers=staff_hdr)
if r.status_code != 200:
    print(f"  ❌ Classrooms failed: {r.status_code} - {r.text}")
assert r.status_code == 200
rooms = r.json().get("data", [])
print(f"  ✅ [200 OK] GET /classrooms/: {len(rooms)} classrooms active (Expected: 20)")
assert len(rooms) == 20, f"Expected 20 rooms, got {len(rooms)}"

# 5. Schedules
r = requests.get(f"{BASE_URL}/schedules/?skip=0&limit=10", headers=staff_hdr)
assert r.status_code == 200
schedules = r.json().get("data", [])
print(f"  ✅ [200 OK] GET /schedules/: {len(schedules)} sessions sampled")

# 6. Tickets (DON_THU: Inbox, Sent, Stats)
r = requests.get(f"{BASE_URL}/tickets/inbox", headers=admin_hdr)
assert r.status_code == 200
inbox_data = r.json().get("data")
inbox = inbox_data.get("items", []) if isinstance(inbox_data, dict) else inbox_data
print(f"  ✅ [200 OK] GET /tickets/inbox (ADMIN): {len(inbox)} inbox tickets")

r = requests.get(f"{BASE_URL}/tickets/sent", headers=student_hdr)
assert r.status_code == 200
sent_data = r.json().get("data")
sent = sent_data.get("items", []) if isinstance(sent_data, dict) else sent_data
print(f"  ✅ [200 OK] GET /tickets/sent (STUDENT): {len(sent)} sent tickets")

r = requests.get(f"{BASE_URL}/tickets/stats", headers=admin_hdr)
assert r.status_code == 200
stats = r.json().get("data", {})
print(f"  ✅ [200 OK] GET /tickets/stats (ADMIN): stats={stats}")

# 7. Grades
r = requests.get(f"{BASE_URL}/grades/classes/1/sheet", headers=staff_hdr)
assert r.status_code == 200
sheet = r.json().get("data", [])
print(f"  ✅ [200 OK] GET /grades/classes/1/sheet: {len(sheet)} student grading records")

# 8. Enrollments & Prerequisite Check
r = requests.get(f"{BASE_URL}/enrollments/check-prerequisite?class_id=1", headers=student_hdr)
assert r.status_code == 200
prereq_res = r.json().get("data", {})
print(f"  ✅ [200 OK] GET /enrollments/check-prerequisite: is_eligible={prereq_res.get('is_eligible')}")

print("\n🎉 ALL 8 CORE MODULE ENDPOINTS PASSED FLAWLESSLY ON LIVE POSTGRESQL!")
