import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

# Find occupied rooms on 2026-11-22 at 18:00
cur.execute("""
    SELECT "MaPhongHoc" FROM "BUOI_HOC" 
    WHERE "NgayHoc" = '2026-11-22' AND "GioBatDau" = '18:00' AND "DaXoa" = FALSE;
""")
occupied = set(r[0] for r in cur.fetchall())
print("Occupied rooms on 2026-11-22 18:00:", occupied)

# Available room
cur.execute('SELECT "MaPhongHoc" FROM "PHONG_HOC" WHERE "DaXoa" = FALSE ORDER BY "MaPhongHoc" ASC;')
all_rooms = [r[0] for r in cur.fetchall()]
avail = [r for r in all_rooms if r not in occupied]
print("Available rooms:", avail)

if avail:
    target_room = avail[0]
    cur.execute('UPDATE "BUOI_HOC" SET "MaPhongHoc" = %s WHERE "MaBuoiHoc" = 28;', (target_room,))
    conn.commit()
    print(f"Updated MaBuoiHoc 28 to Room {target_room}")

conn.close()
