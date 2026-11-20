rooms = list(range(1, 21)) # 20 rooms
teachers = list(range(1, 41)) # 40 teachers

patterns = [
    ([0, 2], 'T2-T4'),
    ([1, 3], 'T3-T5'),
    ([4, 5], 'T6-T7'),
    ([6], 'CN')
]
slots = [
    ('07:30', '09:00', 'Ca sáng 1'),
    ('09:15', '10:45', 'Ca sáng 2'),
    ('13:30', '15:00', 'Ca chiều 1'),
    ('15:15', '16:45', 'Ca chiều 2'),
    ('18:00', '19:30', 'Ca tối 1'),
    ('19:45', '21:15', 'Ca tối 2')
]

windows = []
for p, p_name in patterns:
    for s, e, l in slots:
        windows.append((p, p_name, s, e, l))

class_assignments = {}
for cid in range(1, 106):
    w_idx = (cid - 1) % len(windows)
    pos_in_window = (cid - 1) // len(windows)
    
    r_id = rooms[pos_in_window % len(rooms)]
    t_id = teachers[(pos_in_window * 7 + w_idx) % len(teachers)]
    
    p, p_name, s, e, l = windows[w_idx]
    class_assignments[cid] = {'room': r_id, 'teacher': t_id, 'days': p, 'start': s, 'end': e}

has_conflict = False
for day in range(7):
    day_classes = [c for c in class_assignments.values() if day in c['days']]
    for i in range(len(day_classes)):
        for j in range(i + 1, len(day_classes)):
            c1 = day_classes[i]
            c2 = day_classes[j]
            if c1['start'] < c2['end'] and c1['end'] > c2['start']:
                if c1['room'] == c2['room']:
                    print(f"Room conflict on day {day}: room {c1['room']}")
                    has_conflict = True
                if c1['teacher'] == c2['teacher']:
                    print(f"Teacher conflict on day {day}: teacher {c1['teacher']}")
                    has_conflict = True

if not has_conflict:
    print("VERIFIED: 100% CONFLICT-FREE! ZERO ROOM CONFLICTS, ZERO TEACHER CONFLICTS!")
